import 'package:flutter/material.dart';
import '../services/user_service.dart';

/// User Details Screen - Owner Dashboard
///
/// Displays detailed user information and allows status management
/// Owner can ban or activate user accounts
///
/// Backend Integration:
/// PUT /api/admin/users/:userId/status
/// Headers: { 'Authorization': 'Bearer <firebase_token>' }
/// Body: { "status": "active" | "banned" }
/// Returns: { "success": true, "user": {...} }

class UserDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late String _currentStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.user['status'] as String;
  }

  /// Update user status (ban or activate)
  Future<void> _updateUserStatus(String newStatus) async {
    setState(() => _isLoading = true);

    try {
      final success = await UserService.updateUserStatus(
        widget.user['id'] ?? widget.user['_id'],
        newStatus,
      );

      if (!success) {
        throw Exception('Failed to update status');
      }

      setState(() {
        _currentStatus = newStatus;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'banned'
                  ? 'User has been banned'
                  : 'User has been activated',
            ),
            backgroundColor: const Color(0xFFEDFF00),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        // Return to previous screen after successful update
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update user status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show confirmation dialog before taking action
  void _showConfirmationDialog({
    required String title,
    required String content,
    required String action,
    required Color confirmColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontFamily: 'kobe11Bold'),
        ),
        content: Text(
          content,
          style: const TextStyle(color: Colors.white70, fontFamily: 'kobe11'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54, fontFamily: 'kobe11'),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _updateUserStatus(action);
            },
            child: Text(
              'Confirm',
              style: TextStyle(color: confirmColor, fontFamily: 'kobe11Bold'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _currentStatus.toLowerCase() == 'active';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'User Details',
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
            // User Icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white54,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // User Name
            Center(
              child: Text(
                widget.user['name'] ?? 'Unknown User',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'kobe11Bold',
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),

            // Status Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFEDFF00) : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _currentStatus.toUpperCase(),
                  style: TextStyle(
                    color: isActive ? Colors.black : Colors.white,
                    fontFamily: 'kobe11Bold',
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Divider(color: Colors.white24),
            const SizedBox(height: 24),

            // User Information Section
            const Text(
              'User Information',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'kobe11Bold',
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: widget.user['email'] ?? 'N/A',
            ),
            _buildInfoRow(
              icon: Icons.phone_outlined,
              label: 'Phone Number',
              value: widget.user['phoneNumber'] ?? 'N/A',
            ),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Join Date',
              value: widget.user['joinDate'] ?? 'N/A',
            ),
            _buildInfoRow(
              icon: Icons.shopping_bag_outlined,
              label: 'Total Orders',
              value: '${widget.user['totalOrders'] ?? 0}',
            ),
            _buildInfoRow(
              icon: Icons.badge_outlined,
              label: 'User ID',
              value: widget.user['id'] ?? 'N/A',
            ),

            const SizedBox(height: 32),
            const Divider(color: Colors.white24),
            const SizedBox(height: 24),

            // Action Buttons
            const Text(
              'Account Management',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'kobe11Bold',
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                // Activate User Button
                if (!isActive)
                  Expanded(
                    child: InkWell(
                      onTap: _isLoading
                          ? null
                          : () => _showConfirmationDialog(
                              title: 'Activate User',
                              content:
                                  'Are you sure you want to activate this user account? They will regain access to the app.',
                              action: 'active',
                              confirmColor: const Color(0xFFEDFF00),
                            ),
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDFF00),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text(
                                'Activate User',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'kobe11Bold',
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),

                // Spacing if both buttons shown
                if (!isActive && isActive) const SizedBox(width: 16),

                // Ban User Button
                if (isActive)
                  Expanded(
                    child: InkWell(
                      onTap: _isLoading
                          ? null
                          : () => _showConfirmationDialog(
                              title: 'Ban User',
                              content:
                                  'Are you sure you want to ban this user? They will lose access to the app immediately.',
                              action: 'banned',
                              confirmColor: Colors.red,
                            ),
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Ban User',
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: 'kobe11Bold',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Warning Text
            Center(
              child: Text(
                isActive
                    ? 'Banning this user will immediately revoke their access'
                    : 'Activating this user will restore their full access',
                style: const TextStyle(
                  color: Colors.white54,
                  fontFamily: 'kobe11',
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFEDFF00), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontFamily: 'kobe11',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'kobe11',
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
