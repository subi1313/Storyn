import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D282B),
      body: Center(
        child: Text(
          'Onboarding goes here',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}