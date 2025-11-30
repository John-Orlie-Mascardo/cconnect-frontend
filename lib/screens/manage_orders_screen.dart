import 'package:flutter/material.dart';
import 'order_details_screen.dart';
import '../utils/price_formatter.dart';
import '../services/order_service.dart';
import '../models/order.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = OrderService.getAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Orders',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'kobe11',
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshOrders,
          ),
        ],
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFEDFF00)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No orders found',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final orders = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderItem(context, order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, Order order) {
    // Determine display title (first item name or generic)
    final productName = order.items.isNotEmpty ? order.items.first.name : '';
    final title = order.items.isNotEmpty
        ? '$productName${order.items.length > 1 ? " +${order.items.length - 1} more" : ""}'
        : 'Order #${order.id.substring(order.id.length - 5)}';

    // Debug logging
    print(
      'DEBUG [Manage Orders]: Product name = "$productName", Customer name = "${order.customerName}"',
    );

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(order: order, isAdmin: true),
          ),
        );
        _refreshOrders(); // Refresh list when returning
      },
      child: Container(
        color: const Color(0xFF1E1E1E),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder or First Item Image
            Container(
              width: 100,
              height: 100,
              color: Colors.grey[800],
              child: order.items.isNotEmpty && order.items.first.image != null
                  ? Image.network(
                      _buildImageUrl(order.items.first.image!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported,
                        color: Colors.white24,
                      ),
                    )
                  : const Icon(Icons.shopping_bag, color: Colors.white24),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title.isNotEmpty ? title : 'Unknown Product',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'kobe11Bold',
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        PriceFormatter.format(order.total),
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'kobe11Bold',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'OrderID: ${order.id}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'kobe11',
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Type: ${order.paymentMethod}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'kobe11',
                      fontSize: 14,
                    ),
                  ),
                  if (order.items.isNotEmpty)
                    Text(
                      'Unit Price: ${PriceFormatter.format(order.items.first.price)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'kobe11',
                        fontSize: 14,
                      ),
                    ),
                  Text(
                    'Customer: ${order.customerName}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'kobe11',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.status,
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'kobe11Bold',
                        fontSize: 12,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return const Color(0xFFEDFF00);
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _buildImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) return imagePath;
    final baseUrl = 'http://localhost:3000';
    final path = imagePath.startsWith('/') ? imagePath : '/$imagePath';
    return '$baseUrl$path';
  }
}
