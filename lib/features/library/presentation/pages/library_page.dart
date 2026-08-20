import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/library_provider.dart';
import '../widgets/saved_book_tile.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryProvider>().loadLibrary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LibraryProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Library',
              style: TextStyle(
                fontFamily: 'Playfair',
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(LibraryProvider provider) {
    switch (provider.status) {
      case LibraryStatus.loading:
      case LibraryStatus.initial:
        return const Center(child: CircularProgressIndicator());
      case LibraryStatus.error:
        return Center(child: Text(provider.errorMessage, style: const TextStyle(fontFamily: 'Inter')));
      case LibraryStatus.loaded:
        if (provider.savedBooks.isEmpty) {
          return const Center(
            child: Text(
              'No books saved yet.\nTap the bookmark icon on any book to add it here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textPrimary),
            ),
          );
        }
        return ListView.separated(
          itemCount: provider.savedBooks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => SavedBookTile(book: provider.savedBooks[index]),
        );
    }
  }
}