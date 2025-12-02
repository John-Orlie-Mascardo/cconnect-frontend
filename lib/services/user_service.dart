import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class UserService {
  /// Update user profile (name, phone)
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'error': 'User not logged in'};
      }

      final token = await user.getIdToken();

      // Construct body with only non-null values
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;

      if (body.isEmpty) {
        return {'success': true, 'message': 'No changes to update'};
      }

      final res = await http
          .put(
            Uri.parse('${AuthService.backendBase}/api/user/profile'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return {'success': true, 'body': jsonDecode(res.body)};
      } else {
        return {
          'error': 'Failed to update profile: ${res.statusCode}',
          'body': res.body,
        };
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Fetch user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'error': 'User not logged in'};
      }

      final token = await user.getIdToken();

      final res = await http
          .get(
            Uri.parse('${AuthService.backendBase}/api/user/profile'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(res.body)};
      } else {
        return {
          'error': 'Failed to fetch profile: ${res.statusCode}',
          'body': res.body,
        };
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Fetch user count
  static Future<int> getUserCount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return 0;
      }

      final token = await user.getIdToken();

      final res = await http
          .get(
            Uri.parse('${AuthService.backendBase}/api/user/count'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['count'] ?? 0;
      } else {
        print('Failed to fetch user count: ${res.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error fetching user count: $e');
      return 0;
    }
  }

  /// Fetch all users (Admin)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return [];
      }

      final token = await user.getIdToken();

      final res = await http
          .get(
            Uri.parse('${AuthService.backendBase}/api/user/all'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Failed to fetch users: ${res.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  /// Update user status (Admin)
  static Future<bool> updateUserStatus(String userId, String status) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final token = await user.getIdToken();

      final res = await http
          .put(
            Uri.parse('${AuthService.backendBase}/api/user/$userId/status'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'status': status}),
          )
          .timeout(const Duration(seconds: 10));

      return res.statusCode == 200;
    } catch (e) {
      print('Error updating user status: $e');
      return false;
    }
  }
}
