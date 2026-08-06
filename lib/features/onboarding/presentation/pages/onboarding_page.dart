import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storyn/core/theme/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      bookImages: [
        'assets/images/onboarding/books/book_1.png',
        'assets/images/onboarding/books/book_2.png',
        'assets/images/onboarding/books/book_3.png',
        'assets/images/onboarding/books/book_4.png',
        'assets/images/onboarding/books/book_5.png',
        'assets/images/onboarding/books/book_6.png',
        'assets/images/onboarding/books/book_7.png',
        'assets/images/onboarding/books/book_8.png',
        'assets/images/onboarding/books/book_9.png',
      ],
      topColor: Color(0xFFA0CFD4),
      cardColor: Color(0xFFDEEDEF),
      title: 'Your Personal Reading Space',
      description:
      'Organize your books, import EPUB files, and keep your reading journey in one place.',
      buttonText: 'Next',
    ),
    _OnboardingData(
      image: 'assets/images/onboarding/onboarding_2.png',
      topColor: Color(0xFFDEEDEF),
      cardColor: Color(0xFFA0CFD4),
      title: 'Read Without Limits',
      description:
      'Import your own EPUB books, enjoy a distraction-free reader, and automatically save your reading progress.',
      buttonText: 'Continue',
    ),
    _OnboardingData(
      image: 'assets/images/onboarding/onboarding_3.png',
      topColor: Color(0xFFA0CFD4),
      cardColor: Color(0xFFDEEDEF),
      title: 'Build Your Reading Habit',
      description:
      'Organize books into shelves, rate your favorites, write reviews, and continue exactly where you left off.',
      buttonText: 'Get Started',
    ),
  ];

  void _onButtonPressed() {
    if (_currentPage == _pages.length - 1) {
      context.go('/welcome');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pages[_currentPage].topColor,
      body: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) {
          final page = _pages[index];
          return Column(
            children: [
              Expanded(
                flex: 8,
                child: Container(
                  width: double.infinity,
                  color: page.topColor,
                  child: page.bookImages != null
                      ? _buildBookGrid(page.bookImages!)
                      : Transform.translate(
                    offset: const Offset(0, 35), // Move image down
                    child: Image.asset(
                      page.image!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    ),
                  )
                ),
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  decoration: BoxDecoration(
                    color: page.cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        page.title,
                        style: const TextStyle(
                            fontFamily: 'Playfair',
                            fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        page.description,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _onButtonPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.onboardingButton,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            page.buttonText,
                            style: const TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(child: _buildDots()),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookGrid(List<String> images) {
    final row1 = images.sublist(0, 3);
    final row2 = images.sublist(3, 6);
    final row3 = images.sublist(6, 9);

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;

        return ClipRect(
          child: Stack(
            children: [
              Positioned(
                left: -55,
                top: h * 0.01,
                child: Transform.rotate(
                  angle: -0.25,
                  child: _bookRow(row1),
                ),
              ),

              Positioned(
                left: 5,
                top: h * 0.35,
                child: Transform.rotate(
                  angle: -0.25,
                  child: _bookRow(row2),
                ),
              ),

              Positioned(
                left: 5,
                top: h * 0.72,
                child: Transform.rotate(
                  angle: -0.25,
                  child: _bookRow(row3),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bookRow(List<String> images) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: images.map((img) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                img,
                width: 110,
                height: 165,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_pages.length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.dotActive
                : AppColors.dotInactive,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _OnboardingData {
  final String? image;
  final List<String>? bookImages;
  final Color topColor;
  final Color cardColor;
  final String title;
  final String description;
  final String buttonText;

  const _OnboardingData({
    this.image,
    this.bookImages,
    required this.topColor,
    required this.cardColor,
    required this.title,
    required this.description,
    required this.buttonText,
  });
}