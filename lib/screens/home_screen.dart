import 'package:flutter/material.dart';
import 'dart:async';
import 'cart_screen.dart';
import 'me_screen.dart';
import 'notifications_screen.dart';
import 'chats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // current index of bottom nav bar
  int _currentHeroIndex = 0; // current index of hero area

  // key so we can open the drawer from the custom top bar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // manual demo products with different names and prices for demo purposes
  final List<Map<String, String?>> demoProducts = [
    {
      'title': 'Joshua Shoes',
      'price': '₱69,420',
      'image': 'assets/images/prod_item.jpg',
    },
    {
      'title': 'Joshua Feet',
      'price': '₱59,300',
      'image': 'assets/images/prod_item2.jpg',
    },
    {
      'title': 'Joshua Socks',
      'price': '₱75,150',
      'image': 'assets/images/prod_item3.jpg',
    },
    {
      'title': 'Ken Crocs',
      'price': '₱82,500',
      'image': 'assets/images/prod_item4.jpg',
    },
    {
      'title': 'Orlie Slippers',
      'price': '₱45,200',
      'image': 'assets/images/prod_item5.jpg',
    },
    {
      'title': 'James Heels',
      'price': '₱90,750',
      'image': 'assets/images/prod_item6.jpg',
    },
  ];

  final List<String> _heroImages = [
    'assets/images/feature_test.jpg',
    'assets/images/feature_test2.jpg',
    'assets/images/feature_test3.jpg',
  ];

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);

    if (index == 1) {
      // Cart Screen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CartScreen()),
      );
    } else if (index == 2) {
      // Me Screen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MeScreen()),
      );
    }
    // index 0 = Home, do nothing (already here)
  }

  Timer? _heroTimer;

  @override
  void initState() {
    super.initState();
    _startHeroTimer();
  }

  void _startHeroTimer() {
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentHeroIndex = (_currentHeroIndex + 1) % _heroImages.length;
      });
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: null,

      // ─── DRAWER ───────────────────────────────────────────────
      drawer: Drawer(
        backgroundColor: const Color(0xFF000000),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFEDFF00),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    splashColor: Colors.white24,
                    highlightColor: Colors.white12,
                    onPressed: () {
                      Navigator.of(context).pop(); // close drawer
                    },
                  ),
                  const Text(
                    'Csoles Connect',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Notifications tile  -> NotificationScreen
            InkWell(
              onTap: () {
                Navigator.of(context).pop(); // close drawer first
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationScreen(),
                  ),
                );
              },
              child: const ListTile(
                leading: Icon(Icons.notifications_none, color: Colors.white),
                title: Text(
                  "Notifications",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            // Chatbox tile  -> ChatsScreen
            InkWell(
              onTap: () {
                Navigator.of(context).pop(); // close drawer first
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ChatsScreen(),
                  ),
                );
              },
              child: const ListTile(
                leading: Icon(Icons.chat_bubble_outline, color: Colors.white),
                title: Text(
                  "Messages",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            // Log out (still placeholder)
            InkWell(
              onTap: () {
                // TODO: implement logout
                debugPrint("Pressed the Log out!");
              },
              child: const ListTile(
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text("Logout", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),

      // ─── BODY ───────────────────────────────────────────────
      body: SafeArea(
        child: Column(
          children: [
            // custom top bar
            Container(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      splashColor: Colors.white24,
                      highlightColor: Colors.white12,
                      icon: const Icon(
                        Icons.menu,
                        size: 28,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                    const Spacer(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        'assets/images/logo.png',
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

            // main content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // hero area
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.33,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 1000),
                        child: ClipRRect(
                          key: ValueKey(_currentHeroIndex),
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            _heroImages[_currentHeroIndex],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey,
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
                    ),

                    // slogan band
                    Container(
                      color: const Color(0xFF0000FF),
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

                    // product grid
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 14.0,
                      ),
                      child: GridView.builder(
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

      // ─── BOTTOM NAV ─────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(6),
              ),
              child: imageUrl == null
                  ? const Center(
                      child: Text('pic', style: TextStyle(color: Colors.white)),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        imageUrl!,
                        fit: BoxFit.cover,
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
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
