import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/collection.dart';
import '../repositories/library_repository.dart';

class GetCollections implements UseCase<List<Collection>, NoParams> {
  final LibraryRepository repository;
  GetCollections(this.repository);

  @override
  Future<Either<Failure, List<Collection>>> call(NoParams params) {
    return repository.getCollections();
  }
}