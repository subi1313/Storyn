import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/saved_book.dart';
import '../repositories/library_repository.dart';

class GetSavedBooks implements UseCase<List<SavedBook>, NoParams> {
  final LibraryRepository repository;
  GetSavedBooks(this.repository);

  @override
  Future<Either<Failure, List<SavedBook>>> call(NoParams params) {
    return repository.getSavedBooks();
  }
}