import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Intentionally minimal / empty as requested.
    return const Scaffold(
      appBar: null,
      body: SizedBox.shrink(),
    );
  }
}
