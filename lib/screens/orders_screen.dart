import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Orders',
          style: TextStyle(fontFamily: 'kobe11Bold', color: Colors.white),
        ),
      ),
      body: const Center(
        child: Text('Orders Screen', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
