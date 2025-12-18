import 'package:flutter/material.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/ui/auth/start_page.dart';
import 'package:wello_frontend/ui/main_navigation_screen.dart';

/// Splash screen kiểm tra authentication khi app khởi động
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Đợi 1.5 giây để show splash (optional)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Check authentication status
    final isAuthenticated = await AuthHelper.isAuthenticated();

    if (isAuthenticated) {
      // Có token → Navigate to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainNavigationScreen()),
      );
    } else {
      // Không có token → Navigate to StartPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StartPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEA), // Light cream background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo hoặc app name
            Text(
              'Wello',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFEBCF23),
                fontFamily: 'Pacifico',
              ),
            ),
            const SizedBox(height: 24),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFFEBCF23)),
            ),
          ],
        ),
      ),
    );
  }
}
