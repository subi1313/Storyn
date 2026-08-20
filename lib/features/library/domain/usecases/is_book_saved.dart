import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/library_repository.dart';

class IsBookSaved implements UseCase<bool, String> {
  final LibraryRepository repository;
  IsBookSaved(this.repository);

  @override
  Future<Either<Failure, bool>> call(String bookId) {
    return repository.isBookSaved(bookId);
  }
}