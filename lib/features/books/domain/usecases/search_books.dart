import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

class SearchBooks implements UseCase<List<Book>, SearchBooksParams> {
  final BookRepository repository;
  SearchBooks(this.repository);

  @override
  Future<Either<Failure, List<Book>>> call(SearchBooksParams params) {
    return repository.searchBooks(params.query, sortByNewest: params.sortByNewest);
  }
}

class SearchBooksParams {
  final String query;
  final bool sortByNewest;
  SearchBooksParams({required this.query, this.sortByNewest = false});
}