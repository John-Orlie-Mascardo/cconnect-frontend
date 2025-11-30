import 'package:flutter/material.dart';
import 'user_details_screen.dart';

/// Manage Users Screen - Owner Dashboard
///
/// Displays all registered users with key information
/// Allows navigation to user details for status management
///
/// Backend Integration:
/// GET /api/admin/users
/// Headers: { 'Authorization': 'Bearer <firebase_token>' }
/// Returns: [{
///   "id": "user_id",
///   "name": "User Name",
///   "email": "user@email.com",
///   "phoneNumber": "123456789",
///   "joinDate": "2024-01-15T10:30:00Z",
///   "totalOrders": 5,
///   "status": "active" | "banned"
/// }]

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  /// Load all users from backend
  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Replace with actual API call
      // GET /api/admin/users
      // final response = await http.get(
      //   Uri.parse('http://localhost:3000/api/admin/users'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );
      // final users = jsonDecode(response.body);

      // Mock data for now
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _users = [
          {
            'id': 'user_001',
            'name': 'Joshua Santos',
            'email': 'joshua@email.com',
            'phoneNumber': '09171234567',
            'joinDate': '2024-01-15',
            'totalOrders': 12,
            'status': 'active',
          },
          {
            'id': 'user_002',
            'name': 'Ken Reyes',
            'email': 'ken@email.com',
            'phoneNumber': '09187654321',
            'joinDate': '2024-02-20',
            'totalOrders': 3,
            'status': 'active',
          },
          {
            'id': 'user_003',
            'name': 'Orlie Cruz',
            'email': 'orlie@email.com',
            'phoneNumber': '09191112222',
            'joinDate': '2024-03-10',
            'totalOrders': 0,
            'status': 'banned',
          },
        ];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
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
                  : _users.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      color: const Color(0xFFEDFF00),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return _buildUserCard(user);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
            'Manage Users',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'kobe11',
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUsers,
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final status = user['status'] as String;
    final isActive = status.toLowerCase() == 'active';

    return GestureDetector(
      onTap: () async {
        // Navigate to user details
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserDetailsScreen(user: user)),
        );
        // Refresh list when returning in case status changed
        _loadUsers();
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // User Icon (no image as per requirement)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white54, size: 32),
            ),
            const SizedBox(width: 16),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Name
                      Expanded(
                        child: Text(
                          user['name'] ?? 'Unknown User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'kobe11Bold',
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFEDFF00)
                              : Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: isActive ? Colors.black : Colors.white,
                            fontFamily: 'kobe11Bold',
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Email
                  Text(
                    user['email'] ?? 'No email',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'kobe11',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Join Date and Total Orders
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white54,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Joined: ${user['joinDate'] ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontFamily: 'kobe11',
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.shopping_bag,
                        color: Colors.white54,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user['totalOrders'] ?? 0} orders',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontFamily: 'kobe11',
                          fontSize: 12,
                        ),
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
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.people_outline, size: 80, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'kobe11',
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
