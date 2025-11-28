import 'package:flutter/material.dart';
// import 'home_screen.dart';
import 'cart_screen.dart';
import 'me_screen.dart';
import '../services/cart_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

import '../models/product.dart';

/// Product detail screen showing full product information
/// Features: Image gallery, size selection, add to cart, wishlist, chat, tabs
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // ─── STATE VARIABLES ───────────────────────────────────────

  /// Currently selected sizes
  final Set<int> _selectedSizes = {};

  /// Available shoe sizes
  final List<int> _sizes = [4, 5, 6, 7, 8, 9, 10, 11, 12];

  /// Unavailable shoe sizes
  List<int> _unavailableSizes = [];

  @override
  void initState() {
    super.initState();
    _calculateAvailableSizes();
  }

  void _calculateAvailableSizes() {
    // Read sizes array from product (new backend format)
    final productSizes = widget.product.sizes;
    
    // If no sizes array is present, mark all as unavailable
    if (productSizes == null || productSizes.isEmpty) {
      _unavailableSizes = List.from(_sizes);
      return;
    }

    // Convert to set for efficient lookup
    final availableSizes = productSizes.toSet();

    setState(() {
      // Mark sizes as unavailable if they're not in the product's sizes array
      _unavailableSizes = _sizes.where((s) => !availableSizes.contains(s)).toList();
    });
  }

  /// Currently selected tab (0=Description, 1=Materials, 2=Condition)
  int _selectedTab = 0;

  /// Wishlist/favorite status
  bool _isFavorite = false;

  // ─── METHODS ───────────────────────────────────────────────

  /// Handle bottom navigation bar tap
  void _onNavTap(int index) {
    if (index == 0) {
      // Home - Go back to home screen
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 1) {
      // Cart - Navigate to cart screen
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
    } else if (index == 2) {
      // Me - Navigate to me/profile screen
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const MeScreen()));
    }
  }

  /// Handle size selection
  void _selectSize(int size) {
    setState(() {
      if (_selectedSizes.contains(size)) {
        _selectedSizes.remove(size);
      } else {
        _selectedSizes.add(size);
      }
    });
  }

  /// Handle add to cart
  Future<void> _addToCart() async {
    // Check if user is logged in
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add items to cart'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      // Optional: Navigate to login screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    if (_selectedSizes.isEmpty) {
      // Show snackbar if no size selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one size'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if adding all items would exceed cart limit
    // Note: CartManager check is per item, so we do a pre-check here if possible, 
    // or just try to add them one by one.
    // Since CartManager.addItem returns false if full, we can track successes.

    int addedCount = 0;
    List<int> failedSizes = [];
    
    // Create a copy of selected sizes to avoid concurrent modification
    final sizesToAdd = List<int>.from(_selectedSizes);

    for (final size in sizesToAdd) {
      final success = await CartManager.instance.addItem({
        'title': widget.product.name,
        'price': '₱${widget.product.price.toStringAsFixed(2)}', // Format price as string
        'image': widget.product.image,
        'size': size,
        'qty': 1,
        'productId': widget.product.id, // Add product ID for backend
      });

      if (success) {
        addedCount++;
      } else {
        failedSizes.add(size);
      }
    }

    if (addedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is full'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show success message
    final sizeString = sizesToAdd.join(', ');
    String message = 'Added ${widget.product.name} (Sizes: $sizeString) to cart!';
    
    if (failedSizes.isNotEmpty) {
      message += ' (Failed to add sizes: ${failedSizes.join(', ')} due to cart limit)';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFFEDFF00),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Clear selection after successful add (optional, but good UX)
    setState(() {
      _selectedSizes.clear();
    });
  }

  /// Toggle wishlist/favorite
  void _toggleFavorite() {
    // Check if user is logged in
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add to wishlist'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      // Navigate to login screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  /// Handle chat button
  void _openChat() {
    // TODO: Navigate to chat screen or open chat dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening chat...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // ─── UI BUILD ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                'assets/images/logo.png',
                height: 75,
                width: 70,
                color: Colors.white,
                errorBuilder: (_, __, ___) => const Text(
                  'logo',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── SCROLLABLE CONTENT ────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── PRODUCT IMAGE ─────────────────────────
                  Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[800],
                    child: Builder(
                      builder: (context) {
                        final image = widget.product.image;
                        if (image == null) {
                          return const Center(
                            child: Text(
                              'video/pic showcasing\ngoods',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.white70),
                            ),
                          );
                        }

                        // Determine if it's a network image (http or relative path)
                        final isNetwork = image.startsWith('http') || image.startsWith('/') || image.startsWith('uploads');
                        
                        if (isNetwork) {
                          // Construct full URL if relative
                          final imageUrl = image.startsWith('http') 
                              ? image 
                              : 'http://localhost:3000${image.startsWith('/') ? '' : '/'}$image';
                              
                          return Image(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: const Color(0xFFEDFF00),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image, color: Colors.white54, size: 50),
                            ),
                          );
                        } else {
                          // Fallback for local assets (if any)
                          return Image.asset(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Text(
                                'video/pic showcasing\ngoods',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, color: Colors.white70),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  // ─── PRODUCT INFO SECTION ──────────────────
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Favorite
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.name,
                                style: const TextStyle(
                                  fontFamily: 'kobe11Bold',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavorite
                                    ? Color(0xFFEDFF00)
                                    : Colors.white,
                              ),
                              onPressed: _toggleFavorite,
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Price
                        Text(
                          '₱${widget.product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'kobe11Bold',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Size Label
                        const Text(
                          'Size',
                          style: TextStyle(
                            fontFamily: 'kobe11Bold',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 12),


                        // Size Selection Grid
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _sizes.map((size) {
                            final isSelected = _selectedSizes.contains(size);
                            final isAvailable = !_unavailableSizes.contains(size);

                            return GestureDetector(
                              onTap: isAvailable ? () => _selectSize(size) : null,
                              child: Container(
                                width: 60,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFEDFF00)
                                      : isAvailable
                                          ? Colors.grey[800]
                                          : Colors.grey[900], // Darker for unavailable
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFEDFF00)
                                        : isAvailable
                                            ? Colors.grey[700]!
                                            : Colors.grey[850]!, // Dimmer border
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    size.toString(),
                                    style: TextStyle(
                                      fontFamily: 'kobe11',
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.black
                                          : isAvailable
                                              ? Colors.white
                                              : Colors.white24, // Dimmed text
                                      decoration: isAvailable
                                          ? null
                                          : TextDecoration.lineThrough, // Optional: strike-through
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Add to Cart and Chat Buttons
                        Row(
                          children: [
                            // Add to Cart Button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _addToCart,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFEDFF00),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: const Text(
                                  'ADD TO CART',
                                  style: TextStyle(
                                    fontFamily: 'kobe11Bold',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Chat Now Button
                            ElevatedButton(
                              onPressed: _openChat,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.chat_bubble_outline, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Chat now',
                                    style: TextStyle(
                                      fontFamily: 'kobe11',
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ─── TABS ──────────────────────────────
                        Row(
                          children: [
                            _buildTab('Description', 0),
                            const SizedBox(width: 8),
                            _buildTab('Materials', 1),
                            const SizedBox(width: 8),
                            _buildTab('Condition', 2),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Tab Content
                        _buildTabContent(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── BOTTOM NAVIGATION BAR ─────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.black,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Color.fromARGB(255, 255, 255, 255),
              unselectedItemColor: Colors.grey,
              currentIndex: 0,
              onTap: _onNavTap,
              elevation: 0,
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
                  label: 'me',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a tab button
  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFEDFF00) : Colors.grey[800],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? Color(0xFFEDFF00) : Colors.grey[700]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: isSelected ? 'kobe11Bold' : 'kobe11',
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  /// Build the content for the selected tab
  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0: // Description
        return Text(
          widget.product.description ?? 'No description available.',
          style: const TextStyle(
            fontFamily: 'kobe11',
            fontSize: 14,
            color: Colors.white70,
            height: 1.5,
          ),
        );
      case 1: // Materials
        return Text(
          widget.product.materials ?? 'Material information not available.',
          style: const TextStyle(
            fontFamily: 'kobe11',
            fontSize: 14,
            color: Colors.white70,
            height: 1.5,
          ),
        );
      case 2: // Condition
        return Text(
          widget.product.condition ?? 'Condition information not available.',
          style: const TextStyle(
            fontFamily: 'kobe11',
            fontSize: 14,
            color: Colors.white70,
            height: 1.5,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
