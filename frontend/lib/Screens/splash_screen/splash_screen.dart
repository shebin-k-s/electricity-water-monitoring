import 'package:flutter/material.dart';
import 'package:saron/Screens/auth_screen/auth_screen.dart';
import 'package:saron/Screens/main_sceen/main_screen.dart';
import 'package:saron/api/data/device.dart';
import 'package:saron/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    
    _animationController.forward();
    UserLoggedIn();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: Image.asset(
                "assets/images/saron.png",
              ),
            );
          },
        ),
      ),
    );
  }

  void UserLoggedIn() async {
    final sharedPref = await SharedPreferences.getInstance();
    final userLoggedIn = sharedPref.getString(TOKEN);

    await Future.delayed(const Duration(milliseconds: 1000));

    if (userLoggedIn == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => AuthScreen(),
        ),
      );
    } else {
      await DeviceDB().getDevices();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => MainScreen(),
        ),
      );
    }
  }
}