import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import 'admin_chat_detail_screen.dart';
import 'package:intl/intl.dart';

/// Admin screen to view all customer conversations
class AdminConversationsScreen extends StatefulWidget {
  const AdminConversationsScreen({super.key});

  @override
  State<AdminConversationsScreen> createState() =>
      _AdminConversationsScreenState();
}

class _AdminConversationsScreenState extends State<AdminConversationsScreen> {
  List<dynamic> conversations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => isLoading = true);

    final loadedConversations = await ChatService.getAllConversations();

    if (mounted) {
      setState(() {
        conversations = loadedConversations;
        isLoading = false;
      });
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return DateFormat('MMM d').format(dateTime);
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Customer Conversations',
          style: TextStyle(
            fontFamily: 'kobe11Bold',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadConversations,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFEDFF00),
              ),
            )
          : conversations.isEmpty
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
                        'No conversations yet',
                        style: TextStyle(
                          fontFamily: 'kobe11',
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Customer chats will appear here',
                        style: TextStyle(
                          fontFamily: 'kobe11',
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFFEDFF00),
                  backgroundColor: Colors.grey[900],
                  onRefresh: _loadConversations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      final customer = conversation['customerId'];
                      final customerName = customer is Map
                          ? (customer['name'] ?? 'Unknown User')
                          : 'Unknown User';
                      final customerEmail = customer is Map
                          ? (customer['email'] ?? '')
                          : '';
                      final lastMessage = conversation['lastMessage'] ?? '';
                      final lastMessageTime =
                          conversation['lastMessageTime'];
                      final unreadCount =
                          conversation['adminUnreadCount'] ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: unreadCount > 0
                              ? Border.all(
                                  color: const Color(0xFFEDFF00),
                                  width: 2,
                                )
                              : null,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDFF00),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                customerName.isNotEmpty
                                    ? customerName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontFamily: 'kobe11Bold',
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  customerName,
                                  style: const TextStyle(
                                    fontFamily: 'kobe11Bold',
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (unreadCount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDFF00),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    unreadCount.toString(),
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
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (customerEmail.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    customerEmail,
                                    style: TextStyle(
                                      fontFamily: 'kobe11',
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      lastMessage.isNotEmpty
                                          ? lastMessage
                                          : 'No messages yet',
                                      style: TextStyle(
                                        fontFamily: 'kobe11',
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatTime(lastMessageTime),
                                    style: TextStyle(
                                      fontFamily: 'kobe11',
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminChatDetailScreen(
                                  conversationId: conversation['_id'],
                                  customerName: customerName,
                                  customerEmail: customerEmail,
                                ),
                              ),
                            ).then((_) => _loadConversations());
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
