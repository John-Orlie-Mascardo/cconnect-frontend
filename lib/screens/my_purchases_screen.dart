import 'package:flutter/material.dart';
import 'notifications_screen.dart';
import 'chats_screen.dart';
import '../utils/price_formatter.dart';

class MyPurchasesScreen extends StatelessWidget {
  const MyPurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data: List of completed purchase items to populate the grid
    final completedProducts = [
      {'name': 'Joshua Shoes', 'price': PriceFormatter.format(69420)},
      {'name': 'Joshua Lebron Shoes', 'price': PriceFormatter.format(420.69)},
      {'name': 'Another Shoes', 'price': PriceFormatter.format(12345)},
      {'name': 'Last Pair', 'price': PriceFormatter.format(9999)},
    ];

    return Scaffold(
      backgroundColor: Colors.black, // Dark theme background
      body: SafeArea(
        child: Column(
          children: [
            // ─── HEADER SECTION ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Back Button: Returns to the 'Me' profile screen
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF333333),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Screen Title
                  const Text(
                    'My Purchases',
                    style: TextStyle(
                      fontFamily: 'kobe11',
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),

                  const Spacer(),

                  // Action Buttons: Quick access to secondary features

                  // 1. Notifications Button
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.notifications_none,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 2. Chat Button
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatsScreen()),
                      );
                    },
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ─── ORDER STATUS TABS ─────────────────────────────────────────────
            // Static headers indicating different stages of order processing
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'To Pay',
                    style: TextStyle(
                      fontFamily: 'kobe11',
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'To Ship',
                    style: TextStyle(
                      fontFamily: 'kobe11',
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'To Receive',
                    style: TextStyle(
                      fontFamily: 'kobe11',
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── EMPTY STATE INDICATOR ─────────────────────────────────────────
            // visual placeholder showing no active orders in the above categories
            Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2F2F2F),
              ),
              alignment: Alignment.center,
              child: const Text(
                'no orders yet',
                style: TextStyle(
                  fontFamily: 'kobe11',
                  fontSize: 22,
                  color: Colors.white70,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ─── SECTION HEADER: COMPLETED ORDERS ──────────────────────────────
            Container(
              width: double.infinity,
              height: 56,
              color: const Color(0xFF2F2F2F),
              alignment: Alignment.center,
              child: const Text(
                'COMPLETED',
                style: TextStyle(
                  fontFamily: 'kobe11',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
            ),

            // ─── PRODUCT GRID ──────────────────────────────────────────────────
            // Scrollable grid displaying past purchased items
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // Scrolling handled by parent SingleChildScrollView
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 0.60, // Adjusts height relative to width
                  ),
                  itemCount: completedProducts.length,
                  itemBuilder: (context, index) {
                    final item = completedProducts[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image Placeholder
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            color: const Color(0xFF2F2F2F),
                            alignment: Alignment.center,
                            child: const Text(
                              'pic',
                              style: TextStyle(
                                fontFamily: 'kobe11',
                                fontSize: 20,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Product Name
                        Text(
                          item['name']!,
                          style: const TextStyle(
                            fontFamily: 'kobe11',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),

                        // Product Price
                        Text(
                          item['price']!,
                          style: const TextStyle(
                            fontFamily: 'kobe11',
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
