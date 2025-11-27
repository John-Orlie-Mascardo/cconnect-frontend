import 'dart:convert';
import 'package:http/http.dart' as http;
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
        Uri.parse('${AuthService.backendBase}/api/user/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> items = data['items'] ?? [];
        return items.map((item) => Map<String, dynamic>.from(item)).toList();
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
        Uri.parse('${AuthService.backendBase}/api/user/cart'),
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
        Uri.parse('${AuthService.backendBase}/api/user/cart/$productId'),
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
        Uri.parse('${AuthService.backendBase}/api/user/cart'),
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
        Uri.parse('${AuthService.backendBase}/api/user/cart/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'quantity': quantity}),
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200;
    } catch (e) {
      print('Error updating cart item: $e');
      return false;
    }
  }
}
