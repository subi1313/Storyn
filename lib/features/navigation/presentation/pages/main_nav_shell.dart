import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../books/presentation/pages/explore_page.dart';
import '../../../books/presentation/providers/books_provider.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../library/presentation/pages/library_page.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../widgets/app_bottom_nav.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class MainNavShell extends StatelessWidget {
  const MainNavShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<BooksProvider>()..loadHomeSections()),
        ChangeNotifierProvider(create: (_) => sl<LibraryProvider>()..loadLibrary()),
      ],
      child: const _MainNavShellView(),
    );
  }
}

class _MainNavShellView extends StatefulWidget {
  const _MainNavShellView();

  @override
  State<_MainNavShellView> createState() => _MainNavShellViewState();
}

class _MainNavShellViewState extends State<_MainNavShellView> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ExplorePage(),
    LibraryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile — coming soon', style: TextStyle(fontFamily: 'Inter')));
  }
}