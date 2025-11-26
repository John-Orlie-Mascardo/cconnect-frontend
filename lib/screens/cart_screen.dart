import 'package:flutter/material.dart';
import '../services/cart_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Access cart items from singleton
  List<Map<String, dynamic>> get _cartItems => CartManager.instance.items;

  double get _totalPrice {
    if (_cartItems.isEmpty) return 0.0;
    // Parse price string (e.g., "₱69,420") to double
    double total = 0.0;
    for (var item in _cartItems) {
      String priceStr = item['price'].toString().replaceAll(
        RegExp(r'[^0-9.]'),
        '',
      );
      double price = double.tryParse(priceStr) ?? 0.0;
      total += price;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = _cartItems.isEmpty;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 100,
                      color: Colors.white70,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Please login to view cart',
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

            return Column(
              children: [
                // Header Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: const Text(
                              'CART',
                              style: TextStyle(
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

                // Main Content: Empty State vs Cart List
                Expanded(
                  child: isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _cartItems.length,
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(4),
                                      image: item['image'] != null
                                          ? DecorationImage(
                                              image: AssetImage(item['image']),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'],
                                          style: const TextStyle(
                                            fontFamily: 'kobe11Bold',
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          item['price'],
                                          style: const TextStyle(
                                            fontFamily: 'kobe11',
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        CartManager.instance.removeItem(index);
                                      });
                                    },
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // Footer Section
                Container(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
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
                            isEmpty
                                ? '₱0.00'
                                : '₱${_totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isEmpty
                              ? null
                              : () {
                                  // Checkout logic
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isEmpty
                                ? const Color(0xFF333333)
                                : const Color(0xFFEDFF00),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isEmpty ? 'CART IS EMPTY' : 'CHECKOUT',
                            style: TextStyle(
                              fontFamily: 'kobe11Bold',
                              fontSize: 18,
                              letterSpacing: 2,
                              color: isEmpty ? Colors.white54 : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'Your Cart is Empty',
            style: TextStyle(
              fontFamily: 'kobe11',
              fontSize: 18,
              color: Colors.white54,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
