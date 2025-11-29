import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart';
import 'auth_service.dart';

import 'product_service.dart';

class OrderService {
  static Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  /// Helper to enrich orders with missing product details
  static Future<List<dynamic>> _enrichOrders(List<dynamic> ordersJson) async {
    print('DEBUG: Enriching ${ordersJson.length} orders');
    for (var order in ordersJson) {
      if (order['items'] != null) {
        for (var item in order['items']) {
          // Check if name is missing, null, or empty (including whitespace)
          final currentName = item['name']?.toString().trim() ?? '';
          
          if (currentName.isEmpty) {
            final productId = item['productId'];
            if (productId != null && productId.toString().isNotEmpty) {
              print('DEBUG: Fetching product details for productId: $productId (current name: "${item['name']}")');
              try {
                final product = await ProductService.getProduct(productId.toString());
                if (product != null) {
                  print('DEBUG: Successfully fetched product: ${product.name}');
                  item['name'] = product.name;
                  // Optionally update image if missing
                  if (item['image'] == null || item['image'].toString().isEmpty) {
                    item['image'] = product.image;
                  }
                } else {
                  print('WARNING: Product not found for productId: $productId');
                }
              } catch (e) {
                print('ERROR: Failed to enrich order item for productId $productId: $e');
              }
            } else {
              print('WARNING: Order item has empty name but no valid productId');
            }
          }
        }
      }
    }
    print('DEBUG: Enrichment complete');
    return ordersJson;
  }

  /// Fetch all orders (Admin only)
  static Future<List<Order>> getAllOrders() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('User not logged in');

      final res = await http.get(
        Uri.parse('${AuthService.backendBase}/api/orders/all/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // Handle response format: { count: 0, orders: [] } or just []
        List<dynamic> ordersJson =
            data is Map ? (data['orders'] ?? []) : data;
        
        // Enrich orders with missing details
        ordersJson = await _enrichOrders(ordersJson);

        return ordersJson.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders: ${res.statusCode}');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  /// Update order status (Admin only)
  static Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('User not logged in');

      final res = await http.put(
        Uri.parse('${AuthService.backendBase}/api/orders/$orderId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'orderStatus': status}),
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  /// Fetch orders for the current user
  static Future<List<Order>> getUserOrders() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('User not logged in');

      final res = await http.get(
        Uri.parse('${AuthService.backendBase}/api/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // Handle response format: { count: 0, orders: [] } or just []
        List<dynamic> ordersJson =
            data is Map ? (data['orders'] ?? []) : data;
            
        // Enrich orders with missing details
        ordersJson = await _enrichOrders(ordersJson);
        
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user orders: ${res.statusCode}');
      }
    } catch (e) {
      print('Error fetching user orders: $e');
      return [];
    }
  }
}
