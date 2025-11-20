import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'me_screen.dart';
import 'notifications_screen.dart';
import 'chats_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // card width so that 2 fit in a row with padding
    final cardWidth = (width - 16 * 3) / 2;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,

      // ─── DRAWER (same behavior as HomeScreen) ─────────────────────
      drawer: Drawer(
        backgroundColor: const Color(0xFF000000),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFEDFF00),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    splashColor: Colors.white24,
                    highlightColor: Colors.white12,
                    onPressed: () {
                      Navigator.of(context).pop(); // close drawer
                    },
                  ),
                  const Text(
                    'Csoles Connect',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Notifications tile → NotificationScreen
            InkWell(
              onTap: () {
                Navigator.of(context).pop(); // close drawer first
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationScreen(),
                  ),
                );
              },
              child: const ListTile(
                leading: Icon(Icons.notifications_none, color: Colors.white),
                title: Text(
                  "Notifications",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            // Messages tile → ChatsScreen
            InkWell(
              onTap: () {
                Navigator.of(context).pop(); // close drawer first
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ChatsScreen(),
                  ),
                );
              },
              child: const ListTile(
                leading: Icon(Icons.chat_bubble_outline, color: Colors.white),
                title: Text(
                  "Messages",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            // Logout (placeholder)
            InkWell(
              onTap: () {
                debugPrint("Pressed the Log out!");
              },
              child: const ListTile(
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),

      // ─── BODY ──────────────────────────────────────────────────────
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  // logo
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

            const SizedBox(height: 16),

            // DASHBOARD CARDS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  DashboardCard(
                    width: cardWidth,
                    title: 'Products',
                    count: '6',
                    icon: Icons.bookmark_border,
                  ),
                  DashboardCard(
                    width: cardWidth,
                    title: 'Users',
                    count: '8',
                    icon: Icons.person_outline,
                  ),
                  DashboardCard(
                    width: cardWidth,
                    title: 'Orders',
                    count: '12',
                    icon: Icons.inventory_2_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ─── BOTTOM NAV (Home / Me) ───────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: 0, // Dashboard is acting as "Home" here
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, color: Colors.white),
            label: 'Me',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // Go to HomeScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (index == 1) {
            // Go to MeScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MeScreen()),
            );
          }
        },
      ),
    );
  }
}

// ─── REUSABLE DASHBOARD CARD ───────────────────────────────────────

class DashboardCard extends StatelessWidget {
  final double width;
  final String title;
  final String count;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.width,
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 150,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            // icon
            Center(
              child: Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            // count
            Center(
              child: Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
