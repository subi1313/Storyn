import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _circleRadius; // 0 -> 1 (fraction of max radius)
  late final Animation<double> _logoScale; // 1.0 -> 0.55
  late final Animation<Alignment> _logoAlignment; // center -> left-of-center
  late final Animation<double> _textOpacity; // 0 -> 1
  late final Animation<Offset> _textSlide; // slide in from the right

  static const Color kDarkGreen = Color(0xFF1B4332);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // 0.00-0.20 hold on white  |  0.20-0.55 circle expands
    // 0.55-0.75 logo shrinks + shifts left  |  0.70-1.00 text fades/slides in
    _circleRadius = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.20, 0.55, curve: Curves.easeInOutCubic),
    );

    _logoScale = Tween<double>(begin: 1.0, end: 0.55).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.75, curve: Curves.easeOutBack),
      ),
    );

    _logoAlignment = Tween<Alignment>(
      begin: Alignment.center,
      end: const Alignment(-0.35, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.70, 1.0, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(24, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.70, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          context.go('/onboarding');
        });
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
    final size = MediaQuery.of(context).size;
    final maxRadius = sqrt(pow(size.width, 2) + pow(size.height, 2)) * 1.1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.white),

          AnimatedBuilder(
            animation: _circleRadius,
            builder: (context, child) {
              final radius = _circleRadius.value * maxRadius;
              return Center(
                child: Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: const BoxDecoration(
                    color: kDarkGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),

          // Logo + animated "Storyn" text
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Align(
                alignment: _logoAlignment.value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: _logoScale.value,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24), // Adjust as needed
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (_textOpacity.value > 0) ...[
                      const SizedBox(width: 10),
                      Opacity(
                        opacity: _textOpacity.value,
                        child: Transform.translate(
                          offset: _textSlide.value,
                          child: const Text(
                            'Storyn',
                            style: TextStyle(
                              fontFamily: 'Storyn', // must match pubspec family name
                              fontSize: 34,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}