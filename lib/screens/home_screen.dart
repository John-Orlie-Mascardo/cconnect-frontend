import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Demo product data — replace with your real model or API data
  final List<Map<String, String?>> demoProducts = List.generate(
    6,
    (i) => {
      'title': 'Joshua Shoes',
      'price': '₱69,420',
      // 'image' : 'https://example.com/image.jpg' // optional
      'image': null,
    },
  );

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    // handle navigation: 0 -> home, 1 -> cart, 2 -> profile (expand as needed)
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            // 🔝 Top bar (fixed, not scrollable)
            Container(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.notifications_none, size: 28, color: Colors.white,), //notification icon
                        SizedBox(width: 12),
                        Icon(Icons.chat_bubble_outline, size: 24, color: Colors.white,), //chat bubble
                      ],
                    ),
                    const Spacer(),
                    // Logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        'assets/images/logo.png', // Logo directory
                        width: 56,
                        height: 40,
                        fit: BoxFit.cover,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ⬇️ Scrollable content area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Hero area (advertising image/s or video goes here)
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.33,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/images/feature_test.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[600],
                            child: const Center(
                              child: Text(
                                'video/pic showcasing\n   goods',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Breakpoint slogan band
                    Container(
                      color: Colors.black,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Center(
                        child: Text(
                          '"your shoes, our shoes"',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Product grid (now part of overall scroll)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 14.0,
                      ),
                      child: GridView.builder(
                        // 👇 important so it works inside SingleChildScrollView
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: demoProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (context, index) {
                          final product = demoProducts[index];
                          return ProductCard(
                            title: product['title'] ?? '',
                            price: product['price'] ?? '',
                            imageUrl: product['image'],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 🔻 Bottom bar (fixed, not scrollable)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,     
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, color: Colors.white,),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined, color: Colors.white,),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline,  color: Colors.white,),
            label: 'Me',
          ),
        ],
      ),
    );
  }
}

/// Simple product card widget used in the grid.
class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String? imageUrl;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // keep or remove depending if you want tap later
      borderRadius: BorderRadius.circular(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
              child: imageUrl == null
                  ? const Center(child: Text('pic'))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Text(
            price,
            style: TextStyle(fontSize: 14,
             color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
