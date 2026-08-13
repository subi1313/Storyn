// features/books/presentation/providers/books_provider.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/book.dart';
import '../../domain/usecases/search_books.dart';
import '../models/book_section.dart';

enum SearchStatus { initial, loading, loaded, error }

class BooksProvider extends ChangeNotifier {
  final SearchBooks searchBooksUseCase;
  BooksProvider({required this.searchBooksUseCase});

  // --- Home shelves (unchanged) ---
  String selectedMood = '';
  final Set<String> _shownBookKeys = {};

  final List<BookSection> sections = [
    BookSection(title: 'Trending now', query: 'intitle:love OR intitle:midnight OR intitle:secret romance fiction', sortByNewest: true),
    BookSection(title: 'Romance', query: '"contemporary romance" love story fiction'),
    BookSection(title: 'Mystery & thriller', query: 'crime thriller fiction detective murder'),
    BookSection(title: 'Horror', query: 'horror fiction ghost supernatural fear'),
    BookSection(title: 'Sci-fi', query: 'science fiction space dystopian future'),
    BookSection(title: 'Self help', query: 'self improvement habits productivity mindset'),
  ];

  Future<void> loadHomeSections() async {
    for (final section in sections) {
      await _loadSection(section);
    }
  }

  Future<void> _loadSection(BookSection section, {bool skipCrossDedup = false}) async {
    section.status = SectionStatus.loading;
    notifyListeners();

    final result = await searchBooksUseCase(
      SearchBooksParams(query: section.query, sortByNewest: section.sortByNewest),
    );

    result.fold(
          (failure) {
        section.status = SectionStatus.error;
        section.errorMessage = failure.message;
      },
          (fetchedBooks) {
        final books = skipCrossDedup
            ? fetchedBooks
            : fetchedBooks.where((b) => !_shownBookKeys.contains(b.title.trim().toLowerCase())).toList();

        if (!skipCrossDedup) {
          for (final b in books) {
            _shownBookKeys.add(b.title.trim().toLowerCase());
          }
        }

        section.status = SectionStatus.loaded;
        section.books = books;
      },
    );
    notifyListeners();
  }

  Future<void> searchByMood(String mood) async {
    selectedMood = mood;
    sections.removeWhere((s) => s.title.startsWith('Because you like'));
    final moodSection = BookSection(title: 'Because you like $mood', query: '$mood romance fiction novel');
    sections.insert(0, moodSection);
    notifyListeners();
    await _loadSection(moodSection, skipCrossDedup: true);
  }

  // --- Explore page search (new) ---
  SearchStatus searchStatus = SearchStatus.initial;
  List<Book> searchResults = [];
  String searchErrorMessage = '';

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    searchStatus = SearchStatus.loading;
    notifyListeners();

    final result = await searchBooksUseCase(SearchBooksParams(query: query.trim()));

    result.fold(
          (failure) {
        searchStatus = SearchStatus.error;
        searchErrorMessage = failure.message;
      },
          (fetchedBooks) {
        searchStatus = SearchStatus.loaded;
        searchResults = fetchedBooks;
      },
    );
    notifyListeners();
  }

  void clearSearch() {
    searchStatus = SearchStatus.initial;
    searchResults = [];
    notifyListeners();
  }
}