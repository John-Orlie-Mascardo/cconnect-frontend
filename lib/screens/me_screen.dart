import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'my_purchases_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import 'products_management_screen.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

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
                                  const Text(
                                    'BIG SHOE JOE',
                                    style: TextStyle(
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
                        child: const Text(
                          "BIG SHOE JOE'S WISHLIST",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'kobe11',
                            fontSize: 18,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      // Wishlist Items List: Scrollable area for saved items
                      ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
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
          // Navigation Logic:
          // Index 0: Go back to Home
          // Index 1: Push to Cart
          // Index 2: Stay on Profile (Current)
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
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
            label: 'cart',
          ),
          BottomNavigationBarItem(
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

  const WishlistItem({
    super.key,
    required this.title,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E), // Card background color
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Product Image Placeholder
          Container(
            width: 110,
            height: 110,
            color: Colors.grey[800],
            alignment: Alignment.center,
            child: const Text(
              'SHOE\nPIC',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, letterSpacing: 1.2),
            ),
          ),
          const SizedBox(width: 16),

          // Product Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'kobe11',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'kobe11',
                    fontSize: 16,
                    color: Colors.white70,
                  ),
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
