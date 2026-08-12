import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/book_section.dart';
import 'book_cover_card.dart';

class BookShelfSection extends StatelessWidget {
  final BookSection section;
  const BookShelfSection({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (section.status) {
      case SectionStatus.loading:
        return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
      case SectionStatus.error:
        return SizedBox(height: 60, child: Center(child: Text(section.errorMessage)));
      case SectionStatus.loaded:
        if (section.books.isEmpty) {
          return const SizedBox(height: 60, child: Center(child: Text('No books found.')));
        }
        return SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: section.books.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) => BookCoverCard(book: section.books[index]),
          ),
        );
      case SectionStatus.initial:
        return const SizedBox.shrink();
    }
  }
}