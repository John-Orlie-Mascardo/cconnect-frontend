import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'dart:async';
import 'cart_screen.dart';
import 'me_screen.dart';
import 'notifications_screen.dart';
import 'chats_screen.dart';
import 'product_detail_screen.dart';
import 'owner_dashboard_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/product_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../utils/price_formatter.dart';

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
  String? _userRole;
  bool _hasUnreadNotifications = false;

  // ─── PRODUCT DATA ─────────────────────────────────────────────
  List<Product> products = [];
  bool _isLoadingProducts = true;

  final List<String> _heroImages = [
    'assets/images/feature_test.jpg',
    'assets/images/feature_test2.jpg',
    'assets/images/feature_test3.jpg',
  ];

  // ─── NAVIGATION LOGIC ──────────────────────────────────────

  Future<void> _onNavTap(int index) async {
    setState(() => _selectedIndex = index);

    if (index == 1) {
      // navigate to Dashboard if admin, Cart otherwise
      if (_userRole == 'admin') {
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const DashboardScreen()));
      } else {
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
      }
      if (mounted) setState(() => _selectedIndex = 0);
    } else if (index == 2) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const MeScreen()));
      if (mounted) setState(() => _selectedIndex = 0);
    }
  }

  void _navigateToProductDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }

  // ─── HERO BANNER AUTO-ROTATION ─────────────────────────────

  Timer? _heroTimer;

  @override
  void initState() {
    super.initState();
    _startHeroTimer();
    _checkAuthStatus(); // Check login status immediately on load
    _loadProducts(); // Load products from API
    _checkUnreadNotifications();
  }

  Future<void> _checkUnreadNotifications() async {
    if (!_isLoggedIn) {
      setState(() => _hasUnreadNotifications = false);
      return;
    }
    
    try {
      final notifications = await NotificationService.getNotifications();
      if (mounted) {
        setState(() {
          _hasUnreadNotifications = notifications.any((n) => !n.read);
        });
      }
    } catch (e) {
      print('Error checking notifications: $e');
      if (mounted) {
        setState(() => _hasUnreadNotifications = false);
      }
    }
  }

  /// Load products from the API
  Future<void> _loadProducts() async {
    try {
      setState(() => _isLoadingProducts = true);
      final fetchedProducts = await ProductService.getProducts();
      if (mounted) {
        setState(() {
          products = fetchedProducts;
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      print('Error loading products: $e');
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  /// REAL AUTH CHECK: Checks if a Firebase user is currently signed in
  Future<void> _checkAuthStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    final role = await AuthService.getRole(); // gets user role if any
    setState(() {
      _isLoggedIn = user != null;
      _userRole = role; // sets user state to admin
      // Reset notification badge when user changes
      if (!_isLoggedIn) {
        _hasUnreadNotifications = false;
      }
    });
    
    // Check notifications only if logged in
    if (_isLoggedIn) {
      _checkUnreadNotifications();
    }
  }

  /// Handle user login
  void _handleLogin() {
    // Navigate to login screen
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginScreen())).then((_) {
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
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFEDFF00)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // 1. Sign out from Firebase
              await FirebaseAuth.instance.signOut();

              // 2. Update UI state
              setState(() {
                _isLoggedIn = false;
                _hasUnreadNotifications = false; // Reset notification badge
              });

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

            // Notifications & Messages (VISIBLE ONLY WHEN LOGGED IN)
            if (_isLoggedIn) ...[
              InkWell(
                onTap: () async {
                  Navigator.of(context).pop();
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                  // Refresh notification status after returning
                  _checkUnreadNotifications();
                },
                child: ListTile(
                  leading: Stack(
                    children: [
                      const Icon(Icons.notifications_none, color: Colors.white),
                      if (_hasUnreadNotifications)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEDFF00),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: const Text(
                    "Notifications",
                    style: TextStyle(fontFamily: 'kobe11', color: Colors.white),
                  ),
                ),
              ),

              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChatsScreen()),
                  );
                },
                child: const ListTile(
                  leading: Icon(Icons.chat_bubble_outline, color: Colors.white),
                  title: Text(
                    "Messages",
                    style: TextStyle(fontFamily: 'kobe11', color: Colors.white),
                  ),
                ),
              ),
            ],

            // ─── USER SETTINGS (VISIBLE ONLY WHEN LOGGED IN) ───
            if (_isLoggedIn) ...[
              const Divider(color: Colors.white24),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Text(
                  "User Settings",
                  style: TextStyle(
                    fontFamily: 'kobe11Bold',
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                child: const ListTile(
                  leading: Icon(Icons.settings_outlined, color: Colors.white),
                  title: Text(
                    "Account Settings",
                    style: TextStyle(fontFamily: 'kobe11', color: Colors.white),
                  ),
                ),
              ),
            ],

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
                  _isLoggedIn
                      ? Icons.logout
                      : Icons.login, // Icon changes based on state
                  color: Colors.white,
                ),
                title: Text(
                  _isLoggedIn
                      ? "Logout"
                      : "Login", // Text changes based on state
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.menu,
                            size: 28,
                            color: Colors.white,
                          ),
                          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                        ),
                        if (_hasUnreadNotifications && _isLoggedIn)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEDFF00),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
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
                              child: const Center(
                                child: Text(
                                  'video/pic showcasing\n   goods',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
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

                    // Product Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 14.0,
                      ),
                      child: _isLoadingProducts
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(
                                  color: Color(0xFFEDFF00),
                                ),
                              ),
                            )
                          : products.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text(
                                  'No products available',
                                  style: TextStyle(
                                    fontFamily: 'kobe11',
                                    color: Colors.grey[400],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: products.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 20,
                                    childAspectRatio: 0.72,
                                  ),
                              itemBuilder: (context, index) {
                                final product = products[index];
                                // Construct image URL properly
                                String? imageUrl;
                                if (product.image != null) {
                                  // Ensure there's a slash between base URL and path
                                  final imagePath =
                                      product.image!.startsWith('/')
                                      ? product.image!
                                      : '/${product.image!}';
                                  imageUrl = 'http://localhost:3000$imagePath';
                                }

                                return ProductCard(
                                  title: product.name,
                                  price: PriceFormatter.format(product.price),
                                  imageUrl: imageUrl,
                                  onTap: () =>
                                      _navigateToProductDetail(product),
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
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        items: [
          // ← Remove 'const' here
          const BottomNavigationBarItem(
            // ← Keep const on individual items that don't change
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            // ← No const here - it's dynamic
            icon: Icon(
              _userRole == 'admin'
                  ? Icons.dashboard_outlined
                  : Icons.shopping_cart_outlined,
            ),
            label: _userRole == 'admin' ? 'Dashboard' : 'Cart',
          ),
          const BottomNavigationBarItem(
            // ← Keep const on static items
            icon: Icon(Icons.person_outline),
            label: 'Me',
          ),
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
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(6),
              ),
              child: imageUrl == null
                  ? const Center(
                      child: Text('pic', style: TextStyle(color: Colors.white)),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: imageUrl!.startsWith('http')
                          ? Image(
                              image: NetworkImage(imageUrl!),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                        color: const Color(0xFFEDFF00),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                print('Image load error: $error');
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.white54,
                                      size: 40,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Image.asset(imageUrl!, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'kobe11Bold',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
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
