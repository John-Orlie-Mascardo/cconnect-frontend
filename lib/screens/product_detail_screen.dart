import 'package:flutter/material.dart';
// import 'home_screen.dart';
import 'cart_screen.dart';
import 'me_screen.dart';

/// Product detail screen showing full product information
/// Features: Image gallery, size selection, add to cart, wishlist, chat, tabs
class ProductDetailScreen extends StatefulWidget {
  final String productTitle;
  final String productPrice;
  final String? productImage;

  const ProductDetailScreen({
    super.key,
    required this.productTitle,
    required this.productPrice,
    this.productImage,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // ─── STATE VARIABLES ───────────────────────────────────────

  /// Currently selected size (null = no size selected)
  int? _selectedSize;

  /// Available shoe sizes
  final List<int> _sizes = [4, 5, 6, 7, 8, 9, 10, 11, 12];

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
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CartScreen()),
      );
    } else if (index == 2) {
      // Me - Navigate to me/profile screen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MeScreen()),
      );
    }
  }

  /// Handle size selection
  void _selectSize(int size) {
    setState(() {
      _selectedSize = size;
    });
  }

  /// Handle add to cart
  void _addToCart() {
    if (_selectedSize == null) {
      // Show snackbar if no size selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a size first'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // TODO: Add actual cart functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added ${widget.productTitle} (Size $_selectedSize) to cart!',
        ),
        backgroundColor: Color(0xFFEDFF00),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Toggle wishlist/favorite
  void _toggleFavorite() {
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
                    child: widget.productImage != null
                        ? Image.asset(
                            widget.productImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Text(
                                'video/pic showcasing\ngoods',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          )
                        : const Center(
                            child: Text(
                              'video/pic showcasing\ngoods',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
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
                                widget.productTitle,
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
                                color: _isFavorite ? Color(0xFFEDFF00) : Colors.white,
                              ),
                              onPressed: _toggleFavorite,
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Price
                        Text(
                          widget.productPrice,
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
                            final isSelected = _selectedSize == size;
                            return GestureDetector(
                              onTap: () => _selectSize(size),
                              child: Container(
                                width: 60,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Color(0xFFEDFF00)
                                      : Colors.grey[800],
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isSelected
                                        ? Color(0xFFEDFF00)
                                        : Colors.grey[700]!,
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
                                      color: isSelected ? Colors.black : Colors.white,
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
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
              selectedItemColor: Color(0xFFEDFF00),
              unselectedItemColor: Colors.white70,
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
        return const Text(
          'Shoe worn by Tosen Jordan through thick and thin, through rain and shine, in sickness and in health; will you love, honor and cherish this shoe for as long as you both live?',
          style: TextStyle(
            fontFamily: 'kobe11',
            fontSize: 14,
            color: Colors.white70,
            height: 1.5,
          ),
        );
      case 1: // Materials
        return const Text(
          'Made with premium leather and synthetic materials. Features breathable mesh lining, rubber outsole for durability, and cushioned insole for comfort.',
          style: TextStyle(
            fontFamily: 'kobe11',
            fontSize: 14,
            color: Colors.white70,
            height: 1.5,
          ),
        );
      case 2: // Condition
        return const Text(
          'Gently used. Shows minimal signs of wear. Sole has good tread remaining. No major scuffs or damage. Cleaned and ready to wear.',
          style: TextStyle(
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