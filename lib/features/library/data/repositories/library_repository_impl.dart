import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/saved_book.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_local_data_source.dart';
import '../models/collection_model.dart';
import '../models/saved_book_model.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryLocalDataSource localDataSource;
  LibraryRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<SavedBook>>> getSavedBooks() async {
    try {
      return Right(await localDataSource.getSavedBooks());
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveBook(SavedBook book) async {
    try {
      await localDataSource.saveBook(SavedBookModel.fromEntity(book));
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeBook(String bookId) async {
    try {
      await localDataSource.removeBook(bookId);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isBookSaved(String bookId) async {
    try {
      final books = await localDataSource.getSavedBooks();
      return Right(books.any((b) => b.id == bookId));
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Collection>>> getCollections() async {
    try {
      return Right(await localDataSource.getCollections());
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> createCollection(Collection collection) async {
    try {
      await localDataSource.saveCollection(CollectionModel.fromEntity(collection));
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteCollection(String collectionId) async {
    try {
      await localDataSource.deleteCollection(collectionId);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }
}