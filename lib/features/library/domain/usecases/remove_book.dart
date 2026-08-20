import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/library_repository.dart';

class RemoveBook implements UseCase<void, String> {
  final LibraryRepository repository;
  RemoveBook(this.repository);

  @override
  Future<Either<Failure, void>> call(String bookId) {
    return repository.removeBook(bookId);
  }
}