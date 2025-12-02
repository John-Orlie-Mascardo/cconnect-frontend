import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address.dart';
import 'auth_service.dart';

class AddressService {
  static Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  /// Fetch all addresses for the current user
  static Future<List<Address>> getAddresses() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('User not logged in');

      final res = await http
          .get(
            Uri.parse('${AuthService.backendBase}/api/user/addresses'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((json) => Address.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load addresses: ${res.statusCode}');
      }
    } catch (e) {
      print('Error fetching addresses: $e');
      rethrow; // Rethrow to let UI handle the error
    }
  }

  /// Add a new address
  static Future<Address?> addAddress(Address address) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('User not logged in');

      final res = await http
          .post(
            Uri.parse('${AuthService.backendBase}/api/user/addresses'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(address.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return Address.fromJson(jsonDecode(res.body));
      } else {
        throw Exception('Failed to add address: ${res.statusCode}');
      }
    } catch (e) {
      print('Error adding address: $e');
      return null;
    }
  }

  /// Update an existing address
  static Future<bool> updateAddress(String id, Address address) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('User not logged in');

      final res = await http
          .put(
            Uri.parse('${AuthService.backendBase}/api/user/addresses/$id'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(address.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      return res.statusCode == 200;
    } catch (e) {
      print('Error updating address: $e');
      return false;
    }
  }

  /// Delete an address
  static Future<bool> deleteAddress(String id) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('User not logged in');

      final res = await http
          .delete(
            Uri.parse('${AuthService.backendBase}/api/user/addresses/$id'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      print('Error deleting address: $e');
      return false;
    }
  }
}
