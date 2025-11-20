import 'package:flutter/material.dart';
import 'notifications_screen.dart';
import 'chats_screen.dart';

class MyPurchasesScreen extends StatelessWidget {
  const MyPurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final completedProducts = [
      {'name': 'Joshua Shoes', 'price': '₱69,420'},
      {'name': 'Joshua Lebron Shoes', 'price': '₱420.69'},
      {'name': 'Another Shoes', 'price': '₱12,345'},
      {'name': 'Last Pair', 'price': '₱9,999'},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ─── TOP BAR ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Back Button
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

                  const Text(
                    'My Purchases',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),

                  const Spacer(),

                  // NOTIFICATION BUTTON → NotificationScreen()
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

                  // CHAT BUTTON → ChatsScreen()
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatsScreen(),
                        ),
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

            // ─── TABS ────────────────────────────────────────────────
            Container(
              color: Colors.black,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('To Pay',
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                  Text('To Ship',
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                  Text('To Receive',
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── EMPTY ORDERS CIRCLE ─────────────────────────────────────
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
                style: TextStyle(fontSize: 22, color: Colors.white70),
              ),
            ),

            const SizedBox(height: 32),

            // ─── COMPLETED HEADER ─────────────────────────────────────
            Container(
              width: double.infinity,
              height: 56,
              color: const Color(0xFF2F2F2F),
              alignment: Alignment.center,
              child: const Text(
                'COMPLETED',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
            ),

            // ─── COMPLETED GRID ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 0.60,
                  ),
                  itemCount: completedProducts.length,
                  itemBuilder: (context, index) {
                    final item = completedProducts[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            color: const Color(0xFF2F2F2F),
                            alignment: Alignment.center,
                            child: const Text(
                              'pic',
                              style: TextStyle(
                                  fontSize: 20, color: Colors.white70),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['name']!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          item['price']!,
                          style: const TextStyle(
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
