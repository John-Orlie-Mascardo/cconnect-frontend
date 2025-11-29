import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'my_purchases_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../services/wishlist_service.dart';
import '../services/cart_manager.dart';
import 'products_management_screen.dart';
import '../utils/price_formatter.dart';
import '../services/user_service.dart';
import 'owner_dashboard_screen.dart';

class MeScreen extends StatefulWidget {
  const MeScreen({super.key});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  List<Map<String, dynamic>> _wishlistItems = [];
  bool _isLoadingWishlist = true;
  String _userName = 'BIG SHOE JOE'; // Default/Fallback name
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
    _loadUserProfile();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await AuthService.getRole();
    if (mounted) {
      setState(() {
        _userRole = role;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    final result = await UserService.getProfile();
    if (mounted && result['success'] == true) {
      final data = result['data'];
      setState(() {
        _userName = (data['name'] as String?)?.isNotEmpty == true 
            ? data['name'] 
            : 'BIG SHOE JOE';
      });
    }
  }

  Future<void> _loadWishlist() async {
    setState(() => _isLoadingWishlist = true);
    final items = await WishlistService.getWishlist();
    if (mounted) {
      setState(() {
        _wishlistItems = items;
        _isLoadingWishlist = false;
      });
    }
  }

  Future<void> _removeFromWishlist(String productId) async {
    final success = await WishlistService.removeFromWishlist(productId);
    if (success) {
      _loadWishlist(); // Reload wishlist
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from wishlist'),
            backgroundColor: Color(0xFFEDFF00),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove from wishlist'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _addToCart(Map<String, dynamic> item) async {
    final success = await CartManager.instance.addItem({
      'title': item['title'],
      'price': item['price'],
      'image': item['image'],
      'productId': item['productId'],
      'quantity': 1,
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to cart'),
          backgroundColor: Color(0xFFEDFF00),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add to cart'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme background
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // If waiting for auth state, show a loading indicator
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // If user is NOT logged in, show Login UI
            if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_circle_outlined,
                      size: 100,
                      color: Colors.white70,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'You are not logged in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'kobe11',
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Login / Register',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // If user IS logged in, show the profile content
            return FutureBuilder<String?>(
              future: AuthService.getRole(),
              builder: (context, roleSnapshot) {
                final role = roleSnapshot.data;
                
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // ─── TOP BAR NAVIGATION & BRANDING ────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () =>
                                  Navigator.pushReplacementNamed(context, '/home'),
                              borderRadius: BorderRadius.circular(40),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(shape: BoxShape.circle),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Spacer(),

                            // Brand Logo: Displayed on the far right of the top bar
                            Image.asset(
                              'assets/images/logo.png',
                              color: Colors.white,
                              width: 90,
                              height: 90,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const SizedBox(),
                            ),
                          ],
                        ),
                      ),

                      // ─── SCROLLABLE CONTENT ───────────────────────────────────────────
                      // ─── USER PROFILE HEADER ──────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            // User Avatar: Circular placeholder for profile image
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
                            // User Name: Displays the current user's display name
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userName.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'kobe11',
                                      fontSize: 26,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  if (role == 'admin')
                                    Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEDFF00),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'ADMIN',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Visual Divider
                      Container(height: 1, color: Colors.white24),
                      
                      // ─── ADMIN SECTION ────────────────────────────────────────
                      if (role == 'admin')
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProductsManagementScreen(),
                              ),
                            );
                          },
                          child: Container(
                            color: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.admin_panel_settings, color: Color(0xFFEDFF00)),
                                SizedBox(width: 16),
                                Text(
                                  'Manage Products',
                                  style: TextStyle(
                                    fontFamily: 'kobe11',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFEDFF00),
                                  ),
                                ),
                                Spacer(),
                                Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                              ],
                            ),
                          ),
                        ),
                        
                      if (role == 'admin')
                        Container(height: 1, color: Colors.white24),

                      // ─── PURCHASE HISTORY LINK ────────────────────────────────
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'My Purchases',
                                style: TextStyle(
                                  fontFamily: 'kobe11',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'View Purchase History',
                                style: TextStyle(
                                  fontFamily: 'kobe11',
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ─── ORDER STATUS ICONS ───────────────────────────────────
                      // Quick access to orders in different states
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

                      // ─── WISHLIST SECTION ─────────────────────────────────────

                      // Wishlist Header Label
                      Container(
                        width: double.infinity,
                        color: const Color(0xFF403636),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Text(
                          "${_userName.toUpperCase()}'S WISHLIST",
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'kobe11',
                            fontSize: 18,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      // Wishlist Items List: Scrollable area for saved items
                      _isLoadingWishlist
                          ? const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFEDFF00),
                                ),
                              ),
                            )
                          : _wishlistItems.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Center(
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.favorite_border,
                                          size: 64,
                                          color: Colors.white24,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Your wishlist is empty',
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontFamily: 'kobe11',
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  itemCount: _wishlistItems.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final item = _wishlistItems[index];
                                    return WishlistItem(
                                      title: item['title'] ?? 'Product',
                                      description: item['description'] ??
                                          'No description available',
                                      price: PriceFormatter.format(
                                        item['price'] ?? 0,
                                      ),
                                      imageUrl: item['image'],
                                      onAddToCart: () => _addToCart(item),
                                      onRemove: () => _removeFromWishlist(
                                        item['productId'],
                                      ),
                                    );
                                  },
                                ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),

      // ─── BOTTOM NAVIGATION BAR ────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: 2, // Indicates "Me" tab is currently selected
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            if (_userRole == 'admin') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            }
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _userRole == 'admin'
                  ? Icons.dashboard_outlined
                  : Icons.shopping_cart_outlined,
            ),
            label: _userRole == 'admin' ? 'Dashboard' : 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Me',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

// A helper widget to render a status icon (e.g., To Pay) with a label below it
class _StatusIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.white),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'kobe11',
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

// A reusable card widget representing a single item in the Wishlist
class WishlistItem extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String? imageUrl;
  final VoidCallback? onAddToCart;
  final VoidCallback? onRemove;

  const WishlistItem({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    this.imageUrl,
    this.onAddToCart,
    this.onRemove,
  });

  String _buildImageUrl(String? imagePath) {
    if (imagePath == null) return '';
    if (imagePath.startsWith('http')) return imagePath;
    final baseUrl = 'http://localhost:3000';
    final path = imagePath.startsWith('/') ? imagePath : '/$imagePath';
    return '$baseUrl$path';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E), // Card background color
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
              image: imageUrl != null && imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(_buildImageUrl(imageUrl)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null || imageUrl!.isEmpty
                ? const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.white24,
                      size: 40,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // Product Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'kobe11',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Delete button
                    if (onRemove != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: onRemove,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'kobe11',
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Price and 'Add to Cart' Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Price Tag
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
                              fontFamily: 'kobe11',
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Add to Cart Action
                    Flexible(
                      flex: 6,
                      child: InkWell(
                        onTap: onAddToCart,
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
                                fontFamily: 'kobe11',
                                fontSize: 16,
                                color: Colors.white,
                              ),
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
