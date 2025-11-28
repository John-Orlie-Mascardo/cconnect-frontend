import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

/// Service for managing user wishlist operations
/// Communicates with backend API for wishlist CRUD operations
class WishlistService {
  static Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  /// Fetch user's wishlist items from backend
  /// Returns list of wishlist items with product details
  static Future<List<Map<String, dynamic>>> getWishlist() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final res = await http.get(
        Uri.parse('${AuthService.backendBase}/api/wishlist'),
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
      print('Error fetching wishlist: $e');
      return [];
    }
  }

  /// Add a product to user's wishlist
  /// @param productId - ID of the product to add
  /// @param productData - Optional product data (title, price, image, etc.)
  static Future<bool> addToWishlist(
    String productId, {
    Map<String, dynamic>? productData,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final body = {
        'productId': productId,
        if (productData != null) ...productData,
      };

      final res = await http.post(
        Uri.parse('${AuthService.backendBase}/api/wishlist/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print('Error adding to wishlist: $e');
      return false;
    }
  }

  /// Remove a product from user's wishlist
  /// @param productId - ID of the product to remove
  static Future<bool> removeFromWishlist(String productId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final res = await http.delete(
        Uri.parse('${AuthService.backendBase}/api/wishlist/remove/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      print('Error removing from wishlist: $e');
      return false;
    }
  }

  /// Check if a product is in user's wishlist
  /// @param productId - ID of the product to check
  static Future<bool> isInWishlist(String productId) async {
    try {
      final wishlist = await getWishlist();
      return wishlist.any((item) => item['productId'] == productId);
    } catch (e) {
      print('Error checking wishlist status: $e');
      return false;
    }
  }

  /// Clear entire wishlist
  static Future<bool> clearWishlist() async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final res = await http.delete(
        Uri.parse('${AuthService.backendBase}/api/wishlist'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      print('Error clearing wishlist: $e');
      return false;
    }
  }
}
