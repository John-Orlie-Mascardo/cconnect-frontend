import 'package:flutter/material.dart';
import 'order_details_screen.dart';
import '../utils/price_formatter.dart';

class ManageOrdersScreen extends StatelessWidget {
  // TODO: This screen currently uses dummy data for UI demonstration.
  // Replace with actual data fetching logic when integrating with the backend.
  const ManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          'Manage Orders',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'kobe11',
            fontSize: 24,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOrderItem(
            context,
            title: 'Joshua Shoes',
            orderId: '01015',
            orderType: 'CoD',
            name: 'Joshua',
            status: 'Packaging',
            price: PriceFormatter.format(69420),
          ),
          const SizedBox(height: 16),
          _buildOrderItem(
            context,
            title: 'Orlie Socks',
            orderId: '01016',
            orderType: 'Meetup',
            name: 'Orlie',
            status: 'In Progress',
            price: PriceFormatter.format(420.69),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(
    BuildContext context, {
    required String title,
    required String orderId,
    required String orderType,
    required String name,
    required String status,
    required String price,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrderDetailsScreen()),
        );
      },
      child: Container(
        color: const Color(0xFF1E1E1E),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder
            Container(width: 100, height: 100, color: Colors.grey[600]),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'kobe11Bold',
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        price,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'kobe11Bold',
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'OrderID: $orderId',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'kobe11',
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Order Type: $orderType',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'kobe11',
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Name: $name',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'kobe11',
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Status: $status',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'kobe11',
                      fontSize: 14,
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
