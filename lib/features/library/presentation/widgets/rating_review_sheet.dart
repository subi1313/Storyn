import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/saved_book.dart';
import '../providers/library_provider.dart';

/// Bottom sheet for setting a 1–5 star rating and a short text review on a
/// SavedBook. Requires `rating` (double?) and `reviewText` (String?) fields
/// on SavedBook + copyWith — see note in chat.
class RatingReviewSheet extends StatefulWidget {
  final SavedBook book;
  const RatingReviewSheet({super.key, required this.book});

  @override
  State<RatingReviewSheet> createState() => _RatingReviewSheetState();
}

class _RatingReviewSheetState extends State<RatingReviewSheet> {
  late int _stars;
  late final TextEditingController _reviewController;

  static const int _maxReviewLength = 280;

  @override
  void initState() {
    super.initState();
    _stars = (widget.book.rating ?? 0).round();
    _reviewController = TextEditingController(text: widget.book.reviewText ?? '');
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _save() {
    context.read<LibraryProvider>().saveWithOptions(widget.book.copyWith(
      rating: _stars == 0 ? null : _stars.toDouble(),
      reviewText: _reviewController.text.trim().isEmpty ? null : _reviewController.text.trim(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rate & review', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(widget.book.title,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.dotActive),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final filled = i < _stars;
                return IconButton(
                  iconSize: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  constraints: const BoxConstraints(),
                  icon: Icon(filled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: AppColors.onboardingButton),
                  onPressed: () => setState(() => _stars = (i + 1 == _stars) ? 0 : i + 1),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reviewController,
              maxLength: _maxReviewLength,
              maxLines: 4,
              minLines: 3,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'A short note about this book (optional)',
                hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.dotActive),
                filled: true,
                fillColor: AppColors.dotInactive.withOpacity(0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.onboardingButton,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _save,
                child: const Text('Save', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}