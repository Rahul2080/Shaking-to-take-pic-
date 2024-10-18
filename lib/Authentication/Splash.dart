import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shakingpic/Home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Login.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Duration of the animation
      vsync: this,
    )..repeat(reverse: true); // Repeat the animation in reverse

    // Define the animation
    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(_controller);

    // Navigate after a delay
    Future.delayed(Duration(seconds: 3), () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey("userName")) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => Home()), (route) => false);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => Login()), (route) => false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value, // Apply scaling animation
              child: Image.asset('assets/splashimage.jpg',width: 100.w,height: 80.h,)

            );
          },
        ),
      ),
    );
  }
}
