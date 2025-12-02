import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/socket_service.dart';
import '../services/chat_service.dart';
import 'package:intl/intl.dart';

/// Admin chat detail screen for responding to a specific customer
class AdminChatDetailScreen extends StatefulWidget {
  final String conversationId;
  final String customerName;
  final String customerEmail;

  const AdminChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.customerName,
    required this.customerEmail,
  });

  @override
  State<AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
}

class _AdminChatDetailScreenState extends State<AdminChatDetailScreen> {
  final SocketService _socketService = SocketService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> messages = [];
  String? userId;
  bool isTyping = false;
  bool isLoading = true;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    userId = user.uid;
    final token = await user.getIdToken();
    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    // Connect and setup listeners
    _socketService.connect(token);

    // Listen for connection status
    _socketService.socket?.on('connect', (_) {
      if (mounted) setState(() => isConnected = true);
    });
    _socketService.socket?.on('disconnect', (_) {
      if (mounted) setState(() => isConnected = false);
    });

    // Load message history
    await _loadMessages();

    // Join conversation room
    _socketService.joinConversation(widget.conversationId);

    // Listen for new messages
    _socketService.onNewMessage((data) {
      if (mounted) {
        final newMessage = data['message'];
        final existingIndex = messages.indexWhere((m) =>
            m['timestamp'] == newMessage['timestamp'] &&
            m['message'] == newMessage['message']);

        if (existingIndex == -1) {
          setState(() {
            messages.add(newMessage);
          });
          _scrollToBottom();
        }
      }
    });

    // Listen for typing indicator
    _socketService.onUserTyping((data) {
      if (mounted) {
        setState(() {
          isTyping = data['isTyping'] ?? false;
        });
      }
    });

    // Mark messages as read
    await ChatService.markMessagesAsRead(widget.conversationId);

    if (mounted) {
      setState(() {
        isLoading = false;
        isConnected = _socketService.socket?.connected ?? false;
      });
    }
  }

  Future<void> _loadMessages() async {
    final loadedMessages =
        await ChatService.getMessages(widget.conversationId);
    if (mounted) {
      setState(() {
        messages = loadedMessages;
      });
      _scrollToBottom();
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not connected to server. Checking connection...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Optimistic Update: Add message immediately
    final tempMessage = {
      'message': text,
      'senderId': userId,
      'senderRole': 'admin',
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    };

    setState(() {
      messages.add(tempMessage);
    });
    _scrollToBottom();

    // Send to server
    _socketService.sendMessage(widget.conversationId, text);
    _messageController.clear();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    _socketService.removeAllListeners();
    _socketService.disconnect();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFEDFF00),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.customerName,
              style: const TextStyle(
                fontFamily: 'kobe11Bold',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.customerEmail.isNotEmpty)
              Text(
                widget.customerEmail,
                style: TextStyle(
                  fontFamily: 'kobe11',
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isConnected ? const Color(0xFFEDFF00) : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isConnected ? 'Online' : 'Offline',
              style: const TextStyle(
                fontFamily: 'kobe11Bold',
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontFamily: 'kobe11',
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final senderRole = message['senderRole'] ?? 'user';
                      final isAdmin = senderRole == 'admin';

                      return Align(
                        alignment: isAdmin
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? const Color(0xFFEDFF00)
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['message'] ?? '',
                                style: TextStyle(
                                  fontFamily: 'kobe11',
                                  color: isAdmin ? Colors.black : Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(message['timestamp'] ?? ''),
                                style: TextStyle(
                                  fontFamily: 'kobe11',
                                  fontSize: 10,
                                  color:
                                      isAdmin ? Colors.black54 : Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Typing indicator
          if (isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFFEDFF00),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${widget.customerName} is typing...',
                    style: const TextStyle(
                      fontFamily: 'kobe11',
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(
                top: BorderSide(color: Colors.grey[800]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(
                      fontFamily: 'kobe11',
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(
                        fontFamily: 'kobe11',
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (text) {
                      // Send typing indicator
                      _socketService.sendTypingIndicator(
                        widget.conversationId,
                        text.isNotEmpty,
                      );
                    },
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDFF00),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
