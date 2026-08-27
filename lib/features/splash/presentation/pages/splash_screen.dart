import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_session_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _circleRadius;
  late final Animation<double> _logoScale;
  late final Animation<Alignment> _logoAlignment;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  static const Color kDarkGreen = Color(0xFF0D282B);

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
      curve: const Interval(
        0.20,
        0.55,
        curve: Curves.easeInOutCubic,
      ),
    );

    _logoScale = Tween<double>(
      begin: 1.0,
      end: 0.60,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.55,
          0.75,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _logoAlignment = Tween<Alignment>(
      begin: Alignment.center,
      end: const Alignment(-0.5, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.55,
          0.75,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.70,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(24, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.70,
          1.0,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;

          _decideNextRoute(context);
        });
      }
    });
  }

  Future<void> _decideNextRoute(BuildContext context) async {
    final authSession = context.read<AuthSessionProvider>();

    if (!authSession.hasSeenOnboarding) {
      if (!mounted) return;
      context.go('/onboarding');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      context.go('/welcome');
      return;
    }

    final sessionValid = await authSession.isSessionValid();

    if (!mounted) return;

    if (sessionValid) {
      context.go('/home');
    } else {
      context.go('/welcome');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final maxRadius =
        sqrt(pow(size.width, 2) + pow(size.height, 2)) * 1.8;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F9),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: const Color(0xFFF3F8F9),
          ),

          AnimatedBuilder(
            animation: _circleRadius,
            builder: (_, __) {
              return ClipPath(
                clipper: CircleRevealClipper(
                  _circleRadius.value,
                ),
                child: Container(
                  color: kDarkGreen,
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
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (_textOpacity.value > 0) ...[
                      const SizedBox(width: 1),
                      Transform.translate(
                        offset: const Offset(-12, 0),
                        child: ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: _textOpacity.value,
                            child: const Text(
                              'Storyn',
                              style: TextStyle(
                                fontFamily: 'Jura',
                                fontSize: 40,
                                fontWeight: FontWeight.w200,
                                color: Color(0xFFF3F8F9),
                              ),
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

class CircleRevealClipper extends CustomClipper<Path> {
  final double progress;

  CircleRevealClipper(this.progress);

  @override
  Path getClip(Size size) {
    final center = size.center(Offset.zero);

    final maxRadius =
    sqrt(size.width * size.width + size.height * size.height);

    return Path()
      ..addOval(
        Rect.fromCircle(
          center: center,
          radius: maxRadius * progress,
        ),
      );
  }

  @override
  bool shouldReclip(CircleRevealClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}