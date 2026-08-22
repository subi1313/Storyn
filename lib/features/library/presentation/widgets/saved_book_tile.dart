import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/saved_book.dart';
import '../providers/library_provider.dart';
import '../pages/epub_reader_placeholder_page.dart';

class SavedBookTile extends StatelessWidget {
  final SavedBook book;
  final List<String> tags;
  const SavedBookTile({super.key, required this.book, this.tags = const []});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.textSecondary, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: book.thumbnailUrl != null
                ? Image.network(book.thumbnailUrl!, width: 60, height: 84, fit: BoxFit.cover)
                : Container(width: 60, height: 84, color: AppColors.dotInactive),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(book.authors, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                if (book.description.trim().isNotEmpty && book.description.trim() != 'No description available.')
                  Text(book.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.dotActive, height: 1.3)),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.dotInactive, borderRadius: BorderRadius.circular(6)),
                      child: Text(tag, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.dotActive)),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    if (book.epubPath != null) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => EpubReaderPlaceholderPage(title: book.title, epubPath: book.epubPath!),
                      ));
                    } else {
                      context.read<LibraryProvider>().importEpub(book);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(book.epubPath != null ? Icons.menu_book : Icons.upload_file, size: 14, color: AppColors.onboardingButton),
                      const SizedBox(width: 4),
                      Text(book.epubPath != null ? 'Open EPUB' : 'Import EPUB',
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onboardingButton)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.dotActive),
            onPressed: () => _confirmRemove(context),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Remove from library?', style: TextStyle(fontFamily: 'Poppins', fontSize: 15)),
        content: Text(book.title, style: const TextStyle(fontFamily: 'Inter', fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<LibraryProvider>().removeSavedBook(book.id);
              Navigator.pop(dialogContext);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}