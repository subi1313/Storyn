import 'reading_status.dart';

class SavedBook {
  final String id;
  final String title;
  final String authors;
  final String? thumbnailUrl;
  final String description;
  final DateTime savedAt;
  final ReadingStatus status;
  final List<String> collectionIds;
  final String? epubPath;
  final List<String> bookmarkCfis;
  final double readingProgress;
  final String? lastCfi;
  final double? rating;
  final String? reviewText;

  const SavedBook({
    required this.id,
    required this.title,
    required this.authors,
    this.thumbnailUrl,
    required this.description,
    required this.savedAt,
    this.status = ReadingStatus.none,
    this.collectionIds = const [],
    this.epubPath,
    this.bookmarkCfis = const [],
    this.readingProgress = 0.0,
    this.lastCfi,
    this.rating,
    this.reviewText,
  });

  SavedBook copyWith({
    ReadingStatus? status,
    List<String>? collectionIds,
    String? epubPath,
    List<String>? bookmarkCfis,
    double? readingProgress,
    String? lastCfi,
    double? rating,
    String? reviewText,
  }) {
    return SavedBook(
      id: id,
      title: title,
      authors: authors,
      thumbnailUrl: thumbnailUrl,
      description: description,
      savedAt: savedAt,
      status: status ?? this.status,
      collectionIds: collectionIds ?? this.collectionIds,
      epubPath: epubPath ?? this.epubPath,
      bookmarkCfis: bookmarkCfis ?? this.bookmarkCfis,
      readingProgress: readingProgress ?? this.readingProgress,
      lastCfi: lastCfi ?? this.lastCfi,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
    );
  }
}