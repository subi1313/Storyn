import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class EpubReaderPlaceholderPage extends StatelessWidget {
  final String title;
  final String epubPath;
  const EpubReaderPlaceholderPage({super.key, required this.title, required this.epubPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(backgroundColor: AppColors.white, elevation: 0, title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book, size: 56, color: AppColors.onboardingButton),
              const SizedBox(height: 16),
              const Text(
                'In-app EPUB reading is coming soon.\nYour file has been imported and saved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(epubPath, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.dotActive)),
            ],
          ),
        ),
      ),
    );
  }
}