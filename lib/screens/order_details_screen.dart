import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  // TODO: This screen currently uses dummy data for UI demonstration.
  // Replace with actual data fetching logic when integrating with the backend.
  const OrderDetailsScreen({super.key});

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
            // Header: Order ID and Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '#01015',
                  style: TextStyle(
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
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () {},
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
                      child: const Text(
                        'CoD',
                        style: TextStyle(
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
                        children: const [
                          Text(
                            'Packaging',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'kobe11',
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.edit, color: Colors.white, size: 16),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Customer',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'kobe11Bold',
                    fontSize: 18,
                  ),
                ),
                Icon(Icons.edit, color: Colors.white, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            _buildCustomerRow('Customer:', 'Joshua'),
            _buildCustomerRow('Number:', '1111101012'),
            _buildCustomerRow(
              'Address:',
              'Tanukikoji, Blk 31,\nLot 21\nAsahigaoka,\nSapporo Hokkaido,\nNorth Japan,\n〒064-0941:',
            ),

            const SizedBox(height: 24),
            const Divider(color: Colors.white24),
            const SizedBox(height: 24),

            // Items Header
            const Text(
              'Items: 1',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'kobe11',
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            // Item Row
            Row(
              children: [
                Container(width: 60, height: 60, color: Colors.grey[600]),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Joshua Shoes',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'kobe11Bold',
                      fontSize: 20,
                    ),
                  ),
                ),
                const Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'kobe11',
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 32),
                const Text(
                  '₱69.420',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'kobe11Bold',
                    fontSize: 20,
                  ),
                ),
              ],
            ),

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
            _buildSummaryRow('Subtotal:', '₱69.420'),
            _buildSummaryRow('Shipping cost:', '₱20.00'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'TOTAL:',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'kobe11Bold',
                    fontSize: 24,
                  ),
                ),
                Text(
                  '₱89.420',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'kobe11Bold',
                    fontSize: 24,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Complete Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'kobe11',
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Refund',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'kobe11',
                        fontSize: 16,
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
}
