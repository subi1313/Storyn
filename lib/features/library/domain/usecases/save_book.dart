import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/saved_book.dart';
import '../repositories/library_repository.dart';

class SaveBook implements UseCase<void, SavedBook> {
  final LibraryRepository repository;
  SaveBook(this.repository);

  @override
  Future<Either<Failure, void>> call(SavedBook params) {
    return repository.saveBook(params);
  }
}