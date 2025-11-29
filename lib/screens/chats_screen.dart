import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message from AI
    _messages.add({
      'role': 'assistant',
      'content': 'Hi! 👋 I\'m your CConnect assistant. How can I help you today?',
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Add user message to chat
    setState(() {
      _messages.add({'role': 'user', 'content': message});
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Send message to AI backend
      final response = await AIService.sendChatMessage(message);

      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': response['response'] ?? 'Sorry, I didn\'t get a response.',
        });
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'error',
          'content': e.toString().contains('AI service not configured')
              ? 'AI service is not configured yet. Please contact support.'
              : 'Sorry, I encountered an error. Please try again later.',
        });
        _isLoading = false;
      });
      _scrollToBottom();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Back Button
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF333333),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Screen Title
                  const Text(
                    'Messages',
                    style: TextStyle(
                      fontFamily: 'kobe11',
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  // AI Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDFF00),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.smart_toy, color: Colors.black, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'AI',
                          style: TextStyle(
                            fontFamily: 'kobe11Bold',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Chat Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';
                  final isError = msg['role'] == 'error';

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFFEDFF00)
                            : isError
                                ? Colors.red.shade900
                                : const Color(0xFF333333),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        msg['content']!,
                        style: TextStyle(
                          fontFamily: 'kobe11',
                          color: isUser ? Colors.black : Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Loading Indicator
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(8),
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
                    const Text(
                      'AI is typing...',
                      style: TextStyle(
                        fontFamily: 'kobe11',
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            // Message Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade800),
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
                        hintText: 'Ask me anything...',
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
                      onPressed: _isLoading ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
