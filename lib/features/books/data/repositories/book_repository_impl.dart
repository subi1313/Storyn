import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_remote_data_source.dart';
import '../datasources/openlibrary_remote_data_source.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource googleDataSource;
  final OpenLibraryRemoteDataSource openLibraryDataSource;

  BookRepositoryImpl({
    required this.googleDataSource,
    required this.openLibraryDataSource,
  });

  @override
  Future<Either<Failure, List<Book>>> searchBooks(String query, {bool sortByNewest = false}) async {
    try {
      final books = await googleDataSource.searchBooks(query, sortByNewest: sortByNewest);
      return Right(_deduplicate(books));
    } on ServerException {
      try {
        final books = await openLibraryDataSource.searchBooks(query, sortByNewest: sortByNewest);
        return Right(_deduplicate(books));
      } on ServerException {
        return const Left(ServerFailure());
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  List<Book> _deduplicate(List<Book> books) {
    final seen = <String>{};
    final result = <Book>[];

    for (final book in books) {
      if (!_isQualityBook(book)) continue;
      final key = '${book.title.trim().toLowerCase()}|${book.authors.trim().toLowerCase()}';
      if (seen.add(key)) result.add(book);
    }
    return result;
  }
  // data/repositories/book_repository_impl.dart
  bool _isQualityBook(Book book) {
    if (book.thumbnailUrl == null || book.thumbnailUrl!.isEmpty) return false;
    if (book.printType != 'BOOK') return false;
    if (book.authors.trim().toLowerCase() == 'unknown author') return false;

    final authorCount = book.authors.split(',').length;
    if (authorCount > 3) return false;

    final titleLower = book.title.toLowerCase();
    const junkKeywords = [
      'journal', 'notebook', 'diary', 'planner',
      'log book', 'logbook', 'composition book', 'sketchbook', 'blank book',
      'proceedings', 'conference', 'symposium', 'quarterly', 'annual review',
      'working paper', 'research paper', 'thesis', 'dissertation',
      'article', 'essay collection', 'anthology of essays',
      'how to write', 'writing guide', 'writer\'s guide', 'author\'s guide',
      'workbook', 'study guide', 'summary of', 'summary and analysis',
      'catalogue', 'catalog of', 'library department', 'lending department', // <-- new
    ];
    if (junkKeywords.any((word) => titleLower.contains(word))) return false;

    if (book.pageCount > 0 && book.pageCount < 80) return false;

    // Exclude old public-domain scans — extract the leading 4-digit year
    final yearMatch = RegExp(r'^\d{4}').firstMatch(book.publishedDate);
    if (yearMatch != null) {
      final year = int.tryParse(yearMatch.group(0)!) ?? 0;
      if (year > 0 && year < 1990) return false; // adjust cutoff as you like
    }

    return true;
  }
}