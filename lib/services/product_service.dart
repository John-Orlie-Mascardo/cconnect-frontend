import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductService {
  // API Base URL
  static String get kApiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    } else {
      return 'http://localhost:3000/api';
    }
  }

  // Get all products
  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$kApiBaseUrl/products'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }

  // Get single product
  static Future<Product?> getProduct(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$kApiBaseUrl/products/$id'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data['product']);
      } else {
        print('Failed to load product $id: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching product $id: $e');
      return null;
    }
  }

  // Update product
  static Future<Product> updateProduct(String id, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$kApiBaseUrl/products/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data['product']);
      } else {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  // Delete product
  static Future<void> deleteProduct(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$kApiBaseUrl/products/$id'),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }
}
