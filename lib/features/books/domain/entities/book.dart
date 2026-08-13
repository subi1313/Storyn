class Book {
  final String id;
  final String title;
  final String authors;
  final String? thumbnailUrl;
  final String description;
  final String printType;
  final int pageCount;
  final String publishedDate;

  const Book({
    required this.id,
    required this.title,
    required this.authors,
    this.thumbnailUrl,
    required this.description,
    this.printType = 'BOOK',
    this.pageCount = 0,
    this.publishedDate = '',
  });
}