import 'package:flutter/material.dart';
import 'dart:async';
import 'cart_screen.dart';
import 'me_screen.dart';
import 'notifications_screen.dart';
import 'chats_screen.dart';

/// Main home screen widget that displays products and handles navigation
/// Features: Auto-rotating hero banner, product grid, bottom navigation, drawer menu
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ─── STATE VARIABLES ───────────────────────────────────────

  /// Tracks which bottom navigation item is currently selected (0=Home, 1=Cart, 2=Me)
  int _selectedIndex = 0;

  /// Tracks which hero banner image is currently displayed
  int _currentHeroIndex = 0;

  /// Global key to programmatically control the drawer from custom top bar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ─── DEMO DATA ─────────────────────────────────────────────

  /// Demo product list with titles, prices, and image paths
  final List<Map<String, String?>> demoProducts = [
    {
      'title': 'Joshua Shoes',
      'price': '₱69,420',
      'image': 'assets/images/prod_item.jpg',
    },
    {
      'title': 'Joshua Feet',
      'price': '₱59,300',
      'image': 'assets/images/prod_item2.jpg',
    },
    {
      'title': 'Joshua Socks',
      'price': '₱75,150',
      'image': 'assets/images/prod_item3.jpg',
    },
    {
      'title': 'Ken Crocs',
      'price': '₱82,500',
      'image': 'assets/images/prod_item4.jpg',
    },
    {
      'title': 'Orlie Slippers',
      'price': '₱45,200',
      'image': 'assets/images/prod_item5.jpg',
    },
    {
      'title': 'James Heels',
      'price': '₱90,750',
      'image': 'assets/images/prod_item6.jpg',
    },
  ];

  /// List of hero banner images that auto-rotate every 5 seconds
  final List<String> _heroImages = [
    'assets/images/feature_test.jpg',
    'assets/images/feature_test2.jpg',
    'assets/images/feature_test3.jpg',
  ];

  // ─── NAVIGATION LOGIC ──────────────────────────────────────

  /// Handles bottom navigation bar tap events
  /// Navigates to Cart (index 1) or Me (index 2) screens
  /// Home (index 0) stays on current screen
  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);

    if (index == 1) {
      // Navigate to Cart Screen
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
    } else if (index == 2) {
      // Navigate to Me/Profile Screen
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const MeScreen()));
    }
    // index 0 = Home, stay on current screen
  }

  // ─── HERO BANNER AUTO-ROTATION ─────────────────────────────

  /// Timer that controls hero banner auto-rotation
  Timer? _heroTimer;

  @override
  void initState() {
    super.initState();
    _startHeroTimer();
  }

  /// Starts a periodic timer that cycles through hero images every 5 seconds
  void _startHeroTimer() {
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        // Cycle to next image, wrap around to 0 after last image
        _currentHeroIndex = (_currentHeroIndex + 1) % _heroImages.length;
      });
    });
  }

  @override
  void dispose() {
    // Cancel timer to prevent memory leaks
    _heroTimer?.cancel();
    super.dispose();
  }

  // ─── UI BUILD ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: null, // Using custom top bar instead of AppBar
      // ─── DRAWER MENU ───────────────────────────────────────────────
      drawer: Drawer(
        backgroundColor: const Color(0xFF000000),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Custom drawer header with back button
            Container(
              height: 60,
              decoration: const BoxDecoration(color: Color(0xFFEDFF00)),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    splashColor: Colors.white24,
                    highlightColor: Colors.white12,
                    onPressed: () {
                      Navigator.of(context).pop(); // Close drawer
                    },
                  ),
                  const Text(
                    'Csoles Connect',
                    style: TextStyle(
                      fontFamily: 'kobe11Bold',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Notifications menu item
            InkWell(
              onTap: () {
                Navigator.of(context).pop(); // Close drawer first
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

            // Messages/Chatbox menu item
            InkWell(
              onTap: () {
                Navigator.of(context).pop(); // Close drawer first
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

            // Logout menu item (placeholder functionality)
            InkWell(
              onTap: () {
                // Should clear user session, tokens, and navigate to login
                debugPrint("Pressed the Log out!");
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

      // ─── MAIN BODY ─────────────────────────────────────────────
      body: SafeArea(
        child: Column(
          children: [
            // ─── CUSTOM TOP BAR ────────────────────────────────
            Container(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    // Menu button to open drawer
                    IconButton(
                      splashColor: Colors.white24,
                      highlightColor: Colors.white12,
                      icon: const Icon(
                        Icons.menu,
                        size: 28,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                    const Spacer(),
                    // App logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 56,
                        height: 40,
                        fit: BoxFit.cover,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── SCROLLABLE CONTENT ────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ─── HERO BANNER AREA ──────────────────────
                    // Auto-rotating promotional banner (changes every 5 seconds)
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.33, // 33% of screen height
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 1000),
                        child: ClipRRect(
                          key: ValueKey(_currentHeroIndex), // Key for animation
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            _heroImages[_currentHeroIndex],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            // Fallback if image fails to load
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey,
                              child: const Center(
                                child: Text(
                                  'video/pic showcasing\n   goods',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'kobe11',
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ─── SLOGAN BAND ───────────────────────────
                    Container(
                      color: Colors.black,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Center(
                        child: Text(
                          '"your shoes, our shoes"',
                          style: TextStyle(
                            fontFamily: 'kobe11Bold',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // ─── PRODUCT GRID ──────────────────────────
                    // 2-column grid displaying all products
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 14.0,
                      ),
                      child: GridView.builder(
                        shrinkWrap: true, // Let grid size itself
                        physics:
                            const NeverScrollableScrollPhysics(), // Disable grid scroll
                        itemCount: demoProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2 columns
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 20,
                              childAspectRatio: 0.72, // Card height ratio
                            ),
                        itemBuilder: (context, index) {
                          final product = demoProducts[index];
                          return ProductCard(
                            title: product['title'] ?? '',
                            price: product['price'] ?? '',
                            imageUrl: product['image'],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ─── BOTTOM NAVIGATION BAR ─────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined, color: Colors.white),
            label: 'Cart',
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

// ═══════════════════════════════════════════════════════════════
// PRODUCT CARD WIDGET
// ═══════════════════════════════════════════════════════════════

/// Reusable product card widget displayed in the home screen grid
/// Shows product image, title, and price
class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String? imageUrl;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(6),
              ),
              child: imageUrl == null
                  ? const Center(
                      child: Text(
                        'pic',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'kobe11',
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(imageUrl!, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          // Product title
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'kobe11Bold',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          // Product price
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontFamily: 'kobe11',
            ),
          ),
        ],
      ),
    );
  }
}
