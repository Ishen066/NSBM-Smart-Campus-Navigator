
import 'package:flutter/material.dart';

import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Navigate to Login Screen
  void _getStarted() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Campus Background
          Image.asset(
            'assets/images/campus.jpg',
            fit: BoxFit.cover,
          ),

          // Dark Background Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF001B32).withValues(alpha: 0.72),
                  const Color(0xFF003D35).withValues(alpha: 0.78),
                  const Color(0xFF001629).withValues(alpha: 0.94),
                ],
              ),
            ),
          ),

          // Decorative Glow
          Positioned(
            top: -100,
            right: -90,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38BDF8)
                    .withValues(alpha: 0.13),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // NSBM Official Logo
                    Container(
                      width: 145,
                      height: 145,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 35,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/nsbm_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'NSBM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'SMART CAMPUS',
                      style: TextStyle(
                        color: Color(0xFF8BE0BD),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      width: 55,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Your Campus, One Step Away',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Get Started Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _getStarted,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8BE0BD),
                            foregroundColor: const Color(0xFF003D35),
                            elevation: 8,
                            shadowColor: const Color(0xFF8BE0BD)
                                .withValues(alpha: 0.30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'GET STARTED',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 21,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'NSBM GREEN UNIVERSITY',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
