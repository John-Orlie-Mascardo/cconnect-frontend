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

      final res = await http
          .get(
            Uri.parse('${AuthService.backendBase}/api/wishlist'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> items = data['items'] ?? [];

        // Normalize items to ensure correct ID and details
        return items.map((item) {
          final map = Map<String, dynamic>.from(item);

          // 1. Check for nested 'product' object
          if (map['product'] is Map) {
            final product = map['product'];
            map['title'] = product['name'] ?? product['title'];
            map['image'] = product['image'] ?? map['image'];
            map['price'] = product['price'] ?? map['price'];
            map['description'] = product['description'] ?? map['description'];
            map['productId'] = product['_id']; // Use MongoDB _id
          }
          // 2. Check for populated 'productId' object
          else if (map['productId'] is Map) {
            final product = map['productId'];
            map['title'] = product['name'] ?? product['title'];
            map['image'] = product['image'] ?? map['image'];
            map['price'] = product['price'] ?? map['price'];
            map['description'] = product['description'] ?? map['description'];
            map['productId'] = product['_id']; // Use MongoDB _id
          }
          // 3. Handle flat structure (Found in logs)
          else {
            // Map 'name' to 'title' if needed
            if (map['title'] == null && map['name'] != null) {
              map['title'] = map['name'];
            }
            // CRITICAL: Use top-level '_id' as 'productId' if available
            // The logs showed the real MongoDB ID is in '_id', while 'productId' contained a legacy ID (e.g. "4412")
            if (map['_id'] != null) {
              map['productId'] = map['_id'];
            }
          }

          // Ensure productId is a string
          if (map['productId'] != null) {
            map['productId'] = map['productId'].toString();
          }

          return map;
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching wishlist: $e');
      rethrow;
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

      final res = await http
          .post(
            Uri.parse('${AuthService.backendBase}/api/wishlist/add'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

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

      final res = await http
          .delete(
            Uri.parse(
              '${AuthService.backendBase}/api/wishlist/remove/$productId',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

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

      final res = await http
          .delete(
            Uri.parse('${AuthService.backendBase}/api/wishlist'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      print('Error clearing wishlist: $e');
      return false;
    }
  }
}
