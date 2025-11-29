import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address.dart';
import '../services/cart_manager.dart';
import '../services/address_service.dart';
import 'my_addresses_screen.dart';

/// Checkout Screen - Final step before order placement
///
/// Flow:
/// 1. User selects delivery address (from saved addresses)
/// 2. Reviews cart items
/// 3. Selects delivery method (CoD, CoP, Meetup)
/// 4. Selects payment method (Cash, E-wallet/GCash)
/// 5. Reviews payment breakdown (subtotal + shipping)
/// 6. Places order
///
/// Backend Integration:
/// POST /api/orders/create
/// Headers: { 'Authorization': 'Bearer <firebase_token>' }
/// Body: {
///   "userId": "<firebase_uid>",
///   "customerName": "<from_user_profile>",
///   "phoneNumber": "<from_user_profile>",
///   "deliveryAddress": Address.toJson(),
///   "deliveryMethod": "cod" | "cop" | "meetup",
///   "paymentMethod": "cash" | "gcash",
///   "items": [{ "productId": "...", "name": "...", "price": 0.0, "quantity": 1, "image": "..." }],
///   "subtotal": 0.0,
///   "shippingFee": 0.0,
///   "total": 0.0
/// }
/// Returns: { "orderId": "...", "status": "pending" }
///
/// Success Flow:
/// - Show success modal
/// - Clear cart (CartManager.instance.clearCart())
/// - Navigate to home screen
/// - Backend should notify owner via orders management screen

class CheckoutScreen extends StatefulWidget {
  final String? preselectedPaymentMethod;
  
  const CheckoutScreen({
    super.key,
    this.preselectedPaymentMethod,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // State variables
  Address? _selectedAddress;
  String? _selectedDeliveryMethod; // 'cod', 'cop', 'meetup'
  String? _selectedPaymentMethod; // 'cash', 'gcash'
  bool _isLoading = false;
  List<Address> _addresses = [];

  // Get cart items from singleton
  List<Map<String, dynamic>> get _cartItems => CartManager.instance.items;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = widget.preselectedPaymentMethod;
    _loadAddresses();
  }

  /// Load user's saved addresses
  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Replace with actual API call
      // GET /api/users/:userId/addresses
      final addresses = await AddressService.getAddresses();
      setState(() {
        _addresses = addresses;
        // Auto-select default address if exists
        _selectedAddress = addresses.firstWhere(
          (addr) => addr.isDefault,
          orElse: () => addresses.isNotEmpty
              ? addresses.first
              : Address(
                  province: '',
                  city: '',
                  barangay: '',
                  postalCode: '',
                  streetDetails: '',
                ),
        );
      });
    } catch (e) {
      _showSnackBar('Failed to load addresses', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Calculate subtotal from cart items
  double get _subtotal {
    double total = 0.0;
    for (var item in _cartItems) {
      String priceStr = item['price'].toString().replaceAll(
        RegExp(r'[^0-9.]'),
        '',
      );
      double price = double.tryParse(priceStr) ?? 0.0;
      int quantity = item['quantity'] ?? 1;
      total += price * quantity;
    }
    return total;
  }

  /// Calculate shipping fee based on delivery method
  double get _shippingFee {
    // TODO: Replace with actual shipping calculation logic
    // Could be based on distance, weight, or delivery method
    if (_selectedDeliveryMethod == 'cop') return 0.0; // Free for pickup
    if (_selectedDeliveryMethod == 'meetup') return 0.0; // Free for meetup
    return 40.0; // Flat rate for CoD
  }

  double get _total => _subtotal + _shippingFee;

  /// Build image URL for network images
  String _buildImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) return imagePath;
    final baseUrl = 'http://localhost:3000';
    final path = imagePath.startsWith('/') ? imagePath : '/$imagePath';
    return '$baseUrl$path';
  }

