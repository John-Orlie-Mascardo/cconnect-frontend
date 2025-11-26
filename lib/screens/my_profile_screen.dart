import 'package:flutter/material.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'My Profile',
          style: TextStyle(fontFamily: 'kobe11Bold', color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          _buildProfileItem(context, 'User Name', 'BIG SHOE JOE', Icons.person),
          _buildProfileItem(
            context,
            'Phone Number',
            '+63 912 345 6789',
            Icons.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'kobe11',
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontFamily: 'kobe11Bold',
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        // Placeholder for edit functionality
      },
    );
  }
}
