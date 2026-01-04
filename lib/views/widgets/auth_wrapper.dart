import 'package:flutter/material.dart';
import '../../controllers/login_controller.dart';
import '../main_navigation.dart';
import '../screens/auth/login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final LoginController _loginController = LoginController();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final result = await _loginController.checkLoginStatus();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoggedIn = result.success;
        });

        // Show messages for different states
        if (result.type == LoginResultType.sessionExpired) {
          // Only show message if actually expired (not refreshed)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesi Anda telah berakhir. Silakan login kembali.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (result.success && result.user != null) {
          // Optional: Show welcome message for auto-login
          // Disabled by default to reduce noise
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('Selamat datang kembali, ${result.user!.displayName ?? result.user!.email}!'),
          //     backgroundColor: Colors.green,
          //     duration: const Duration(seconds: 2),
          //   ),
          // );
        }
      }
    } catch (e) {
      print('Error checking auth status: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoggedIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Memuat...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return _isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}