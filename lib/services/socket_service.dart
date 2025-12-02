import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Socket.IO service for real-time chat communication
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;
  bool isConnected = false;

  // Replace with your backend URL
  final String serverUrl = 'http://localhost:3000';

  /// Connect to Socket.IO server with authentication
  void connect(String authToken) {
    socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    socket!.on('connect', (_) {
      print('✅ Connected to Socket.IO');
      isConnected = true;

      // Authenticate immediately after connection
      socket!.emit('authenticate', authToken);
    });

    socket!.on('authenticated', (data) {
      print('✅ Authenticated: $data');
    });

    socket!.on('disconnect', (_) {
      print('❌ Disconnected from Socket.IO');
      isConnected = false;
    });

    socket!.on('error', (error) {
      print('❌ Socket error: $error');
    });
  }

  /// Disconnect from Socket.IO server
  void disconnect() {
    socket?.disconnect();
    socket?.dispose();
    isConnected = false;
  }

  /// Join a conversation room
  void joinConversation(String conversationId) {
    if (isConnected) {
      socket!.emit('join_conversation', conversationId);
    }
  }

  /// Send a message to the conversation
  void sendMessage(String conversationId, String message) {
    if (isConnected) {
      socket!.emit('send_message', {
        'conversationId': conversationId,
        'message': message,
      });
    }
  }

  /// Send typing indicator
  void sendTypingIndicator(String conversationId, bool isTyping) {
    if (isConnected) {
      socket!.emit('typing', {
        'conversationId': conversationId,
        'isTyping': isTyping,
      });
    }
  }

  /// Mark messages as read
  void markAsRead(String conversationId) {
    if (isConnected) {
      socket!.emit('mark_read', {
        'conversationId': conversationId,
      });
    }
  }

  /// Listen for new messages
  void onNewMessage(Function(dynamic) callback) {
    socket?.on('new_message', callback);
  }

  /// Listen for typing indicator
  void onUserTyping(Function(dynamic) callback) {
    socket?.on('user_typing', callback);
  }

  /// Listen for messages read event
  void onMessagesRead(Function(dynamic) callback) {
    socket?.on('messages_read', callback);
  }

  /// Remove all listeners
  void removeAllListeners() {
    socket?.off('new_message');
    socket?.off('user_typing');
    socket?.off('messages_read');
  }
}
