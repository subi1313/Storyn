// features/books/data/models/book_model.dart
import '../../domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.title,
    required super.authors,
    super.thumbnailUrl,
    required super.description,
    super.printType,
    super.pageCount,
    super.publishedDate,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'];

    return BookModel(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? 'Unknown title',
      authors: (volumeInfo['authors'] as List?)?.join(', ') ?? 'Unknown author',
      thumbnailUrl: imageLinks != null ? imageLinks['thumbnail'] : null,
      description: _cleanDescription(volumeInfo['description'] ?? ''),
      printType: volumeInfo['printType'] ?? 'BOOK',
      pageCount: volumeInfo['pageCount'] ?? 0,
      publishedDate: volumeInfo['publishedDate'] ?? '',
    );
  }

  factory BookModel.fromOpenLibraryJson(Map<String, dynamic> json) {
    final coverId = json['cover_i'];
    final authorsList = json['author_name'] as List?;
    final year = json['first_publish_year'];

    return BookModel(
      id: json['key'] ?? '',
      title: json['title'] ?? 'Unknown title',
      authors: authorsList?.join(', ') ?? 'Unknown author',
      thumbnailUrl: coverId != null ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg' : null,
      description: _cleanDescription(json['first_sentence']?.toString() ?? ''),
      printType: 'BOOK',
      pageCount: json['number_of_pages_median'] ?? 0,
      publishedDate: year != null ? year.toString() : '',
    );
  }

  static String _cleanDescription(String raw) {
    if (raw.trim().isEmpty) return 'No description available.';

    String cleaned = raw;

    // Cut everything from "keywords:" onward (case-insensitive) — these are SEO tag dumps
    final keywordsIndex = RegExp(r'keywords\s*:', caseSensitive: false).firstMatch(cleaned);
    if (keywordsIndex != null) {
      cleaned = cleaned.substring(0, keywordsIndex.start);
    }

    // Remove quoted reviewer blurbs, e.g. "...great book..." - Amazon reviewer
    cleaned = cleaned.replaceAll(
      RegExp(r'"[^"]{10,400}"\s*-\s*(Amazon\s*)?reviewer', caseSensitive: false),
      '',
    );

    // Remove common promo/sale prefixes at the very start of the text
    cleaned = cleaned.replaceAll(
      RegExp(r'^(SALE[^.]*\.|SPECIAL PRICING[^.]*\.|LIMITED TIME[^.]*\.)\s*', caseSensitive: false),
      '',
    );

    // Collapse leftover extra whitespace/newlines from the removals above
    cleaned = cleaned.replaceAll(RegExp(r'\n{2,}'), '\n\n').trim();

    return cleaned.isEmpty ? 'No description available.' : cleaned;
  }
}