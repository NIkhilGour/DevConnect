import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotsController;
  late Animation<int> _dotsAnimation;

  @override
  void initState() {
    super.initState();

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _dotsAnimation = StepTween(begin: 0, end: 3).animate(_dotsController);
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  String get loadingText {
    const base = 'Loading';
    final dots = '.' * (_dotsAnimation.value + 1);
    return '$base$dots';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE8F7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/DevConnect.png',
            ),
            const SizedBox(height: 30),

            // Loading Dots
            AnimatedBuilder(
              animation: _dotsAnimation,
              builder: (context, child) {
                return Text(
                  loadingText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.deepPurple,
                    letterSpacing: 1.2,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
