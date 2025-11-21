import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section: Displays the screen title 'CART' and a close button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  // Title Container: Expands to fill space and centers the text
                  Expanded(
                    child: Center(
                      child: Padding(
                        // Offset padding to visually center the title against the right-aligned close button
                        padding: const EdgeInsets.only(left: 40),
                        child: Text(
                          'CART',
                          style: const TextStyle(
                            fontFamily: 'kobe11',
                            fontSize: 24,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Navigation: Close button to dismiss the screen
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 28,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),

            // Spacer: Occupies remaining vertical space to push the footer to the bottom
            const Expanded(child: SizedBox.expand()),

            // Footer Section: Contains the total amount display and the main action button
            Container(
              color: const Color.fromARGB(
                255,
                0,
                0,
                0,
              ), // Background color matches scaffold
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Summary Row: Displays 'TOTAL' label and the current cart value
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'TOTAL:',
                        style: TextStyle(
                          fontFamily: 'kobe11',
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 2,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      Text(
                        '₱0.00',
                        style: TextStyle(
                          fontFamily: 'kobe11',
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Primary Action Button: Indicates cart state (Empty) or triggers checkout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // No action required when cart is empty
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF666666),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'CART IS EMPTY',
                        style: TextStyle(
                          fontFamily: 'kobe11',
                          fontSize: 18,
                          letterSpacing: 2,
                          color: Colors.white,
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
    );
  }
}
