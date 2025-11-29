import 'package:csoles_application/screens/home_screen.dart';
import 'package:csoles_application/screens/owner_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // generated file

import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';

import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); // Enable path-based routing (removes # from URLs)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Auth App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        dialogBackgroundColor: Colors.grey[900],
        cardColor: Colors.grey[900],
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/admin': (context) => const DashboardScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle deep link for reset password
        if (settings.name != null && settings.name!.startsWith('/reset-password')) {
          final uri = Uri.parse(settings.name!);
          if (uri.queryParameters.containsKey('token') &&
              uri.queryParameters.containsKey('id')) {
            return MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(
                token: uri.queryParameters['token'],
                userId: uri.queryParameters['id'],
              ),
            );
          }
        }
        return null;
      },
    );
  }
}
