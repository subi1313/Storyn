import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../library/domain/entities/reading_status.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../../domain/entities/book.dart';
import '../widgets/add_to_library_sheet.dart';

class BookDetailPage extends StatefulWidget {
  final Book book;
  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  bool _descriptionExpanded = false;

  static const double _heroHeight = 220;
  static const double _thumbHeight = 150;
  static const double _thumbOverlap = 60; // how much thumbnail overlaps into hero

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final libraryProvider = context.watch<LibraryProvider>();
    final currentStatus = libraryProvider.statusFor(book.id);
    final isInLibrary = libraryProvider.isSaved(book.id);

    final hasDescription = book.description.trim().isNotEmpty &&
        book.description.trim().toLowerCase() != 'no description available.';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: hero image + overlapping thumbnail, all in ONE Stack, not split across slivers
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      height: _heroHeight,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          book.thumbnailUrl != null
                              ? Image.network(book.thumbnailUrl!, fit: BoxFit.cover)
                              : Container(color: AppColors.dotInactive),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.black.withOpacity(0.15), AppColors.white],
                                stops: const [0.0, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: -_thumbOverlap,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: book.thumbnailUrl != null
                            ? Image.network(book.thumbnailUrl!, width: 108, height: _thumbHeight, fit: BoxFit.cover)
                            : Container(width: 108, height: _thumbHeight, color: AppColors.dotInactive, child: const Icon(Icons.book)),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: SafeArea(
                        bottom: false,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.35),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Reserve space equal to the thumbnail's overlap so nothing sits underneath it
                SizedBox(height: _thumbOverlap + 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (currentStatus != ReadingStatus.none)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.onboardingButton, borderRadius: BorderRadius.circular(20)),
                          child: Text(_statusLabel(currentStatus), style: const TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.white)),
                        ),
                      Text(
                        book.title,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 21, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.25),
                      ),
                      const SizedBox(height: 6),
                      Text(book.authors, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textPrimary)),
                      const SizedBox(height: 14),
                      if (book.pageCount > 0 || book.publishedDate.isNotEmpty)
                        Row(
                          children: [
                            if (book.pageCount > 0) _MetaChip(label: '${book.pageCount} pages'),
                            if (book.pageCount > 0 && book.publishedDate.isNotEmpty) const SizedBox(width: 8),
                            if (book.publishedDate.isNotEmpty) _MetaChip(label: book.publishedDate),
                          ],
                        ),
                      const SizedBox(height: 24),
                      const Text('About this book', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 10),
                      if (!hasDescription)
                        const Text(
                          'No description available for this book yet.',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.dotActive),
                        )
                      else
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 200),
                          crossFadeState: _descriptionExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                          firstChild: Text(
                            book.description,
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.55, color: AppColors.textPrimary),
                          ),
                          secondChild: Text(
                            book.description,
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.55, color: AppColors.textPrimary),
                          ),
                        ),
                      if (hasDescription && book.description.length > 260)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
                            child: Text(
                              _descriptionExpanded ? 'Show less' : 'Read more',
                              style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onboardingButton),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInLibrary ? AppColors.dotActive : AppColors.onboardingButton,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                icon: Icon(isInLibrary ? Icons.check : Icons.add, color: AppColors.white),
                label: Text(
                  isInLibrary ? 'In your library' : 'Add to library',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: AppColors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (_) => AddToLibrarySheet(book: book),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
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

class _MetaChip extends StatelessWidget {
  final String label;
  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.textSecondary, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textPrimary)),
    );
  }
}