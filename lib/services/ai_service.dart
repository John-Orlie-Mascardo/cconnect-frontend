import 'package:http/http.dart' as http;
import 'dart:convert';

class AIService {
  // Update this URL based on your backend deployment
  // For local testing on web: http://localhost:3000/api
  // For mobile testing: http://YOUR_IP:3000/api (e.g., http://192.168.1.100:3000/api)
  static const String baseUrl = 'http://localhost:3000/api';

  /// Send a chat message to the AI backend
  /// Returns the AI response or throws an exception on error
  static Future<Map<String, dynamic>> sendChatMessage(
    String message, {
    String? userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          if (userId != null) 'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 503) {
        throw Exception('AI service not configured yet. Please add your OpenAI API key to the backend .env file.');
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('AI service not configured')) {
        rethrow;
      }
      throw Exception('Network error: Unable to connect to AI service');
    }
  }
}
