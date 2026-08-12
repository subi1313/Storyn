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
      printType: volumeInfo['printType'] ?? 'BOOK',
      pageCount: volumeInfo['pageCount'] ?? 0,
    );
  }

  factory BookModel.fromOpenLibraryJson(Map<String, dynamic> json) {
    final coverId = json['cover_i'];
    final authorsList = json['author_name'] as List?;

    return BookModel(
      id: json['key'] ?? '',
      title: json['title'] ?? 'Unknown title',
      authors: authorsList?.join(', ') ?? 'Unknown author',
      thumbnailUrl: coverId != null
          ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
          : null,
      description: json['first_sentence']?.toString() ?? 'No description available.',
      printType: 'BOOK', // Open Library doesn't return this; assume BOOK
      pageCount: json['number_of_pages_median'] ?? 0,
    );
  }
}