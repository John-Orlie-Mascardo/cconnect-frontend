import 'package:csoles_application/screens/checkout_screen.dart';
import 'package:flutter/material.dart';
import '../services/cart_manager.dart';
import '../utils/price_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = true;
  Set<int> _selectedIndices = {}; // Track which items are selected

  // Access cart items from singleton
  List<Map<String, dynamic>> get _cartItems => CartManager.instance.items;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);
    await CartManager.instance.loadCart();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  double get _totalPrice {
    if (_cartItems.isEmpty || _selectedIndices.isEmpty) return 0.0;
    double total = 0.0;
    for (int index in _selectedIndices) {
      if (index < _cartItems.length) {
        final item = _cartItems[index];
        // Use PriceFormatter logic to parse price string
        String priceStr = item['price'].toString().replaceAll(RegExp(r'[₱, ]'), '');
        double price = double.tryParse(priceStr) ?? 0.0;
        int quantity = item['quantity'] ?? 1;
        total += price * quantity;
      }
    }
    return total;
  }

  String _buildImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    final baseUrl = 'http://localhost:3000';
    final path = imagePath.startsWith('/') ? imagePath : '/$imagePath';
    return '$baseUrl$path';
  }

  Future<void> _incrementQuantity(int index) async {
    final item = _cartItems[index];
    int currentQuantity = item['quantity'] ?? 1;
    int stock = item['stock'] ?? 999; // TODO: Get actual stock from product data
    
    // Check if we can increment (don't exceed stock)
    if (currentQuantity >= stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum stock of $stock reached'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    int newQuantity = currentQuantity + 1;
    final success = await CartManager.instance.updateQuantity(
      index,
      newQuantity,
    );
    if (success && mounted) {
      setState(() {});
    }
  }

  Future<void> _decrementQuantity(int index) async {
    int currentQuantity = _cartItems[index]['quantity'] ?? 1;
    
    // If quantity is 1, show confirmation to remove
    if (currentQuantity <= 1) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Remove Item',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'kobe11Bold',
            ),
          ),
          content: const Text(
            'Remove this item from your cart?',
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'kobe11',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white54,
                  fontFamily: 'kobe11',
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await CartManager.instance.removeItem(index);
                if (mounted) setState(() {});
              },
              child: const Text(
                'Remove',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'kobe11Bold',
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // Decrement quantity
    int newQuantity = currentQuantity - 1;
    final success = await CartManager.instance.updateQuantity(
      index,
      newQuantity,
    );
    if (success && mounted) {
      setState(() {});
    }
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
              return Column(
                children: [
                  // Header with back button
                  Container(
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'CART',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'kobe11',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Main content
                  Expanded(
                    child: Center(
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
                    ),
                  ),
                ],
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

                // Main Content
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFEDFF00),
                            ),
                          ),
                        )
                      : isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _cartItems.length,
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            final int quantity = item['quantity'] ?? 1;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  // Checkbox for selection
                                  Checkbox(
                                    value: _selectedIndices.contains(index),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedIndices.add(index);
                                        } else {
                                          _selectedIndices.remove(index);
                                        }
                                      });
                                    },
                                    activeColor: const Color(0xFFEDFF00),
                                    checkColor: Colors.black,
                                  ),
                                  const SizedBox(width: 8),
                                  // Product Image
                                  Container(
                                    width: 80,
                                    height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(4),
                                        image: (item['image'] != null && item['image'] is String)
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                  _buildImageUrl(item['image']),
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                    child: item['image'] == null
                                        ? const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.white24,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),

                                  // Product Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title']?.toString() ?? 'Unknown Product',
                                          style: const TextStyle(
                                            fontFamily: 'kobe11Bold',
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          PriceFormatter.format(item['price']),
                                          style: const TextStyle(
                                            fontFamily: 'kobe11',
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 12),

                                        // Quantity Controls
                                        Row(
                                          children: [
                                            // Decrement Button
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () => _decrementQuantity(index),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[800],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.remove,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Quantity Display
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                              child: Text(
                                                '$quantity',
                                                style: const TextStyle(
                                                  fontFamily: 'kobe11',
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                            // Increment Button
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () => _incrementQuantity(index),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[800],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const Spacer(),

                                            // Delete Button
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    backgroundColor:
                                                        Colors.grey[900],
                                                    title: const Text(
                                                      'Remove Item',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily:
                                                            'kobe11Bold',
                                                      ),
                                                    ),
                                                    content: const Text(
                                                      'Are you sure you want to remove this item from your cart?',
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                        fontFamily: 'kobe11',
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                            ),
                                                        child: const Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                            color:
                                                                Colors.white54,
                                                            fontFamily:
                                                                'kobe11',
                                                          ),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          await CartManager
                                                              .instance
                                                              .removeItem(
                                                                index,
                                                              );
                                                          setState(() {});
                                                        },
                                                        child: const Text(
                                                          'Remove',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontFamily:
                                                                'kobe11Bold',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
                      // Total Price Row
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
                                ? PriceFormatter.format(0)
                                : PriceFormatter.format(_totalPrice),
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
                      
                      if (!isEmpty) ...[
                        const SizedBox(height: 24),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Checkout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isEmpty
                              ? null
                              : () {
                                  // Check if any items are selected
                                  if (_selectedIndices.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please select at least one item to checkout'),
                                        backgroundColor: Colors.orange,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    return;
                                  }

                                  // Get only selected items
                                  final selectedItems = _selectedIndices
                                      .map((index) => _cartItems[index])
                                      .toList();

                                  // Navigate to checkout screen with selected items
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CheckoutScreen(
                                        selectedCartItems: selectedItems,
                                      ),
                                    ),
                                  ).then((_) {
                                    // Reload cart after checkout
                                    _loadCart();
                                    // Clear selections
                                    setState(() {
                                      _selectedIndices.clear();
                                    });
                                  });
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
