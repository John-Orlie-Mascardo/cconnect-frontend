import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class CartService {
  static Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  /// Fetch cart items from backend
  static Future<List<Map<String, dynamic>>> getCart() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final res = await http.get(
        Uri.parse('${AuthService.backendBase}/api/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> items = data['items'] ?? [];
        
        // Process items and fetch missing details
        final List<Map<String, dynamic>> processedItems = [];
        
        for (var item in items) {
          final map = Map<String, dynamic>.from(item);
          
          // 1. Check for nested 'product' object (Found in logs)
          if (map['product'] is Map) {
            final product = map['product'];
            map['title'] = product['name'] ?? product['title'];
            map['image'] = product['image'] ?? map['image'];
            map['price'] = product['price'] ?? map['price'];
            map['productId'] = product['_id']; // This is the correct ID for cart operations
          }
          // 2. Try to get details from populated productId (Legacy/Alternative)
          else if (map['productId'] is Map) {
            final product = map['productId'];
            map['title'] = product['name'] ?? product['title'];
            map['image'] = product['image'] ?? map['image'];
            map['price'] = product['price'] ?? map['price'];
            map['productId'] = product['_id']; 
          }
          
          // 3. Fallback: Check top-level fields
          if (map['title'] == null && map['name'] != null) {
            map['title'] = map['name'];
          }

          // 4. Ensure productId is a string
          if (map['productId'] is Map) {
             map['productId'] = map['productId']['_id'];
          }
          
          // 5. If title is STILL missing, fetch from API
          if (map['title'] == null && map['productId'] != null) {
            print('DEBUG: Fetching missing details for productId: ${map['productId']}');
            try {
              final product = await ProductService.getProduct(map['productId'].toString());
              if (product != null) {
                print('DEBUG: Fetched product: ${product.name}');
                map['title'] = product.name;
                map['image'] = product.image;
                map['price'] = product.price;
              } else {
                print('DEBUG: Product not found for ID: ${map['productId']}');
              }
            } catch (e) {
              print('Error fetching details for cart item: $e');
            }
          }

          processedItems.add(map);
        }

        print('DEBUG: Processed items: $processedItems');
        return processedItems;
      }
      return [];
    } catch (e) {
      print('Error fetching cart: $e');
      return [];
    }
  }

  /// Add item to cart
  static Future<bool> addItem(Map<String, dynamic> item) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final res = await http.post(
        Uri.parse('${AuthService.backendBase}/api/cart/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(item),
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print('Error adding item to cart: $e');
      return false;
    }
  }

  /// Remove item from cart
  static Future<bool> removeItem(String productId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final res = await http.delete(
        Uri.parse('${AuthService.backendBase}/api/cart/remove/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      print('Error removing item from cart: $e');
      return false;
    }
  }

  /// Clear entire cart
  static Future<bool> clearCart() async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final res = await http.delete(
        Uri.parse('${AuthService.backendBase}/api/cart/clear'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  /// Update item quantity
  static Future<bool> updateQuantity(String productId, int quantity) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final res = await http.put(
        Uri.parse('${AuthService.backendBase}/api/cart/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'productId': productId, 'quantity': quantity}),
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200;
    } catch (e) {
      print('Error updating cart item: $e');
      return false;
    }
  }
}
