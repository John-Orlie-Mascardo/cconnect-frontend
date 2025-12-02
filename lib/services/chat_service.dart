import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';

/// Service for chat-related REST API calls
class ChatService {
  static const String baseUrl = ApiService.baseUrl;

  /// Get or create a conversation for the current user
  static Future<Map<String, dynamic>?> getOrCreateConversation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final token = await user.getIdToken();
      final userId = user.uid;

      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/conversation/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to get conversation: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting conversation: $e');
      return null;
    }
  }

  /// Get message history for a conversation
  static Future<List<dynamic>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final token = await user.getIdToken();

      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/chat/messages/$conversationId?page=$page&limit=$limit',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['messages'] ?? [];
      } else {
        print('Failed to get messages: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  /// Mark messages as read
  static Future<bool> markMessagesAsRead(String conversationId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final token = await user.getIdToken();

      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/messages/$conversationId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error marking messages as read: $e');
      return false;
    }
  }

  /// Get all conversations (admin only)
  static Future<List<dynamic>> getAllConversations() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final token = await user.getIdToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/conversations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['conversations'] ?? [];
      } else {
        print('Failed to get conversations: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting conversations: $e');
      return [];
    }
  }

  /// Close a conversation
  static Future<bool> closeConversation(String conversationId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final token = await user.getIdToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/api/chat/conversation/$conversationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error closing conversation: $e');
      return false;
    }
  }
}
