import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../books/presentation/providers/books_provider.dart';
import '../../../books/presentation/widgets/book_shelf_section.dart';
import '../../../books/presentation/widgets/mood_chip.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<BooksProvider>()..loadHomeSections(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _navIndex = 0;

  final List<Map<String, dynamic>> _moods = [
    {'label': 'cozy', 'icon': Icons.local_cafe_outlined},
    {'label': 'dark', 'icon': Icons.dark_mode_outlined},
    {'label': 'spicy', 'icon': Icons.local_fire_department_outlined},
    {'label': 'funny', 'icon': Icons.sentiment_satisfied_alt_outlined},
    {'label': 'emotional', 'icon': Icons.favorite_border},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BooksProvider>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          children: [
            const Text(
              'Storyn',
              style: TextStyle(
                fontFamily: 'Playfair',
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'how are you feeling?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              'choose a vibe or trope',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _moods.map((mood) {
                return MoodChip(
                  label: mood['label'],
                  icon: mood['icon'],
                  isSelected: provider.selectedMood == mood['label'],
                  onTap: () => context.read<BooksProvider>().searchByMood(mood['label']),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            for (final section in provider.sections) BookShelfSection(section: section),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
        selectedItemColor: AppColors.onboardingButton,
        unselectedItemColor: AppColors.dotInactive,
        backgroundColor: AppColors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: 'Shelves'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}