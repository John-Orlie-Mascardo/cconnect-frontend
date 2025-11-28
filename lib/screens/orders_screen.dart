import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 0, 0)),
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
