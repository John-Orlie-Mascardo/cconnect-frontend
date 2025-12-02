import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../models/order.dart';
import '../utils/price_formatter.dart';
import 'order_details_screen.dart';
import 'widgets/error_view.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = OrderService.getUserOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'My Orders',
          style: TextStyle(fontFamily: 'kobe11Bold', color: Colors.white),
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
            return ErrorView(
              onRetry: _refreshOrders,
              message: 'Failed to load orders.\nPlease check your connection.',
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No orders yet',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'kobe11',
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Start Shopping',
                      style: TextStyle(
                        color: Color(0xFFEDFF00),
                        fontFamily: 'kobe11Bold',
                      ),
                    ),
                  ),
                ],
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
    // Determine display title
    final productName = order.items.isNotEmpty ? order.items.first.name : '';
    final title = order.items.isNotEmpty
        ? '$productName${order.items.length > 1 ? " +${order.items.length - 1} more" : ""}'
        : 'Order #${order.id.substring(order.id.length - 5)}';

    // Debug logging
    print(
      'DEBUG [Customer Orders]: Product name = "$productName", Customer = "${order.customerName}"',
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(order: order, isAdmin: false),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child:
                      order.items.isNotEmpty && order.items.first.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            _buildImageUrl(order.items.first.image!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_not_supported,
                              color: Colors.white24,
                            ),
                          ),
                        )
                      : const Icon(Icons.shopping_bag, color: Colors.white24),
                ),
                const SizedBox(width: 16),
                // Info
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
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
                      const SizedBox(height: 8),
                      Text(
                        'Order ID: ${order.id}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontFamily: 'kobe11',
                          fontSize: 12,
                        ),
                      ),
                      if (order.items.isNotEmpty)
                        Text(
                          'Unit Price: ${PriceFormatter.format(order.items.first.price)}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontFamily: 'kobe11',
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.items.length} items • ${PriceFormatter.format(order.total)}',
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
