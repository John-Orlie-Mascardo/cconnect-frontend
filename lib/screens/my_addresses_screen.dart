import 'package:flutter/material.dart';
import '../../models/address.dart';
import 'address_form_sheet.dart';

/// Screen for managing user delivery addresses
///
/// Features:
/// - Display all user addresses (max 3)
/// - Add new addresses via bottom sheet form
/// - Edit existing addresses
/// - Delete addresses with confirmation
/// - Mark addresses as default
///
/// Backend Requirements:
/// Replace the mock functions with these API endpoints:
///
/// 1. _loadAddresses() → GET /api/users/:userId/addresses
///    Returns: Array of address objects
///    Headers: { 'Authorization': 'Bearer <firebase_token>' }
///
/// 2. _addAddress() → POST /api/users/:userId/addresses
///    Body: Address.toJson()
///    Returns: Created address with assigned ID
///
/// 3. _updateAddress() → PUT /api/addresses/:addressId
///    Body: Address.toJson()
///    Returns: Updated address
///
/// 4. _deleteAddress() → DELETE /api/addresses/:addressId
///    Returns: 204 No Content on success
///
/// Note: Firebase Auth token should be extracted from FirebaseAuth.instance.currentUser
/// and included in Authorization header for all requests

class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  // State variables
  List<Address> _addresses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  // TODO: Backend - Replace with GET /api/users/:userId/addresses
  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data (empty for now - backend will provide real data)
    setState(() {
      _addresses = [];
      _isLoading = false;
    });
  }

  // TODO: Backend - Replace with POST /api/users/:userId/addresses
  Future<void> _addAddress(Address address) async {
    // Check 3-address limit
    if (_addresses.length >= 3) {
      _showSnackBar('Maximum 3 addresses allowed', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      // Generate temporary mock ID (backend will provide real ID)
      final newAddress = address.copyWith(id: DateTime.now().toString());
      _addresses.add(newAddress);
      _isLoading = false;
    });

    _showSnackBar('Address added successfully');
  }

  // TODO: Backend - Replace with PUT /api/addresses/:addressId
  Future<void> _updateAddress(int index, Address updatedAddress) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _addresses[index] = updatedAddress;
      _isLoading = false;
    });

    _showSnackBar('Address updated successfully');
  }

  // TODO: Backend - Replace with DELETE /api/addresses/:addressId
  Future<void> _deleteAddress(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete Address?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _addresses.removeAt(index);
      _isLoading = false;
    });

    _showSnackBar('Address deleted successfully');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddressForm({Address? existingAddress, int? index}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B1B1B),
      isScrollControlled: true,
      builder: (ctx) => AddressFormSheet(
        existingAddress: existingAddress,
        onSave: (address) {
          if (index != null) {
            _updateAddress(index, address);
          } else {
            _addAddress(address);
          }
        },
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
            // Top bar with back button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.black,
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'My Addresses',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content area
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFEDFF00),
                      ),
                    )
                  : _addresses.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_off_outlined,
                            size: 80,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No addresses added yet',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _addresses.length,
                      itemBuilder: (context, index) {
                        final address = _addresses[index];
                        return _buildAddressCard(address, index);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _addresses.length < 3
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFEDFF00),
              onPressed: () => _showAddressForm(),
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
    );
  }

  Widget _buildAddressCard(Address address, int index) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFFEDFF00),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.isDefault ? 'Default Address' : 'Delivery Address',
                    style: TextStyle(
                      color: address.isDefault
                          ? const Color(0xFFEDFF00)
                          : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Color(0xFFEDFF00),
                    size: 20,
                  ),
                  onPressed: () =>
                      _showAddressForm(existingAddress: address, index: index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _deleteAddress(index),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${address.region}, ${address.province}, ${address.city}, ${address.barangay}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Postal Code: ${address.postalCode}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              address.streetDetails,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
