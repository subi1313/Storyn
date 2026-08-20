import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/saved_book.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_local_data_source.dart';
import '../models/saved_book_model.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryLocalDataSource localDataSource;
  LibraryRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<SavedBook>>> getSavedBooks() async {
    try {
      final books = await localDataSource.getSavedBooks();
      return Right(books);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveBook(SavedBook book) async {
    try {
      print('REPO: attempting to save ${book.id} - ${book.title}');
      await localDataSource.saveBook(SavedBookModel.fromEntity(book));
      print('REPO: save call completed');
      return const Right(null);
    } on CacheException catch (e) {
      print('REPO: CacheException caught: $e');
      return const Left(CacheFailure());
    } catch (e) {
      print('REPO: unexpected error: $e');
      return Left(CacheFailure(e.toString()));
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
}