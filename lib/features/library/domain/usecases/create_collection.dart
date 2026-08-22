import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/collection.dart';
import '../repositories/library_repository.dart';

class CreateCollection implements UseCase<void, Collection> {
  final LibraryRepository repository;
  CreateCollection(this.repository);

  @override
  Future<Either<Failure, void>> call(Collection params) {
    return repository.createCollection(params);
  }
}