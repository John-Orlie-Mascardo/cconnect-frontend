import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/socket_service.dart';
import '../services/chat_service.dart';
import 'package:intl/intl.dart';

/// Real-time chat screen for customer-store communication
class RealtimeChatScreen extends StatefulWidget {
  final String? productName;
  final String? productImage;

  const RealtimeChatScreen({
    super.key,
    this.productName,
    this.productImage,
  });

  @override
  State<RealtimeChatScreen> createState() => _RealtimeChatScreenState();
}

class _RealtimeChatScreenState extends State<RealtimeChatScreen> {
  final SocketService _socketService = SocketService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> messages = [];
  String? conversationId;
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

    await _getOrCreateConversation();
    await _loadMessages();

    if (conversationId != null) {
      _socketService.joinConversation(conversationId!);
    }

    _socketService.onNewMessage((data) {
      if (mounted) {
        // Check if we already have this message (to avoid duplicates from optimistic update)
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

    _socketService.onUserTyping((data) {
      if (mounted) {
        setState(() {
          isTyping = data['isTyping'] ?? false;
        });
      }
    });

    if (mounted) {
      setState(() {
        isLoading = false;
        isConnected = _socketService.socket?.connected ?? false;
      });
    }
  }

  Future<void> _getOrCreateConversation() async {
    final data = await ChatService.getOrCreateConversation();
    if (data != null && mounted) {
      setState(() {
        conversationId = data['conversation']['_id'];
      });
    }
  }

  Future<void> _loadMessages() async {
    if (conversationId == null) return;

    final loadedMessages = await ChatService.getMessages(conversationId!);
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

    if (conversationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No conversation found. Try reloading.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not connected to server. Checking connection...'),
          backgroundColor: Colors.orange,
        ),
      );
      // Try to reconnect
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        user.getIdToken().then((token) {
          if (token != null) _socketService.connect(token);
        });
      }
      return;
    }

    // 1. Optimistic Update: Add message immediately
    final tempMessage = {
      'message': text,
      'senderId': userId,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    };

    setState(() {
      messages.add(tempMessage);
    });
    _scrollToBottom();

    // 2. Send to server
    _socketService.sendMessage(conversationId!, text);
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
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEDFF00),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.store,
                color: Colors.black,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Store Owner',
                    style: TextStyle(
                      fontFamily: 'kobe11Bold',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isConnected ? 'Online' : 'Connecting...',
                    style: TextStyle(
                      fontFamily: 'kobe11',
                      color: isConnected ? const Color(0xFFEDFF00) : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (isTyping)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Typing...',
                style: TextStyle(
                  fontFamily: 'kobe11',
                  fontSize: 12,
                  color: Color(0xFFEDFF00),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Product context (if provided)
          if (widget.productName != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFEDFF00), width: 1),
              ),
              child: Row(
                children: [
                  if (widget.productImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        widget.productImage!.startsWith('http')
                            ? widget.productImage!
                            : 'http://localhost:3000${widget.productImage!.startsWith('/') ? '' : '/'}${widget.productImage}',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.image,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Asking about:',
                          style: TextStyle(
                            fontFamily: 'kobe11',
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          widget.productName!,
                          style: const TextStyle(
                            fontFamily: 'kobe11Bold',
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

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
                        const SizedBox(height: 8),
                        Text(
                          'Start a conversation with the store',
                          style: TextStyle(
                            fontFamily: 'kobe11',
                            color: Colors.grey[700],
                            fontSize: 14,
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
                      
                      // Use senderRole to determine if message is from current user
                      // In customer chat: admin messages = left, customer messages = right
                      final senderRole = message['senderRole'] ?? 'user';
                      final isMe = senderRole != 'admin'; // If NOT admin, it's the customer

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
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
                            color: isMe
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
                                  color: isMe ? Colors.black : Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(message['timestamp'] ?? ''),
                                style: TextStyle(
                                  fontFamily: 'kobe11',
                                  fontSize: 10,
                                  color: isMe ? Colors.black54 : Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
                      if (conversationId != null) {
                        _socketService.sendTypingIndicator(
                          conversationId!,
                          text.isNotEmpty,
                        );
                      }
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
