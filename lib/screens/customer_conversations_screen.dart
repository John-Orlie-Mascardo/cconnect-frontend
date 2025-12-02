import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'package:intl/intl.dart';
import 'realtime_chat_screen.dart';
import 'chats_screen.dart';

/// Customer conversations list screen showing AI chat and Store Owner chat
class CustomerConversationsScreen extends StatefulWidget {
  const CustomerConversationsScreen({super.key});

  @override
  State<CustomerConversationsScreen> createState() =>
      _CustomerConversationsScreenState();
}

class _CustomerConversationsScreenState
    extends State<CustomerConversationsScreen> {
  Map<String, dynamic>? ownerConversation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOwnerConversation();
  }

  Future<void> _loadOwnerConversation() async {
    setState(() => isLoading = true);

    final data = await ChatService.getOrCreateConversation();

    if (mounted && data != null) {
      setState(() {
        ownerConversation = data['conversation'];
        isLoading = false;
      });
    } else if (mounted) {
      setState(() => isLoading = false);
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
          'Messages',
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
            onPressed: _loadOwnerConversation,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFEDFF00)),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // AI Chat Option
                _buildChatTile(
                  icon: Icons.smart_toy,
                  title: 'AI Assistant',
                  subtitle: 'Get instant help and answers',
                  badge: 'AI',
                  badgeColor: const Color(0xFFEDFF00),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatsScreen()),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Store Owner Chat
                _buildChatTile(
                  icon: Icons.store,
                  title: 'Store Owner',
                  subtitle:
                      ownerConversation?['lastMessage'] ??
                      'Start a conversation',
                  timestamp: ownerConversation?['lastMessageTime'],
                  unreadCount: ownerConversation?['customerUnreadCount'] ?? 0,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RealtimeChatScreen(),
                      ),
                    ).then((_) => _loadOwnerConversation());
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildChatTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    String? timestamp,
    int unreadCount = 0,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: unreadCount > 0
            ? Border.all(color: const Color(0xFFEDFF00), width: 2)
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
            color: badgeColor ?? const Color(0xFFEDFF00),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: Colors.black, size: 28),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'kobe11Bold',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor ?? const Color(0xFFEDFF00),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontFamily: 'kobe11Bold',
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'kobe11',
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (timestamp != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  _formatTime(timestamp),
                  style: TextStyle(
                    fontFamily: 'kobe11',
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
