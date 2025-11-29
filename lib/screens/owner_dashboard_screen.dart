import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'me_screen.dart';
import 'notifications_screen.dart';
import 'chats_screen.dart';
import 'products_management_screen.dart';
import 'manage_orders_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Tracks user authentication status
  bool _isLoggedIn = false; // TODO: Replace with actual auth state management

  @override
  void initState() {
    super.initState();
    _checkAuthStatus(); // Check login status on init
  }

  /// Check user authentication status
  /// TODO: Replace with actual auth state check (e.g., from SharedPreferences, Provider, etc.)
  void _checkAuthStatus() {
    // Example: Check if user token exists
    // final prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   _isLoggedIn = prefs.getString('user_token') != null;
    // });

    setState(() {
      _isLoggedIn = false; // Default to logged out
    });
  }

  /// Handle user login
  void _handleLogin() {
    // Navigate to login screen
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const LoginScreen()))
        .then((result) {
          // If login was successful, update state
          if (result == true) {
            setState(() => _isLoggedIn = true);
          }
        });
  }

  /// Handle user logout
  void _handleLogout() {
    // Show confirmation dialog before logout
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontFamily: 'kobe11',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontFamily: 'kobe11', color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFEDFF00)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog

              // Clear session data
              // TODO: Clear SharedPreferences, tokens, etc.
              // Example:
              // final prefs = await SharedPreferences.getInstance();
              // await prefs.clear();

              setState(() => _isLoggedIn = false);

              // Navigate to login screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );

              debugPrint("User logged out");
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Calculate card width to fit 2 columns with consistent padding
    final cardWidth = (width - 16 * 3) / 2;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black, // Dark theme background
      // ─── DRAWER NAVIGATION ─────────────────────────────────────────────────
      // Side menu accessible via the hamburger icon in the top bar
      drawer: Drawer(
        backgroundColor: const Color(0xFF000000),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header: Contains the back button and app branding
            Container(
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFEDFF00),
              ), // Brand accent color
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    splashColor: Colors.white24,
                    highlightColor: Colors.white12,
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the drawer
                    },
                  ),
                  const Text(
                    'Csoles Connect',
                    style: TextStyle(
                      fontFamily: 'kobe11',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Item: Notifications
            InkWell(
              onTap: () {
                Navigator.of(context).pop(); // Close drawer before navigating
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
              },
              child: const ListTile(
                leading: Icon(Icons.notifications_none, color: Colors.white),
                title: Text(
                  "Notifications",
                  style: TextStyle(fontFamily: 'kobe11', color: Colors.white),
                ),
              ),
            ),

            // Navigation Item: Messages
            InkWell(
              onTap: () {
                Navigator.of(context).pop(); // Close drawer before navigating
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ChatsScreen()));
              },
              child: const ListTile(
                leading: Icon(Icons.chat_bubble_outline, color: Colors.white),
                title: Text(
                  "Messages",
                  style: TextStyle(fontFamily: 'kobe11', color: Colors.white),
                ),
              ),
            ),

            // Logout menu item
            InkWell(
              onTap: () {
                Navigator.of(context).pop(); // Close drawer first
                _handleLogout();
              },
              child: const ListTile(
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text(
                  "Logout",
                  style: TextStyle(fontFamily: 'kobe11', color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),

      // ─── MAIN BODY CONTENT ─────────────────────────────────────────────────
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Contains the Menu trigger and Page Title
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Hamburger Menu Button
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  const SizedBox(width: 8),

                  // Page Title
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'kobe11',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),

                  // Brand Logo
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

            // ─── DASHBOARD METRICS GRID ──────────────────────────────────────
            // A responsive grid of cards displaying key statistics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 16, // Horizontal space between cards
                runSpacing: 16, // Vertical space between rows
                children: [
                  // Products Card: Links to Product Management
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProductsManagementScreen(),
                        ),
                      );
                    },
                    child: DashboardCard(
                      width: cardWidth,
                      title: 'Products',
                      count: '6', // Dynamic count placeholder
                      icon: Icons.bookmark_border,
                    ),
                  ),

                  // Users Card: Displays user count
                  InkWell(
                    child: DashboardCard(
                      width: cardWidth,
                      title: 'Users',
                      count: '8', // Dynamic count placeholder
                      icon: Icons.person_outline,
                    ),
                  ),

                  // Orders Card: Displays active order count
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ManageOrdersScreen(),
                        ),
                      );
                    },
                    child: DashboardCard(
                      width: cardWidth,
                      title: 'Orders',
                      count: '12', // Dynamic count placeholder
                      icon: Icons.inventory_2_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ─── BOTTOM NAVIGATION BAR ─────────────────────────────────────────────
      // Provides navigation between Dashboard (Home) and Profile
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: 0, // Dashboard acts as the primary 'Home' view here
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
            // Navigate to Consumer Home Screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (index == 1) {
            // Navigate to Profile Screen
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

// ─── REUSABLE WIDGETS ──────────────────────────────────────────────────────

// A unified card widget for displaying dashboard statistics
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
          color: const Color(0xFF1E1E1E), // Card background
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'kobe11',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            // Central Icon
            Center(child: Icon(icon, size: 48, color: Colors.white)),
            const Spacer(),
            // Metric Count
            Center(
              child: Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'kobe11',
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
