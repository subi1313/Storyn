import '../../domain/entities/reading_status.dart';
import '../../domain/entities/saved_book.dart';

class SavedBookModel extends SavedBook {
  const SavedBookModel({
    required super.id,
    required super.title,
    required super.authors,
    super.thumbnailUrl,
    required super.description,
    required super.savedAt,
    super.status,
    super.collectionIds,
    super.epubPath,
  });

  factory SavedBookModel.fromJson(Map<String, dynamic> json) {
    return SavedBookModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      authors: json['authors'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      description: json['description'] ?? '',
      savedAt: DateTime.tryParse(json['savedAt'] ?? '') ?? DateTime.now(),
      status: ReadingStatus.values.firstWhere((s) => s.name == json['status'], orElse: () => ReadingStatus.none),
      collectionIds: (json['collectionIds'] as List?)?.map((e) => e.toString()).toList() ?? [],
      epubPath: json['epubPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'savedAt': savedAt.toIso8601String(),
      'status': status.name,
      'collectionIds': collectionIds,
      'epubPath': epubPath,
    };
  }

  factory SavedBookModel.fromEntity(SavedBook book) {
    return SavedBookModel(
      id: book.id,
      title: book.title,
      authors: book.authors,
      thumbnailUrl: book.thumbnailUrl,
      description: book.description,
      savedAt: book.savedAt,
      status: book.status,
      collectionIds: book.collectionIds,
      epubPath: book.epubPath,
    );
  }
}