import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../library/domain/entities/reading_status.dart';
import '../../../library/domain/entities/saved_book.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../../domain/entities/book.dart';

class ReadingStatusSelector extends StatelessWidget {
  final Book book;
  const ReadingStatusSelector({super.key, required this.book});

  static const _options = [
    (status: ReadingStatus.planToRead, label: 'Plan to read', icon: Icons.bookmark_add_outlined),
    (status: ReadingStatus.currentlyReading, label: 'Currently reading', icon: Icons.menu_book_outlined),
    (status: ReadingStatus.completed, label: 'Completed', icon: Icons.check_circle_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LibraryProvider>();
    final currentStatus = provider.statusFor(book.id);

    return Row(
      children: _options.map((option) {
        final isSelected = currentStatus == option.status;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                final savedBook = SavedBook(
                  id: book.id,
                  title: book.title,
                  authors: book.authors,
                  thumbnailUrl: book.thumbnailUrl,
                  description: book.description,
                  savedAt: DateTime.now(),
                );
                // Tapping the already-selected status clears it back to "none"
                final newStatus = isSelected ? ReadingStatus.none : option.status;
                context.read<LibraryProvider>().setStatus(savedBook, newStatus);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.onboardingButton : AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      option.icon,
                      size: 18,
                      color: isSelected ? AppColors.white : AppColors.textPrimary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}