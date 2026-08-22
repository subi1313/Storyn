import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/library_repository.dart';

class DeleteCollection implements UseCase<void, String> {
  final LibraryRepository repository;
  DeleteCollection(this.repository);

  @override
  Future<Either<Failure, void>> call(String collectionId) {
    return repository.deleteCollection(collectionId);
  }
}