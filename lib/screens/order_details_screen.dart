import 'package:flutter/material.dart';
import '../utils/price_formatter.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;
  final bool isAdmin;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    this.isAdmin = true,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late String _currentStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);
    final success = await OrderService.updateOrderStatus(widget.order.id, newStatus);
    setState(() => _isLoading = false);

    if (success) {
      setState(() => _currentStatus = newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $newStatus'),
            backgroundColor: const Color(0xFFEDFF00),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          'Order Details',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'kobe11',
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Order ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${widget.order.id.substring(widget.order.id.length - 5)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'kobe11Bold',
                    fontSize: 28,
                  ),
                ),
                const Text(
                  'Order details',
                  style: TextStyle(
                    color: Colors.white54,
                    fontFamily: 'kobe11',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Payment and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'kobe11',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: Colors.grey[800],
                      child: Text(
                        widget.order.paymentMethod,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'kobe11',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'kobe11',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      color: Colors.grey[800],
                      child: Row(
                        children: [
                          Text(
                            _currentStatus,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'kobe11',
                              fontSize: 16,
                            ),
                          ),
                          if (widget.isAdmin) ...[
                            const SizedBox(width: 8),
                            if (_isLoading)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else
                              const Icon(Icons.edit, color: Colors.white, size: 16),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white24),
            const SizedBox(height: 24),

            // Customer Info
            const Text(
              'Customer',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'kobe11Bold',
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            _buildCustomerRow('Name:', widget.order.customerName),
            _buildCustomerRow('Number:', widget.order.phoneNumber),
            _buildCustomerRow(
              'Address:',
              widget.order.deliveryAddress.fullAddress,
            ),

            const SizedBox(height: 24),
            const Divider(color: Colors.white24),
            const SizedBox(height: 24),

            // Items Header
            Text(
              'Items: ${widget.order.items.length}',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'kobe11',
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            // Items List
            ...widget.order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[800],
                        child: item.image != null
                            ? Image.network(
                                _buildImageUrl(item.image!),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white24),
                              )
                            : const Icon(Icons.shopping_bag, color: Colors.white24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'kobe11Bold',
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Text(
                        'x${item.quantity}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'kobe11',
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 32),
                      Text(
                        PriceFormatter.format(item.price * item.quantity),
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'kobe11Bold',
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 24),
            const Divider(color: Colors.white24),
            const SizedBox(height: 24),

            // Payment Summary
            const Text(
              'Payment',
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'kobe11',
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Subtotal:', PriceFormatter.format(widget.order.subtotal)),
            _buildSummaryRow('Shipping cost:', PriceFormatter.format(widget.order.shippingFee)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL:',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'kobe11Bold',
                    fontSize: 24,
                  ),
                ),
                Text(
                  PriceFormatter.format(widget.order.total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'kobe11Bold',
                    fontSize: 24,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Action Buttons (Only for Admin)
            if (widget.isAdmin && _currentStatus != 'Delivered' && _currentStatus != 'Cancelled')
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _isLoading ? null : () => _updateStatus('Delivered'),
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDFF00),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text(
                                'Complete Order',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'kobe11Bold',
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _isLoading ? null : () => _updateStatus('Cancelled'),
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Cancel Order',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'kobe11',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontFamily: 'kobe11',
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'kobe11',
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontFamily: 'kobe11',
              fontSize: 18,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'kobe11Bold',
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  String _buildImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) return imagePath;
    final baseUrl = 'http://localhost:3000';
    final path = imagePath.startsWith('/') ? imagePath : '/$imagePath';
    return '$baseUrl$path';
  }
}
