import '../../domain/entities/book.dart';

enum SectionStatus { initial, loading, loaded, error }

class BookSection {
  final String title;
  final String query;
  final bool sortByNewest;
  List<Book> books;
  SectionStatus status;
  String errorMessage;

  BookSection({
    required this.title,
    required this.query,
    this.sortByNewest = false,
    this.books = const [],
    this.status = SectionStatus.initial,
    this.errorMessage = '',
  });
}