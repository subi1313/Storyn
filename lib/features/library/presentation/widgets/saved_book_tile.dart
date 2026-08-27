import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/presentation/pages/book_detail_page.dart';
import '../../domain/entities/saved_book.dart';
import '../providers/library_provider.dart';
import '../pages/epub_reader_page.dart';
import '../widgets/rating_review_sheet.dart';

class SavedBookTile extends StatelessWidget {
  final SavedBook book;
  final List<String> tags;

  const SavedBookTile({
    super.key,
    required this.book,
    this.tags = const [],
  });

  bool get _hasLocalEpub {
    final path = book.epubPath;

    if (path == null || path.isEmpty) {
      return false;
    }

    return File(path).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    final hasLocalEpub = _hasLocalEpub;

    // Keep the value between 0 and 1.
    final progress = book.readingProgress.clamp(0.0, 1.0);

    // Convert to percentage.
    final progressPercentage = (progress * 100).round();

    return GestureDetector(
      // Long press anywhere on the book tile.
      onLongPress: () => _confirmRemove(context),

      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.textSecondary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            GestureDetector(
              onTap: () => _openDetail(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: book.thumbnailUrl != null
                    ? Image.network(
                  book.thumbnailUrl!,
                  width: 60,
                  height: 84,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 60,
                  height: 84,
                  color: AppColors.dotInactive,
                ),
              ),
            ),

            const SizedBox(width: 12),


            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  GestureDetector(
                    onTap: () => _openDetail(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          book.authors,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 4),

                        if (book.description.trim().isNotEmpty &&
                            book.description.trim() !=
                                'No description available.')
                          Text(
                            book.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: AppColors.dotActive,
                              height: 1.3,
                            ),
                          ),
                      ],
                    ),
                  ),


                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 6),

                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: tags
                          .map(
                            (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.dotInactive,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              color: AppColors.dotActive,
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 8),


                  GestureDetector(
                    onTap: () {
                      if (hasLocalEpub) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EpubReaderPage(
                              book: book,
                            ),
                          ),
                        );
                      } else {
                        context
                            .read<LibraryProvider>()
                            .importEpub(book);
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasLocalEpub
                              ? Icons.menu_book
                              : Icons.upload_file,
                          size: 14,
                          color: AppColors.onboardingButton,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          hasLocalEpub
                              ? 'Open EPUB'
                              : 'Import EPUB',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onboardingButton,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (progress > 0) ...[
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Text(
                          'Reading',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.dotActive,
                          ),
                        ),

                        const Spacer(),

                        Text(
                          '$progressPercentage% read',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onboardingButton,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: AppColors.dotInactive,
                        color: AppColors.onboardingButton,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: () => _openRatingReview(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          book.rating != null && book.rating! > 0
                              ? Icons.star
                              : Icons.star_border,
                          size: 15,
                          color: AppColors.onboardingButton,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          book.rating != null && book.rating! > 0
                              ? '${book.rating!.toStringAsFixed(1)} / 5'
                              : 'Rate & review',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onboardingButton,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (book.reviewText != null &&
                      book.reviewText!.trim().isNotEmpty) ...[
                    const SizedBox(height: 5),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.rate_review_outlined,
                          size: 13,
                          color: AppColors.dotActive,
                        ),

                        const SizedBox(width: 5),

                        Expanded(
                          child: Text(
                            book.reviewText!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              color: AppColors.dotActive,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    final bookEntity = Book(
      id: book.id,
      title: book.title,
      authors: book.authors,
      thumbnailUrl: book.thumbnailUrl,
      description: book.description,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookDetailPage(
          book: bookEntity,
        ),
      ),
    );
  }

  void _openRatingReview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) => RatingReviewSheet(
        book: book,
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,

        title: const Text(
          'Remove from library?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
          ),
        ),

        content: Text(
          book.title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),

          TextButton(
            onPressed: () {
              context
                  .read<LibraryProvider>()
                  .removeSavedBook(book.id);

              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Remove',
              style: TextStyle(
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}