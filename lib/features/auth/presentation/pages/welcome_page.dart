import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.authGradient),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 95),
        child: Column(
          children: [
            const Spacer(flex: 2),
            const Text(
              'Welcome To Storyn',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Playfair',
                  fontSize: 36,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Discover, organize, and enjoy your favorite books in one place. '
                  'Import EPUBs, track your reading progress, and build your personal digital library.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 32),
            Image.asset('assets/images/auth/bookshelf.png', height: 220),
            const Spacer(flex: 3),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.go('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Create Account', style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: AppColors.textPrimary)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => context.go('/login'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.white),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Log In', style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: AppColors.textSecondary)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}