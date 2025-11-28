import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart';
import 'auth_service.dart';

class OrderService {
  static Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
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
        final List<dynamic> ordersJson =
            data is Map ? (data['orders'] ?? []) : data;
        
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
        body: jsonEncode({'status': status}),
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
        final List<dynamic> ordersJson =
            data is Map ? (data['orders'] ?? []) : data;
        
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
