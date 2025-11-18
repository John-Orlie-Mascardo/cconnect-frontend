import 'package:flutter/material.dart';
import 'dart:async'; // for timer

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState(); //
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // current index of bottom nav bar
  int _currentHeroIndex =
      0; // current index of hero area (if carousel is implemented)

  // key so we can open the drawer from the custom top bar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ORIGINAL PRODUCT MAP DATA
  // demo product data — replace with your real model or API data
  // final List<Map<String, String?>> demoProducts = List.generate(
  //   6,
  //   (i) => {
  //     'title': 'Joshua Shoes',
  //     'price': '₱69,420',
  //     'image': 'assets/images/nike_test.jpg', // replace with real image paths
  //   },
  // );

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
    // hard coded paths for hero area
    'assets/images/feature_test.jpg',
    'assets/images/feature_test2.jpg',
    'assets/images/feature_test3.jpg',
  ];

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    // handle navigation here: 0 -> home, 1 -> cart, 2 -> profile, etc
  }

  Timer? _heroTimer; // timer for changing hero area image

  // setups start timer method
  @override
  void initState() {
    super.initState();
    _startHeroTimer();
  }

  void _startHeroTimer() {
    _heroTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _currentHeroIndex = (_currentHeroIndex + 1) % _heroImages.length;
      });
    });
  }

  // disposes timer when not needed to avoid memory leaks
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
      backgroundColor: Colors.black, // scaffold background color
      appBar: null, // we are using a custom top bar
      // drawer that appears when hamburger is tapped
      drawer: Drawer(
        backgroundColor: const Color(0xFF000000),
        // drawer background color
        child: ListView(
          // creates a child in drawer called listview so it can contain many children
          padding: EdgeInsets.zero,
          children: [
            Container(
              // top of drawer with back button
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFFEDFF00),
              ), // top box decoration
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      // back arrow
                      Icons.arrow_back,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ), // back arrow icon
                    splashColor: Colors.white24,
                    highlightColor: Colors.white12,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    'Csoles Connect',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),

            // notification tile
            InkWell(
              onTap: () {
                print("Pressed notifications!");
              },
              child: const ListTile(
                leading: Icon(Icons.notifications_none, color: Colors.white),
                title: Text(
                  "Notifications",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            // chatbox tile
            InkWell(
              onTap: () {
                print("Pressed the chatbox!"); // temp function
              },
              child: const ListTile(
                leading: Icon(Icons.chat_bubble_outline, color: Colors.white),
                title: Text("Messages", style: TextStyle(color: Colors.white)),
              ),
            ),
            // log out, Log in, Register
            InkWell(
              onTap: () {
                print("Pressed the Log out!"); // temp function
              },
              child: const ListTile(
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text("Logout", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),

      // MAIN BODY
      body: SafeArea(
        child: Column(
          children: [
            // custom top bar (fixed)
            Container(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    // Hamburger / menu button
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

                    // Logo only (notifications/chat moved into drawer)
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

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // hero area (advertising image / video)
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.33,
                      child: AnimatedSwitcher(
                        // for smooth transitions
                        duration: const Duration(milliseconds: 1000),
                        child: ClipRRect(
                          key: ValueKey(
                            _currentHeroIndex,
                          ), // key for AnimatedSwitcher to know when the child changes
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

                    // Breakpoint slogan band
                    Container(
                      color: Color(
                        0xFF0000FF,
                      ), // break point color, blue else you can change to 0xFFEDFF00, yellow
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

                    // Product grid (part of scroll)
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

      // 🔻 Bottom bar (fixed)
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
          // Image placeholder
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
                      // image with rounded corners
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
            title, // title text
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Text(
            // price text
            price,
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
