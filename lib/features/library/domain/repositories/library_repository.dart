import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/collection.dart';
import '../entities/saved_book.dart';

abstract class LibraryRepository {
  Future<Either<Failure, List<SavedBook>>> getSavedBooks();
  Future<Either<Failure, void>> saveBook(SavedBook book);
  Future<Either<Failure, void>> removeBook(String bookId);
  Future<Either<Failure, bool>> isBookSaved(String bookId);
  Future<Either<Failure, List<Collection>>> getCollections();
  Future<Either<Failure, void>> createCollection(Collection collection);
  Future<Either<Failure, void>> deleteCollection(String collectionId);
}