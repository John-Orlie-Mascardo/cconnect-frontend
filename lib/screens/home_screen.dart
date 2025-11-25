import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'dart:async';
import 'cart_screen.dart';
import 'me_screen.dart';
import 'notifications_screen.dart';
import 'chats_screen.dart';
import 'product_detail_screen.dart';
import 'login_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ─── STATE VARIABLES ───────────────────────────────────────

  int _selectedIndex = 0;
  int _currentHeroIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Tracks user authentication status
  bool _isLoggedIn = false; 

  // ─── DEMO DATA ─────────────────────────────────────────────
  final List<Map<String, String?>> demoProducts = [
    {'title': 'Joshua Shoes', 'price': '₱69,420', 'image': 'assets/images/prod_item.jpg'},
    {'title': 'Joshua Feet', 'price': '₱59,300', 'image': 'assets/images/prod_item2.jpg'},
    {'title': 'Joshua Socks', 'price': '₱75,150', 'image': 'assets/images/prod_item3.jpg'},
    {'title': 'Ken Crocs', 'price': '₱82,500', 'image': 'assets/images/prod_item4.jpg'},
    {'title': 'Orlie Slippers', 'price': '₱45,200', 'image': 'assets/images/prod_item5.jpg'},
    {'title': 'James Heels', 'price': '₱90,750', 'image': 'assets/images/prod_item6.jpg'},
  ];

  final List<String> _heroImages = [
    'assets/images/feature_test.jpg',
    'assets/images/feature_test2.jpg',
    'assets/images/feature_test3.jpg',
  ];

  // ─── NAVIGATION LOGIC ──────────────────────────────────────

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);

    if (index == 1) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen()));
    } else if (index == 2) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MeScreen()));
    }
  }

  void _navigateToProductDetail(Map<String, String?> product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          productTitle: product['title'] ?? 'Product',
          productPrice: product['price'] ?? '₱0',
          productImage: product['image'],
        ),
      ),
    );
  }

  // ─── HERO BANNER AUTO-ROTATION ─────────────────────────────

  Timer? _heroTimer;

  @override
  void initState() {
    super.initState();
    _startHeroTimer();
    _checkAuthStatus(); // Check login status immediately on load
  }

  /// REAL AUTH CHECK: Checks if a Firebase user is currently signed in
  void _checkAuthStatus() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _isLoggedIn = user != null;
    });
  }

  /// Handle user login
  void _handleLogin() {
    // Navigate to login screen
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    ).then((_) {
      // When we come BACK from the login screen (e.g. user logged in or pressed back),
      // we re-check the status to update the UI.
      _checkAuthStatus();
    });
  }

  /// Handle user logout
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Logout',
          style: TextStyle(fontFamily: 'kobe11Bold', color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontFamily: 'kobe11', color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFEDFF00))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              // 1. Sign out from Firebase
              await FirebaseAuth.instance.signOut();
              
              // 2. Update UI state
              setState(() => _isLoggedIn = false);
              
              // 3. Option A: Navigate to Login Screen immediately
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
              
              // Option B: If you prefer to stay on Home but show "Login" button,
              // remove the Navigator block above.
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _startHeroTimer() {
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentHeroIndex = (_currentHeroIndex + 1) % _heroImages.length;
        });
      }
    });
  }

  @override
  void dispose() {
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
      appBar: null,
      
      // ─── DRAWER MENU ───────────────────────────────────────────────
      drawer: Drawer(
        backgroundColor: const Color(0xFF000000),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Custom drawer header
            Container(
              height: 60,
              decoration: const BoxDecoration(color: Color(0xFFEDFF00)),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
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

            // Notifications
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
              },
              child: const ListTile(
                leading: Icon(Icons.notifications_none, color: Colors.white),
                title: Text("Notifications", style: TextStyle(fontFamily: 'kobe11', color: Colors.white)),
              ),
            ),

            // Messages
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatsScreen()));
              },
              child: const ListTile(
                leading: Icon(Icons.chat_bubble_outline, color: Colors.white),
                title: Text("Messages", style: TextStyle(fontFamily: 'kobe11', color: Colors.white)),
              ),
            ),

            // ─── DYNAMIC LOGIN / LOGOUT ITEM ───────────────────
            InkWell(
              onTap: () {
                Navigator.of(context).pop(); // Close drawer
                
                if (_isLoggedIn) {
                  // If logged in -> Action is LOGOUT
                  _handleLogout();
                } else {
                  // If NOT logged in -> Action is LOGIN
                  _handleLogin();
                }
              },
              child: ListTile(
                leading: Icon(
                  _isLoggedIn ? Icons.logout : Icons.login, // Icon changes based on state
                  color: Colors.white,
                ),
                title: Text(
                  _isLoggedIn ? "Logout" : "Login", // Text changes based on state
                  style: const TextStyle(
                    fontFamily: 'kobe11',
                    color: Colors.white,
                  ),
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
            // Top Bar
            Container(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, size: 28, color: Colors.white),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const Spacer(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 56, height: 40, fit: BoxFit.cover, color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Hero Banner
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.33,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 1000),
                        child: ClipRRect(
                          key: ValueKey(_currentHeroIndex),
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            _heroImages[_currentHeroIndex],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey,
                              child: const Center(child: Text('video/pic showcasing\n   goods', textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Slogan
                    Container(
                      color: Colors.black,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Center(
                        child: Text('"your shoes, our shoes"', style: TextStyle(fontFamily: 'kobe11Bold', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      ),
                    ),

                    // Product Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: demoProducts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (context, index) {
                          final product = demoProducts[index];
                          return ProductCard(
                            title: product['title'] ?? '',
                            price: product['price'] ?? '',
                            imageUrl: product['image'],
                            onTap: () => _navigateToProductDetail(product),
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

      // Bottom Nav
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Me'),
        ],
      ),
    );
  }
}

// ─── PRODUCT CARD WIDGET ─────────────────────────────────────
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
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(6)),
              child: imageUrl == null
                  ? const Center(child: Text('pic', style: TextStyle(color: Colors.white)))
                  : ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.asset(imageUrl!, fit: BoxFit.cover)),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontFamily: 'kobe11Bold', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          Text(price, style: const TextStyle(fontSize: 14, color: Colors.white70, fontFamily: 'kobe11')),
        ],
      ),
    );
  }
}