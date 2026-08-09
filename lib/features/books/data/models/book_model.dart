import '../../domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.title,
    required super.authors,
    super.thumbnailUrl,
    required super.description,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'];

    return BookModel(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? 'Unknown title',
      authors: (volumeInfo['authors'] as List?)?.join(', ') ?? 'Unknown author',
      thumbnailUrl: imageLinks != null ? imageLinks['thumbnail'] : null,
      description: volumeInfo['description'] ?? 'No description available.',
    );
  }
}