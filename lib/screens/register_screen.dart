import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Form and Controller Initialization
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    // Clean up controllers to free resources
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ─── REGISTRATION LOGIC ────────────────────────────────────────────────────
  Future<void> _submit() async {
    // Input Validation: Verify all fields meet requirements before making requests
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    setState(() => _isLoading = true);

    try {
      // Step 1: Firebase Account Creation
      // Create the user in Firebase Authentication first
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Step 2: Token Retrieval
      // Obtain the secure ID token to authenticate with the custom backend
      final token = await userCred.user?.getIdToken();

      print(
        '🔥 Firebase ID Token: $token',
      ); // Debug: Token for manual API testing

      // Step 3: Backend Sync (MongoDB Registration)
      // Send the new user data/token to the backend API to create a database record
      final res = await http.post(
        Uri.parse(
          'http://localhost:3000/api/user/register',
        ), // Note: Use 10.0.2.2 for Android emulator
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}), // Body empty as token carries identity
      );

      print('📡 Backend response: ${res.body}'); // Debug: API Response log

      // Response Handling
      if (res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Registered successfully!')),
        );
        // Navigate to the landing page/home and remove register screen from stack
        Navigator.pushReplacementNamed(context, '/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Backend error: ${res.body}')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase errors (e.g., email already in use)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase Auth Error: ${e.message}')),
      );
    } catch (e) {
      // Handle general errors (e.g., network failure)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
    } finally {
      // Stop loading indicator
      setState(() => _isLoading = false);
    }

    print('🚀 Submit button pressed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      // Main Layout
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── INPUT FIELDS ─────────────────────────────────────────────

              // Email Input
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter email';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Password Input
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter password';
                  if (v.length < 6) return 'Password too short';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Confirm Password Input
              TextFormField(
                controller: _confirmCtrl,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirm password';
                  if (v != _passwordCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ─── ACTION BUTTONS ───────────────────────────────────────────

              // Register Button: Triggers the registration flow
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Register'),
              ),
              const SizedBox(height: 12),

              // Navigation Button: returns to Login screen
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
