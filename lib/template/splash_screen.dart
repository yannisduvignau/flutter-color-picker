import 'dart:async';
import 'package:flutter/material.dart';
import 'color_picker_app.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ColorPickerApp()),
      );
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
      backgroundColor: const Color.fromARGB(255, 40, 136, 214),
      body: Center(
          child: FadeTransition(
        opacity: _fadeAnimation,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.color_lens,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'COLOR PICKER APP',
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'FugazOne',
                color: Colors.white,
              ),
            ),
          ],
        ),
      )),
    );
  }
}
