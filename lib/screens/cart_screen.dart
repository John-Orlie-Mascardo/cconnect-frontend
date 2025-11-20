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
            // Top bar: CART + close (X)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  // This Expanded + Center keeps "CART" centered
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 40), // to offset the close button
                        child: Text(
                          'CART',
                          style: const TextStyle(
                            fontSize: 24,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ),
                      ),
                    ),
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

            // Empty space / body
            const Expanded(
              child: SizedBox.expand(),
            ),

            // Bottom total + button area
            Container(
              color: const Color.fromARGB(255, 0, 0, 0), // light grey bar
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TOTAL row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'TOTAL:',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 2,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      Text(
                        '₱0.00',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // "CART IS EMPTY" button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // nothing for now, cart is empty
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
