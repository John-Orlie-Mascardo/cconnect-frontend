import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'cart_screen.dart';
import 'me_screen.dart';
import 'home_screen.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await NotificationService.getNotifications();
      
      // Mark all unread notifications as read
      final unreadNotifications = notifications.where((n) => !n.read).toList();
      for (var notification in unreadNotifications) {
        await NotificationService.markAsRead(notification.id);
      }
      
      // Update local state with all notifications marked as read
      if (mounted) {
        setState(() {
          _notifications = notifications.map((n) {
            return NotificationModel(
              id: n.id,
              title: n.title,
              message: n.message,
              type: n.type,
              read: true, // Mark all as read in UI
              createdAt: n.createdAt,
            );
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.read) return;

    // Optimistic update
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          read: true,
          createdAt: notification.createdAt,
        );
      }
    });

    await NotificationService.markAsRead(notification.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme background
      body: SafeArea(
        child: Column(
          children: [
            // ─── HEADER SECTION ────────────────────────────────────────────────
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'kobe11',
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ─── SECTION HEADER ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: const Color(0xFF303030),
              child: const Center(
                child: Text(
                  'Recent Updates',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'kobe11',
                    fontSize: 20,
                  ),
                ),
              ),
            ),

            // ─── MAIN CONTENT ──────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFEDFF00),
                      ),
                    )
                  : _notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.notifications_off_outlined,
                                size: 80,
                                color: Colors.white24,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No notifications yet',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontFamily: 'kobe11',
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: SizedBox(
                                  height: 60,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(0xFF202020),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'SHOP NOW',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'kobe11',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadNotifications,
                          color: const Color(0xFFEDFF00),
                          backgroundColor: Colors.grey[900],
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              return Dismissible(
                                key: Key(notification.id),
                                background: Container(color: Colors.red),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  // TODO: Implement delete
                                },
                                child: InkWell(
                                  onTap: () => _markAsRead(notification),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: notification.read
                                          ? Colors.black
                                          : const Color(0xFF1E1E1E),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: notification.read
                                            ? Colors.grey[900]!
                                            : const Color(0xFFEDFF00),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          notification.type == 'admin_alert'
                                              ? Icons.admin_panel_settings
                                              : Icons.local_shipping,
                                          color: notification.read
                                              ? Colors.grey
                                              : const Color(0xFFEDFF00),
                                          size: 24,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      notification.title,
                                                      style: TextStyle(
                                                        color: notification.read
                                                            ? Colors.white70
                                                            : Colors.white,
                                                        fontFamily: 'kobe11Bold',
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    _formatDate(
                                                        notification.createdAt),
                                                    style: const TextStyle(
                                                      color: Colors.white38,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                notification.message,
                                                style: TextStyle(
                                                  color: notification.read
                                                      ? Colors.white54
                                                      : Colors.white70,
                                                  fontFamily: 'kobe11',
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MeScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Me',
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
