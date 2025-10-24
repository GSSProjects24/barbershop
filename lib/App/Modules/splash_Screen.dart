import 'package:babershop_project/App/provider/sharedprefference.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:babershop_project/App/helper/route_hepler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward().then((_) async {
      await Future.delayed(const Duration(seconds: 2));
      await _checkAuthStatus();
    });
  }

  // ✅ Check authentication status
  Future<void> _checkAuthStatus() async {
    try {
      // ✅ Direct access since SharedPrefService is already initialized in main.dart
      final token = SharedPrefService.instance.getToken();
      final userId = SharedPrefService.instance.getUserId();

      print('🔍 Splash: Checking auth status...');
      print('📱 Token exists: ${token != null && token.isNotEmpty}');
      print('👤 User ID: $userId');

      if (token != null && token.isNotEmpty && userId != null) {
        // User is logged in
        print('✅ User is logged in, navigating to BarberSelection');
        RouteHelper.replace(name: RouteHelper.barberSelection);
      } else {
        // User is not logged in
        print('❌ User not logged in, navigating to Login');
        RouteHelper.replace(name: RouteHelper.login);
      }
    } catch (e) {
      print('❌ Error checking auth status: $e');
      // On error, go to login screen
      RouteHelper.replace(name: RouteHelper.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset(
            'images/logo.jpg',
            width: 160,
            height: 160,
          ),
        ),
      ),
    );
  }
}