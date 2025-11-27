// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Replace with correct base depending on platform/test:
  // - Flutter Web / Desktop: use http://localhost:3000
  // - Android emulator: use http://10.0.2.2:3000
  // - Physical device: use http://<your_pc_local_ip>:3000
  static String get backendBase {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      return 'http://10.0.2.2:3000';
    }
  }

  // Register with Firebase then notify backend
  static Future<Map<String, dynamic>> registerWithEmail(String email, String password) async {
    try {
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final token = await cred.user?.getIdToken();
      final res = await http.post(
        Uri.parse('$backendBase/api/user/register'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}), // backend reads from token
      );

      return {
        'statusCode': res.statusCode,
        'body': res.body,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Login with Firebase then notify backend (or fetch profile)
  static Future<Map<String, dynamic>> loginWithEmail(String email, String password) async {
    try {
      UserCredential cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final token = await cred.user?.getIdToken();
      final res = await http.post(
        Uri.parse('$backendBase/api/user/login'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );

      return {
        'statusCode': res.statusCode,
        'body': res.body,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Traditional login (MongoDB-based, for users who reset password)
  static Future<Map<String, dynamic>> loginWithTraditional(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$backendBase/api/user/login-traditional'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return {
        'statusCode': res.statusCode,
        'body': res.body,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  // ─── ROLE MANAGEMENT ───────────────────────────────────────

  static const String _roleKey = 'user_role';

  /// Save user role to local storage
  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  /// Get user role from local storage
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  /// Clear user role (logout)
  static Future<void> clearRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
  }
  /// Request password reset link
  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final res = await http.post(
        Uri.parse('$backendBase/api/password-reset/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return {
        'statusCode': res.statusCode,
        'body': res.body,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Verify reset token (optional check before showing reset screen)
  static Future<bool> verifyResetToken(String token, String userId) async {
    try {
      final res = await http.get(
        Uri.parse('$backendBase/api/password-reset/verify?token=$token&userId=$userId'),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Reset password with new password
  static Future<Map<String, dynamic>> resetPassword(
      String token, String userId, String newPassword) async {
    try {
      final res = await http.post(
        Uri.parse('$backendBase/api/password-reset/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'userId': userId,
          'newPassword': newPassword,
        }),
      );
      return {
        'statusCode': res.statusCode,
        'body': res.body,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
