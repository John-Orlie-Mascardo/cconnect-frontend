import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'me_screen.dart';
import 'home_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme background
      body: SafeArea(
        child: Column(
          children: [
            // ─── HEADER SECTION ────────────────────────────────────────────────
            // Top navigation bar containing back button, title, and action icons
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Back Button: Circular icon to return to the previous screen
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

                  // Screen Title
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
            // Label for the notifications category (Order Updates)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: const Color(0xFF303030),
              child: const Center(
                child: Text(
                  'Order Updates',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'kobe11',
                    fontSize: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ─── MAIN CONTENT ──────────────────────────────────────────────────
            // Displays brand logo and a call-to-action button for empty state
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Brand Logo
                  Image.asset(
                    'assets/images/logo.png',
                    color: Colors.white,
                    width: 230,
                    height: 230,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 40),

                  // Shop Now Button: Redirects the user back to the Home screen to start shopping
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      height: 80,
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF202020),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(
                            context,
                          ); // Navigate back to home context
                        },
                        child: const Text(
                          'SHOP NOW',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'kobe11',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ─── BOTTOM NAVIGATION BAR ─────────────────────────────────────────────
      // Allows switching between Home, Cart, and Profile screens
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: 0, // Highlights the 'Home' tab by default for this view
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          // Navigation Logic: Replaces the current route to avoid stacking navigation
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
