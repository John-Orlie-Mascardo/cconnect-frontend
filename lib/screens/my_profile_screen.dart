import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  String _name = 'Loading...';
  String _phone = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await UserService.getProfile();
      
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        setState(() {
          _name = data['name'] ?? FirebaseAuth.instance.currentUser?.displayName ?? 'User';
          _phone = data['phone'] ?? FirebaseAuth.instance.currentUser?.phoneNumber ?? 'No phone number';
        });
      } else {
        // Fallback to Firebase Auth
        final user = FirebaseAuth.instance.currentUser;
        setState(() {
          _name = user?.displayName ?? 'User';
          _phone = user?.phoneNumber ?? 'No phone number';
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile from server. Using local data.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      // Fallback
      final user = FirebaseAuth.instance.currentUser;
      if (mounted) {
        setState(() {
          _name = user?.displayName ?? 'User';
          _phone = user?.phoneNumber ?? 'No phone number';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfile(String field, String value) async {
    setState(() => _isLoading = true);

    Map<String, dynamic> result;
    if (field == 'name') {
      result = await UserService.updateProfile(name: value);
    } else {
      result = await UserService.updateProfile(phone: value);
    }

    if (result['success'] == true) {
      setState(() {
        if (field == 'name') _name = value;
        if (field == 'phone') _phone = value;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  void _showEditDialog(String title, String currentValue, String fieldKey) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Edit $title', style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter new $title',
            hintStyle: const TextStyle(color: Colors.white54),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFEDFF00)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.isNotEmpty && controller.text != currentValue) {
                _updateProfile(fieldKey, controller.text);
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFFEDFF00), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEDFF00)))
          : ListView(
              children: [
                _buildProfileItem(
                  context,
                  'User Name',
                  _name,
                  Icons.person,
                  () => _showEditDialog('User Name', _name, 'name'),
                ),
                _buildProfileItem(
                  context,
                  'Phone Number',
                  _phone,
                  Icons.phone,
                  () => _showEditDialog('Phone Number', _phone, 'phone'),
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
    VoidCallback onTap,
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
      trailing: const Icon(Icons.edit, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}
