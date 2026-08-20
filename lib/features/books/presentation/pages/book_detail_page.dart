import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../library/domain/entities/saved_book.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../../domain/entities/book.dart';
import '../widgets/reading_status_selector.dart';

class BookDetailPage extends StatefulWidget {
  final Book book;
  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  bool _descriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final libraryProvider = context.watch<LibraryProvider>();
    final isSaved = libraryProvider.isSaved(book.id);

    final hasDescription = book.description.trim().isNotEmpty &&
        book.description.trim().toLowerCase() != 'no description available.';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            pinned: true,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            actions: [
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: AppColors.onboardingButton,
                ),
                onPressed: () async {
                  final savedBook = SavedBook(
                    id: book.id,
                    title: book.title,
                    authors: book.authors,
                    thumbnailUrl: book.thumbnailUrl,
                    description: book.description,
                    savedAt: DateTime.now(),
                  );
                  final wasSaved = isSaved;
                  await context.read<LibraryProvider>().toggleSave(savedBook);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(wasSaved ? 'Removed from library' : 'Saved to library'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: AppColors.onboardingButton,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover + title/author side-by-side
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: book.thumbnailUrl != null
                            ? Image.network(
                          book.thumbnailUrl!,
                          width: 120,
                          height: 168,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          width: 120,
                          height: 168,
                          color: AppColors.dotInactive,
                          child: const Icon(Icons.book, size: 40),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              book.authors,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (book.pageCount > 0)
                              _MetaChip(label: '${book.pageCount} pages'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ReadingStatusSelector(book: book),
                  const SizedBox(height: 28),
                  Container(height: 1, color: AppColors.dotInactive),
                  const SizedBox(height: 24),

                  const Text(
                    'About this book',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (!hasDescription)
                    const Text(
                      'No description available for this book yet.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.dotActive,
                      ),
                    )
                  else
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 200),
                      crossFadeState: _descriptionExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: Text(
                        book.description,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          height: 1.55,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      secondChild: Text(
                        book.description,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          height: 1.55,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                  // Only show the toggle if the description is actually long enough to need it
                  if (hasDescription && book.description.length > 260)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
                        child: Text(
                          _descriptionExpanded ? 'Show less' : 'Read more',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onboardingButton,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.textSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textPrimary),
      ),
    );
  }
}