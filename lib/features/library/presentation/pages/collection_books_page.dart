import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/reading_status.dart';
import '../providers/library_provider.dart';
import '../widgets/saved_book_tile.dart';

enum LibraryFilterType { all, status, collection }

class CollectionBooksPage extends StatelessWidget {
  final String title;
  final LibraryFilterType filterType;
  final ReadingStatus? status;
  final String? collectionId;

  const CollectionBooksPage({
    super.key,
    required this.title,
    required this.filterType,
    this.status,
    this.collectionId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LibraryProvider>();

    final books = switch (filterType) {
      LibraryFilterType.all => provider.savedBooks,
      LibraryFilterType.status => provider.booksByStatus(status!),
      LibraryFilterType.collection => provider.booksInCollection(collectionId!),
    };

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, color: AppColors.textPrimary)),
      ),
      body: books.isEmpty
          ? const Center(child: Text('No books here yet.', style: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary)))
          : ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final book = books[index];
          final tags = _buildTags(book, provider);
          return SavedBookTile(book: book, tags: tags);
        },
      ),
    );
  }

  List<String> _buildTags(book, LibraryProvider provider) {
    final tags = <String>[];
    if (book.status != ReadingStatus.none) {
      tags.add(_statusLabel(book.status));
    }
    for (final id in book.collectionIds) {
      final match = provider.collections.where((c) => c.id == id);
      if (match.isNotEmpty) tags.add(match.first.name);
    }
    return tags;
  }

  String _statusLabel(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.planToRead: return 'Plan to read';
      case ReadingStatus.currentlyReading: return 'Currently reading';
      case ReadingStatus.completed: return 'Completed';
      case ReadingStatus.none: return '';
    }
  }
}