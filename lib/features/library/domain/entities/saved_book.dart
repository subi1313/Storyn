import 'reading_status.dart';

class SavedBook {
  final String id;
  final String title;
  final String authors;
  final String? thumbnailUrl;
  final String description;
  final DateTime savedAt;
  final ReadingStatus status;
  final List<String> collectionIds; // <-- new

  const SavedBook({
    required this.id,
    required this.title,
    required this.authors,
    this.thumbnailUrl,
    required this.description,
    required this.savedAt,
    this.status = ReadingStatus.none,
    this.collectionIds = const [],
  });

  SavedBook copyWith({ReadingStatus? status, List<String>? collectionIds}) {
    return SavedBook(
      id: id,
      title: title,
      authors: authors,
      thumbnailUrl: thumbnailUrl,
      description: description,
      savedAt: savedAt,
      status: status ?? this.status,
      collectionIds: collectionIds ?? this.collectionIds,
    );
  }
}