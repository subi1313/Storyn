import 'package:flutter/foundation.dart';
import '../../domain/entities/book.dart';
import '../../domain/usecases/search_books.dart';

enum BooksStatus { initial, loading, loaded, error }

class BooksProvider extends ChangeNotifier {
  final SearchBooks searchBooksUseCase;
  BooksProvider({required this.searchBooksUseCase});

  BooksStatus status = BooksStatus.initial;
  List<Book> books = [];
  String errorMessage = '';

  Future<void> searchBooks(String query) async {
    status = BooksStatus.loading;
    notifyListeners();

    final result = await searchBooksUseCase(SearchBooksParams(query: query));

    result.fold(
          (failure) {
        status = BooksStatus.error;
        errorMessage = failure.message;
      },
          (fetchedBooks) {
        status = BooksStatus.loaded;
        books = fetchedBooks;
      },
    );
    notifyListeners();
  }
}