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

  Future<bool> _updateStatus(String newStatus) async {
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
      return true;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
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
                      child: GestureDetector(
                        onTap: widget.isAdmin && !_isLoading
                            ? () => _showStatusPicker(context)
                            : null,
                        child: Row(
                          children: [
                            Text(
                              _currentStatus[0].toUpperCase() +
                                  _currentStatus.substring(1),
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
                                const Icon(Icons.edit,
                                    color: Colors.white, size: 16),
                            ],
                          ],
                        ),
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
                            : const Icon(Icons.shopping_bag,
                                color: Colors.white24),
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
            _buildSummaryRow(
                'Subtotal:', PriceFormatter.format(widget.order.subtotal)),
            _buildSummaryRow('Shipping cost:',
                PriceFormatter.format(widget.order.shippingFee)),
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

            const SizedBox(height: 24),

            // Action Buttons (Only for Admin)
            if (widget.isAdmin)
              Row(
                children: [
                  if (_currentStatus != 'delivered' &&
                      _currentStatus != 'cancelled')
                    Expanded(
                      child: InkWell(
                        onTap: _isLoading
                            ? null
                            : () => _showConfirmationDialog(
                                  context,
                                  'Complete Order',
                                  'Are you sure you want to mark this order as completed?',
                                  'delivered',
                                  const Color(0xFFEDFF00),
                                  Colors.black,
                                ),
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
                  if (_currentStatus != 'delivered' &&
                      _currentStatus != 'cancelled') ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: _isLoading
                            ? null
                            : () => _showConfirmationDialog(
                                  context,
                                  'Cancel Order',
                                  'Are you sure you want to cancel this order?',
                                  'cancelled',
                                  Colors.red,
                                  Colors.white,
                                ),
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
                ],
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }



  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
    String statusToUpdate,
    Color confirmColor,
    Color confirmTextColor,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'kobe11Bold',
          ),
        ),
        content: Text(
          content,
          style: const TextStyle(
            color: Colors.white70,
            fontFamily: 'kobe11',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'No',
              style: TextStyle(
                color: Colors.white54,
                fontFamily: 'kobe11',
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final success = await _updateStatus(statusToUpdate);
              if (success && mounted) {
                Navigator.pop(context); // Close screen
              }
            },
            child: Text(
              'Yes',
              style: TextStyle(
                color: confirmColor,
                fontFamily: 'kobe11Bold',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    final statuses = [
      'pending',
      'processing',
      'shipped',
      'delivered',
      'cancelled'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Update Status',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'kobe11Bold',
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            ...statuses.map((status) => ListTile(
                  title: Text(
                    status[0].toUpperCase() + status.substring(1),
                    style: TextStyle(
                      color: _currentStatus == status
                          ? const Color(0xFFEDFF00)
                          : Colors.white,
                      fontFamily: 'kobe11',
                      fontSize: 18,
                    ),
                  ),
                  trailing: _currentStatus == status
                      ? const Icon(Icons.check, color: Color(0xFFEDFF00))
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    if (_currentStatus != status) {
                      String title = 'Update Status';
                      String content = 'Are you sure you want to update the status to $status?';
                      Color confirmColor = Colors.white;
                      Color confirmTextColor = Colors.black;

                      switch (status) {
                        case 'delivered':
                          title = 'Complete Order';
                          content = 'Are you sure you want to mark this order as completed?';
                          confirmColor = const Color(0xFFEDFF00);
                          break;
                        case 'cancelled':
                          title = 'Cancel Order';
                          content = 'Are you sure you want to cancel this order?';
                          confirmColor = Colors.red;
                          confirmTextColor = Colors.white;
                          break;
                        case 'shipped':
                          content = 'Are you sure you want to mark this order as shipped?';
                          break;
                        case 'processing':
                          content = 'Are you sure you want to mark this order as processing?';
                          break;
                        case 'pending':
                          content = 'Are you sure you want to mark this order as pending?';
                          break;
                      }

                      _showConfirmationDialog(
                        context,
                        title,
                        content,
                        status,
                        confirmColor,
                        confirmTextColor,
                      );
                    }
                  },
                )),
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
