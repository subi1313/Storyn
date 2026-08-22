import 'package:flutter/foundation.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/reading_status.dart';
import '../../domain/entities/saved_book.dart';
import '../../domain/usecases/create_collection.dart';
import '../../domain/usecases/delete_collection.dart';
import '../../domain/usecases/get_collections.dart';
import '../../domain/usecases/get_saved_books.dart';
import '../../domain/usecases/remove_book.dart';
import '../../domain/usecases/save_book.dart';
import '../../domain/usecases/is_book_saved.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

enum LibraryStatus { initial, loading, loaded, error }

class LibraryProvider extends ChangeNotifier {
  final GetSavedBooks getSavedBooksUseCase;
  final SaveBook saveBookUseCase;
  final RemoveBook removeBookUseCase;
  final IsBookSaved isBookSavedUseCase;
  final GetCollections getCollectionsUseCase;
  final CreateCollection createCollectionUseCase;
  final DeleteCollection deleteCollectionUseCase;

  LibraryProvider({
    required this.getSavedBooksUseCase,
    required this.saveBookUseCase,
    required this.removeBookUseCase,
    required this.isBookSavedUseCase,
    required this.getCollectionsUseCase,
    required this.createCollectionUseCase,
    required this.deleteCollectionUseCase,
  });

  LibraryStatus status = LibraryStatus.initial;
  List<SavedBook> savedBooks = [];
  List<Collection> collections = [];
  String errorMessage = '';

  final Set<String> _savedIds = {};
  bool isSaved(String bookId) => _savedIds.contains(bookId);

  Future<void> loadLibrary() async {
    status = LibraryStatus.loading;
    notifyListeners();

    final booksResult = await getSavedBooksUseCase(NoParams());
    final collectionsResult = await getCollectionsUseCase(NoParams());

    booksResult.fold(
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

    collectionsResult.fold((_) {}, (fetched) => collections = fetched);
    notifyListeners();
  }

  ReadingStatus statusFor(String bookId) {
    final match = savedBooks.where((b) => b.id == bookId);
    return match.isEmpty ? ReadingStatus.none : match.first.status;
  }

  List<String> collectionIdsFor(String bookId) {
    final match = savedBooks.where((b) => b.id == bookId);
    return match.isEmpty ? [] : match.first.collectionIds;
  }

  Future<void> saveWithOptions(SavedBook baseBook, {ReadingStatus? status, List<String>? collectionIds}) async {
    print('PROVIDER: saveWithOptions bookId="${baseBook.id}" incomingStatus=$status');

    final existing = savedBooks.where((b) => b.id == baseBook.id);
    final current = existing.isEmpty ? baseBook : existing.first;

    final updated = current.copyWith(
      status: status ?? current.status,
      collectionIds: collectionIds ?? current.collectionIds,
    );
    print('PROVIDER: resolved status=${updated.status}, will call saveBookUseCase');

    final result = await saveBookUseCase(updated);
    result.fold(
          (failure) => print('PROVIDER: save FAILED - ${failure.message}'),
          (_) {
        print('PROVIDER: save SUCCEEDED, updated.status=${updated.status}');
        _savedIds.add(updated.id);
        final index = savedBooks.indexWhere((b) => b.id == updated.id);
        if (index != -1) {
          savedBooks[index] = updated;
        } else {
          savedBooks.add(updated);
        }
        notifyListeners();
      },
    );
  }

  Future<void> createCollection(String name) async {
    final collection = Collection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
    print('PROVIDER: creating collection "$name"');
    final result = await createCollectionUseCase(collection);
    result.fold(
          (failure) => print('PROVIDER: create collection FAILED: ${failure.message}'),
          (_) {
        print('PROVIDER: collection created, total now ${collections.length + 1}');
        collections.add(collection);
        notifyListeners();
      },
    );
  }

  Future<void> removeSavedBook(String bookId) async {
    final result = await removeBookUseCase(bookId);
    result.fold(
          (failure) => debugPrint('LibraryProvider: remove failed - ${failure.message}'),
          (_) {
        _savedIds.remove(bookId);
        savedBooks.removeWhere((b) => b.id == bookId);
        notifyListeners();
      },
    );
  }



  Future<void> deleteCollection(String collectionId) async {
    final result = await deleteCollectionUseCase(collectionId);
    result.fold(
          (failure) => debugPrint('LibraryProvider: delete collection failed - ${failure.message}'),
          (_) {
        collections.removeWhere((c) => c.id == collectionId);
        notifyListeners();
      },
    );
  }

  // features/library/presentation/providers/library_provider.dart
  Future<void> importEpub(SavedBook book) async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );
    if (files.isEmpty || files.first.path == null) return; // empty list = user canceled

    final pickedFile = File(files.first.path!);
    final appDir = await getApplicationDocumentsDirectory();
    final epubDir = Directory('${appDir.path}/epubs');
    if (!epubDir.existsSync()) epubDir.createSync(recursive: true);

    final destPath = '${epubDir.path}/${book.id}.epub';
    final savedFile = await pickedFile.copy(destPath);

    final updated = book.copyWith(epubPath: savedFile.path);
    final result = await saveBookUseCase(updated);
    result.fold(
          (failure) => print('PROVIDER: epub import failed - ${failure.message}'),
          (_) {
        final index = savedBooks.indexWhere((b) => b.id == updated.id);
        if (index != -1) savedBooks[index] = updated;
        notifyListeners();
      },
    );
  }

  List<SavedBook> booksByStatus(ReadingStatus status) =>
      savedBooks.where((b) => b.status == status).toList();

  List<SavedBook> booksInCollection(String collectionId) =>
      savedBooks.where((b) => b.collectionIds.contains(collectionId)).toList();
}