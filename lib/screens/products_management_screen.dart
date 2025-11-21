import 'package:flutter/material.dart';
import 'add_product_form.dart';

class ProductsManagementScreen extends StatefulWidget {
  // product managemement screen
  const ProductsManagementScreen({super.key});

  @override
  State<ProductsManagementScreen> createState() => _ProductsManagementScreen();
}

// main products page
class _ProductsManagementScreen extends State<ProductsManagementScreen> {
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
            // empty state
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // icon of no items
                    SizedBox(height: 16),
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: Colors.white,
                    ),
                    Text(
                      'No products added yet',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'kobe11',
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFEDFF00),
        onPressed: () {
          // item add pop up form
          showModalBottomSheet(
            // modal screen background color
            backgroundColor: const Color.fromARGB(255, 27, 27, 27),
            context: context,
            builder: (context) {
              return const AddProductForm();
            },
          );
        },
        // add item icon
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
