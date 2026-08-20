import 'package:flutter/foundation.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/reading_status.dart';
import '../../domain/entities/saved_book.dart';
import '../../domain/usecases/get_saved_books.dart';
import '../../domain/usecases/save_book.dart';
import '../../domain/usecases/remove_book.dart';
import '../../domain/usecases/is_book_saved.dart';

enum LibraryStatus { initial, loading, loaded, error }

class LibraryProvider extends ChangeNotifier {
  final GetSavedBooks getSavedBooksUseCase;
  final SaveBook saveBookUseCase;
  final RemoveBook removeBookUseCase;
  final IsBookSaved isBookSavedUseCase;

  LibraryProvider({
    required this.getSavedBooksUseCase,
    required this.saveBookUseCase,
    required this.removeBookUseCase,
    required this.isBookSavedUseCase,
  });

  LibraryStatus status = LibraryStatus.initial;
  List<SavedBook> savedBooks = [];
  String errorMessage = '';

  // Tracks per-book saved state so BookDetailPage can reflect it instantly
  final Set<String> _savedIds = {};
  bool isSaved(String bookId) => _savedIds.contains(bookId);

  Future<void> loadLibrary() async {
    status = LibraryStatus.loading;
    notifyListeners();

    final result = await getSavedBooksUseCase(NoParams());
    result.fold(
          (failure) {
        status = LibraryStatus.error;
        errorMessage = failure.message;
      },
          (books) {
        status = LibraryStatus.loaded;
        savedBooks = books;
        _savedIds
          ..clear()
          ..addAll(books.map((b) => b.id));
      },
    );
    notifyListeners();
  }

  Future<void> toggleSave(SavedBook book) async {
    print('PROVIDER: toggleSave called for id="${book.id}"');
    if (_savedIds.contains(book.id)) {
      print('PROVIDER: removing');
      await removeBookUseCase(book.id);
      _savedIds.remove(book.id);
      savedBooks.removeWhere((b) => b.id == book.id);
    } else {
      print('PROVIDER: saving');
      final result = await saveBookUseCase(book);
      result.fold(
            (failure) => print('PROVIDER: save FAILED: ${failure.message}'),
            (_) {
          print('PROVIDER: save SUCCEEDED');
          _savedIds.add(book.id);
          savedBooks.add(book);
        },
      );
      notifyListeners();
      return; // early return since the else-branch above already handles state on success
    }
    notifyListeners();
  }

  Future<void> setStatus(SavedBook book, ReadingStatus status) async {
    final updatedBook = book.copyWith(status: status);
    final result = await saveBookUseCase(updatedBook);

    result.fold(
          (failure) => print('PROVIDER: setStatus FAILED: ${failure.message}'),
          (_) {
        _savedIds.add(updatedBook.id);
        final index = savedBooks.indexWhere((b) => b.id == updatedBook.id);
        if (index != -1) {
          savedBooks[index] = updatedBook;
        } else {
          savedBooks.add(updatedBook);
        }
        notifyListeners();
      },
    );
  }

  ReadingStatus statusFor(String bookId) {
    final match = savedBooks.where((b) => b.id == bookId);
    return match.isEmpty ? ReadingStatus.none : match.first.status;
  }
}