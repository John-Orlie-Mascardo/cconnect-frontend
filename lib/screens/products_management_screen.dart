import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_product_form.dart';

// runtime API base URL (Android emulator uses 10.0.2.2)
String get kApiBaseUrl {
  if (kIsWeb) return 'http://localhost:3000/api';
  if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000/api';
  return 'http://localhost:3000/api';
}

class ProductsManagementScreen extends StatefulWidget {
  // product managemement screen
  const ProductsManagementScreen({super.key});

  @override
  State<ProductsManagementScreen> createState() => _ProductsManagementScreen();
}

// main products page
class _ProductsManagementScreen extends State<ProductsManagementScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final uri = Uri.parse('$kApiBaseUrl/products');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // assume data is an array
        setState(() {
          _products = List<Map<String, dynamic>>.from(data)
              .where((p) => p['deleted'] != true)
              .toList();
        });
      } else {
        debugPrint('Failed to fetch products: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProduct(String id) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Remove product?'),
            content: const Text('This will mark the product as removed (soft delete).'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    try {
      final uri = Uri.parse('$kApiBaseUrl/products/$id');
      final res = await http.delete(uri);
      if (res.statusCode == 200 || res.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product removed')));
        await _fetchProducts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Remove failed: ${res.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> product) async {
    final qtyCtrl = TextEditingController(text: product['quantity']?.toString() ?? '0');
    final condCtrl = TextEditingController(text: product['condition']?.toString() ?? '');

    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Quantity')),
            TextField(controller: condCtrl, decoration: const InputDecoration(labelText: 'Condition')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );

    if (res != true) return;

    // send PUT
    final id = product['_id'] ?? product['id'] ?? product['productId'];
    if (id == null) return;

    try {
      final uri = Uri.parse('$kApiBaseUrl/products/$id');
      final body = {
        'quantity': int.tryParse(qtyCtrl.text) ?? 0,
        'condition': condCtrl.text,
      };
      final resp = await http.put(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product updated')));
        await _fetchProducts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: ${resp.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // top bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.black,
              child: Row(
                children: [
                  // back button
                  InkWell(
                    splashColor: Colors.white24,
                    highlightColor: Colors.white24,
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                      ? Center(
                          child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 16),
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 80,
                              color: Colors.white,
                            ),
                            const Text(
                              'No products added yet',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'kobe11',
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ))
                      : RefreshIndicator(
                          onRefresh: _fetchProducts,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final p = _products[index];
                              final imageName = p['image'] as String?;
                              final imageUrl = (imageName != null && imageName.isNotEmpty)
                                  ? '${kApiBaseUrl.replaceAll('/api', '')}/uploads/$imageName'
                                  : null;

                              return Card(
                                color: Colors.grey[900],
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 96,
                                        height: 96,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.black,
                                          image: imageUrl != null
                                              ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                                              : null,
                                        ),
                                        child: imageUrl == null
                                            ? const Icon(Icons.image_not_supported, color: Colors.white24)
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(p['name'] ?? 'No name', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 6),
                                            Text('Price: ${p['price'] ?? '-'}', style: const TextStyle(color: Colors.white70)),
                                            const SizedBox(height: 6),
                                            Text('Qty: ${p['quantity'] ?? p['stock'] ?? '-'} • Cond: ${p['condition'] ?? '-'}', style: const TextStyle(color: Colors.white70)),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () => _showEditDialog(p),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                                                  child: const Text('Update'),
                                                ),
                                                const SizedBox(width: 8),
                                                ElevatedButton(
                                                  onPressed: () => _deleteProduct(p['_id']?.toString() ?? p['id']?.toString() ?? ''),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                                                  child: const Text('Remove'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEDFF00),
        onPressed: () async {
          // item add pop up form
          await showModalBottomSheet(
            // modal screen background color
            backgroundColor: const Color.fromARGB(255, 27, 27, 27),
            context: context,
            builder: (context) {
              return const AddProductForm();
            },
          );
          // refresh when sheet is closed
          await _fetchProducts();
        },
        // add item icon
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
