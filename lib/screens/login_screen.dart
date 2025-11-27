import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false; // Password visibility toggle state
  String? _errorMessage; // Error message to show under password field

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showSuccessModal(String role) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFFEDFF00), size: 64),
            const SizedBox(height: 16),
            const Text(
              'Success!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Logged in successfully',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog

                  if (role == 'admin') {
                    Navigator.pushReplacementNamed(context, '/admin');
                  } else {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEDFF00),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show loading modal while API request is processing
  void _showLoadingModal(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEDFF00)),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show forgot password modal
  void _showForgotPasswordModal() {
    final emailCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reset Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your email to receive a password reset link',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Colors.white70,
                ),
                hintText: 'Email',
                hintStyle: const TextStyle(color: Colors.white38),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDFF00)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Placeholder - backend will implement later
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset coming soon'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEDFF00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Send Reset Link',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Login logic with error handling
  Future<void> _login() async {
    // Clear previous errors
    setState(() => _errorMessage = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    setState(() => _isLoading = true);

    // Show loading modal
    _showLoadingModal('Logging in...');

    try {
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final token = await userCred.user?.getIdToken();

      final res = await http.post(
        Uri.parse('http://localhost:3000/api/user/login'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );

      // Close loading modal
      if (mounted) Navigator.pop(context);

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        print('LOGIN RESPONSE BODY: $body'); // DEBUG
        
        // Check for role at root level OR inside user object
        final String role = body['role'] ?? body['user']?['role'] ?? 'user';
        
        print('PARSED ROLE: $role'); // DEBUG
        await AuthService.saveRole(role);

        setState(() => _isLoading = false);
        if (mounted) {
          // Show success modal
          _showSuccessModal(role);
        }
      } else {
        setState(() {
          _errorMessage = 'Login failed. Please try again.';
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      // Close loading modal
      if (mounted) Navigator.pop(context);

      // Try traditional login (for users who reset password)
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        try {
          final res = await AuthService.loginWithTraditional(email, password);
          
          if (res['statusCode'] == 200) {
            final Map<String, dynamic> body = jsonDecode(res['body']);
            final String role = body['role'] ?? body['user']?['role'] ?? 'user';
            await AuthService.saveRole(role);

            setState(() => _isLoading = false);
            if (mounted) {
              _showSuccessModal(role);
            }
            return; // Success, exit function
          }
        } catch (_) {
          // Traditional login also failed, show original error
        }
      }

      setState(() {
        _isLoading = false;
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          _errorMessage = "The password you've entered is incorrect";
        } else if (e.code == 'user-not-found') {
          _errorMessage = 'No account found with this email';
        } else {
          _errorMessage = 'Login failed. Please try again.';
        }
      });
    } catch (e) {
      // Close loading modal
      if (mounted) Navigator.pop(context);

      setState(() {
        _isLoading = false;
        _errorMessage = 'Check your internet connection';
      });
    }
  }

  // Google Sign-In implementation using Firebase popup (better for web)
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    // Show loading modal
    _showLoadingModal('Signing in with Google...');

    try {
      // Create Google Auth Provider
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Add scopes if needed
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      // Sign in with popup (works better on web than google_sign_in package)
      UserCredential userCred = await FirebaseAuth.instance.signInWithPopup(
        googleProvider,
      );

      // Get Firebase token
      final token = await userCred.user?.getIdToken();

      // Send token to backend
      final res = await http.post(
        Uri.parse('http://localhost:3000/api/user/login'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );

      // Close loading modal
      if (mounted) Navigator.pop(context);

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        
        // Check for role at root level OR inside user object
        final String role = body['role'] ?? body['user']?['role'] ?? 'user';
        
        await AuthService.saveRole(role);

        setState(() => _isLoading = false);
        if (mounted) {
          // Show success modal and navigate to home
          _showSuccessModal(role);
        }
      } else {
        setState(() {
          _errorMessage = 'Login failed. Please try again.';
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      // Close loading modal
      if (mounted) Navigator.pop(context);

      setState(() {
        _isLoading = false;
        if (e.code == 'popup-closed-by-user') {
          _errorMessage = null; // User cancelled, don't show error
        } else {
          _errorMessage = 'Google Sign-In failed: ${e.message}';
        }
      });
    } catch (e) {
      // Close loading modal
      if (mounted) Navigator.pop(context);

      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button + Title
                Row(
                  children: [
                    InkWell(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/home'),
                      borderRadius: BorderRadius.circular(40),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[800],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Log In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Logo
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Email field
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Colors.white70,
                    ),
                    hintText: 'Username/Email',
                    hintStyle: const TextStyle(color: Colors.white38),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFEDFF00)),
                    ),
                    errorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter email';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Password field with visibility toggle
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _passwordCtrl,
                      obscureText: !_isPasswordVisible,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => setState(() => _errorMessage = null),
                      onFieldSubmitted: (_) => _login(),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.white70,
                        ),
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: Colors.white38),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFEDFF00)),
                        ),
                        errorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        // Show loading indicator over password field when logging in
                        suffixIcon: _isLoading
                            ? Container(
                                width: 50,
                                padding: const EdgeInsets.all(12),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFEDFF00),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter password' : null,
                    ),
                    // Password visibility toggle (only show when NOT loading)
                    if (!_isLoading)
                      Positioned(
                        right: 0,
                        child: IconButton(
                          onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                  ],
                ),

                // Error message (shows under password field)
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Log In button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      disabledBackgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _isLoading ? 'Logging in...' : 'Log In',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Google Sign-In Button (Placeholder)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(
                      Icons.g_mobiledata_sharp, // temp icon
                      color: Colors.white,
                      size: 28,
                    ),
                    label: const Text(
                      'Continue with Google',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Navigate to Register
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
