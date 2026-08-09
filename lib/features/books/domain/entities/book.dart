class Book {
  final String id;
  final String title;
  final String authors;
  final String? thumbnailUrl;
  final String description;

  const Book({
    required this.id,
    required this.title,
    required this.authors,
    this.thumbnailUrl,
    required this.description,
  });
}