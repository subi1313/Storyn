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
    return repository.searchBooks(params.query);
  }
}

class SearchBooksParams {
  final String query;
  SearchBooksParams({required this.query});
}