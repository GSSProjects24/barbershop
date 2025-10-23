import 'package:babershop_project/App/Controller/splash/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:babershop_project/App/helper/route_hepler.dart';

import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final AuthRepo authRepo = AuthRepo();

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

      bool firstTime = await authRepo.isFirstTimeLaunch();
      bool loggedIn = await authRepo.isLoggedIn();

      if (firstTime) {
        await authRepo.saveIsFirstTimeLaunch();
        RouteHelper.replace(name: RouteHelper.login);
      } else if (loggedIn) {
        // Already logged in → go to BarberSelection
        RouteHelper.replace(name: RouteHelper.barberSelection);
      } else {
        RouteHelper.replace(name: RouteHelper.login);
      }
    });

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