  /// Place order - sends to backend
  Future<void> _placeOrder() async {
    // Validation
    if (_selectedAddress == null || _selectedAddress!.province.isEmpty) {
      _showSnackBar('Please select a delivery address', isError: true);
      return;
    }
    if (_selectedDeliveryMethod == null) {
      _showSnackBar('Please select a delivery method', isError: true);
      return;
    }
    if (_selectedPaymentMethod == null) {
      _showSnackBar('Please select a payment method', isError: true);
      return;
    }
    if (_cartItems.isEmpty) {
      _showSnackBar('Your cart is empty', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get Firebase user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get Firebase token
      final token = await user.getIdToken();

      // Prepare order data
      final orderData = {
        'userId': user.uid,
        'customerName':
            user.displayName ?? user.email?.split('@').first ?? 'Customer',
        'phoneNumber': user.phoneNumber ?? 'N/A', // TODO: Get from user profile
        'deliveryAddress': _selectedAddress!.toJson(),
        'deliveryMethod': _selectedDeliveryMethod,
        'paymentMethod': _selectedPaymentMethod == 'cash'
            ? _selectedDeliveryMethod
            : _selectedPaymentMethod,
        'items': _cartItems
            .map(
              (item) {
                // Extract and validate product name
                final productName = (item['title'] ?? item['name'] ?? '').toString().trim();
                final productId = item['productId'] ?? item['id'];
                
                // Detailed logging for each cart item
                print('CART ITEM DEBUG: productId=$productId, title=${item['title']}, name=${item['name']}, keys=${item.keys.toList()}');
                
                // Log warning if name is empty
                if (productName.isEmpty) {
                  print('WARNING: Empty product name for productId: $productId');
                }
                
                // Log warning if no productId
                if (productId == null || productId.toString().isEmpty) {
                  print('CRITICAL WARNING: Cart item has NO productId! Item: $item');
                }
                
                return {
                  'productId': productId,
                  'name': productName.isNotEmpty ? productName : 'Unknown Product',
                  'price':
                      double.tryParse(
                        item['price'].toString().replaceAll(
                          RegExp(r'[^0-9.]'),
                          '',
                        ),
                      ) ??
                      0.0,
                  'quantity': item['quantity'] ?? 1,
                  'image': item['image'],
                };
              },
            )
            .toList(),
        'subtotal': _subtotal,
        'shippingFee': _shippingFee,
        'total': _total,
      };

      // Debug: Print order data
      print('=== ORDER DATA ===');
      print(jsonEncode(orderData));
      print('==================');

      // TODO: Replace with actual backend endpoint
      final uri = Uri.parse('http://localhost:3000/api/orders/create');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(orderData),
      );

      setState(() => _isLoading = false);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success - clear cart and show modal
        await CartManager.instance.clear();
        if (mounted) _showSuccessModal();
      } else {
        throw Exception('Order failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to place order: $e', isError: true);
    }
  }

  /// Show success modal after order placement
  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFFEDFF00), size: 64),
            const SizedBox(height: 16),
            const Text(
              'Order Placed!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your order has been placed successfully',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  ); // Navigate to home, clear stack
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEDFF00),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFEDFF00),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAddressSection(),
                          const SizedBox(height: 16),
                          _buildItemsSection(),
                          const SizedBox(height: 16),
                          _buildDeliveryMethodSection(),
                          const SizedBox(height: 16),
                          _buildPaymentMethodSection(),
                          const SizedBox(height: 16),
                          _buildPaymentDetails(),
                        ],
                      ),
                    ),
            ),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(40),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[800],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Checkout',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFEDFF00), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Delivery Address',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyAddressesScreen(),
                    ),
                  );
                  _loadAddresses(); // Reload addresses when returning
                },
                child: const Text(
                  'Change',
                  style: TextStyle(color: Color(0xFFEDFF00)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedAddress != null && _selectedAddress!.province.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedAddress!.province}, ${_selectedAddress!.city}, ${_selectedAddress!.barangay}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedAddress!.streetDetails,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Postal Code: ${_selectedAddress!.postalCode}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            )
          else
            const Text(
              'No address selected. Please add an address.',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items (${_cartItems.length})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._cartItems.map((item) => _buildItemCard(item)),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
              image: item['image'] != null
                  ? DecorationImage(
                      image: NetworkImage(_buildImageUrl(item['image'])),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item['image'] == null
                ? const Icon(Icons.image_not_supported, color: Colors.white24)
                : null,
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? 'Product',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['price']} × ${item['quantity']}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryMethodSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Method',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMethodButton('CoD', 'CoD', _selectedDeliveryMethod),
              const SizedBox(width: 8),
              _buildMethodButton('CoP', 'CoP', _selectedDeliveryMethod),
              const SizedBox(width: 8),
              _buildMethodButton('Meetup', 'Meetup', _selectedDeliveryMethod),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMethodButton(
                'Cash',
                'cash',
                _selectedPaymentMethod,
                isPayment: true,
              ),
              const SizedBox(width: 8),
              _buildMethodButton(
                'GCash',
                'E-Wallet',
                _selectedPaymentMethod,
                isPayment: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodButton(
    String label,
    String value,
    String? selected, {
    bool isPayment = false,
  }) {
    final isSelected = selected == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            if (isPayment) {
              _selectedPaymentMethod = value;
            } else {
              _selectedDeliveryMethod = value;
            }
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEDFF00) : Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildPriceRow('Merchandise Subtotal', _subtotal),
          const SizedBox(height: 8),
          _buildPriceRow('Shipping Fee', _shippingFee),
          const Divider(color: Colors.white30, height: 24),
          _buildPriceRow('Total Payment', _total, isBold: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₱${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isBold ? const Color(0xFFEDFF00) : Colors.white,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.grey[800]!)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _placeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEDFF00),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.black)
              : const Text(
                  'Place Order',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
