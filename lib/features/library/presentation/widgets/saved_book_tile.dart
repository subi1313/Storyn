import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/reading_status.dart';
import '../../domain/entities/saved_book.dart';

class SavedBookTile extends StatelessWidget {
  final SavedBook book;
  const SavedBookTile({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.textSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
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
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  book.authors,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                if (book.status != ReadingStatus.none)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.dotInactive,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _statusLabel(book.status),
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.dotActive),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.planToRead:
        return 'Plan to read';
      case ReadingStatus.currentlyReading:
        return 'Currently reading';
      case ReadingStatus.completed:
        return 'Completed';
      case ReadingStatus.none:
        return '';
    }
  }
}