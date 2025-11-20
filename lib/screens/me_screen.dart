import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'my_purchases_screen.dart';
import 'notifications_screen.dart';
import 'chats_screen.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, //dark background
      body: SafeArea(
        child: Column(
          children: [
            // ─── TOP BAR: notif + chat + logo ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  // tap to go to Notifications
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.notifications_none,
                      size: 36,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  
                  // tap to go to Chats
                  Transform.translate(
                    offset: const Offset(-6, 0),
                    child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      size: 32,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatsScreen(),
                        ),
                      );
                    },
                  ),
               ),

                  const Spacer(),
                  
                  Image.asset(
                    'assets/images/logo.png',
                    color: Colors.white,
                    width: 90,
                    height: 90,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            // ─── PROFILE ROW ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 64,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Expanded(
                    child: Text(
                      'BIG SHOE JOE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // divider
            Container(height: 1, color: Colors.white24),

            // ─── "MY PURCHASES" BAND ────────────────────────────────────────
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyPurchasesScreen(),
                  ),
                );
              },
              child: Container(
                color: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Purchases',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'View Purchase History',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ─── TO PAY / TO SHIP / TO RECEIVE ROW ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _StatusIcon(
                    icon: Icons.payments_outlined,
                    label: 'To pay',
                  ),
                  _StatusIcon(
                    icon: Icons.local_shipping_outlined,
                    label: 'To Ship',
                  ),
                  _StatusIcon(
                    icon: Icons.inbox_outlined,
                    label: 'To Receive',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── WISHLIST HEADER ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              color: const Color(0xFF403636),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: const Text(
                "BIG SHOE JOE'S WISHLIST",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            // ─── WISHLIST ITEMS (SCROLLABLE) ─────────────────────────────────
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: const [
                  WishlistItem(
                    title: 'JOSHUA SHOES',
                    description:
                        'lorem ipsum\ndetails details\nskibidi rizz',
                    price: '₱420.69',
                  ),
                  SizedBox(height: 16),
                  WishlistItem(
                    title: 'JAMES SHOES',
                    description:
                        'lorem ipsum\ndetails details\nskibidi rizz',
                    price: '₱420.69',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ─── BOTTOM NAV (static, Me selected) ─────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: 2, // this screen is "Me"
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          // Navigate either to home or cart
          if (index == 0) {
            Navigator.pop(context); // go back to previous (Home in your flow)
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined, color: Colors.white),
            label: 'cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, color: Colors.white),
            label: 'Me',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small widgets used above
// ─────────────────────────────────────────────────────────────────────────────

class _StatusIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusIcon({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.white),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }
}

class WishlistItem extends StatelessWidget {
  final String title;
  final String description;
  final String price;

  const WishlistItem({
    super.key,
    required this.title,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E), // dark card background
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Shoe picture placeholder
          Container(
            width: 110,
            height: 110,
            color: Colors.grey[800],
            alignment: Alignment.center,
            child: const Text(
              'SHOE\nPIC',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Texts + button/price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),

                // PRICE + ADD TO CART (no overflow)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        alignment: Alignment.center,
                        color: Colors.grey[800],
                        child: FittedBox(
                          child: Text(
                            price,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          color: Colors.black,
                        ),
                        child: const FittedBox(
                          child: Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
