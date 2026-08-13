// features/books/presentation/providers/books_provider.dart
import 'package:flutter/foundation.dart';
import '../../domain/usecases/search_books.dart';
import '../models/book_section.dart';

class BooksProvider extends ChangeNotifier {
  final SearchBooks searchBooksUseCase;
  BooksProvider({required this.searchBooksUseCase});

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
    // Load sequentially, not concurrently, so earlier shelves' picks
    // are known before later shelves dedupe against them.
    for (final section in sections) {
      await _loadSection(section);
    }
  }

  // features/books/presentation/providers/books_provider.dart
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
            : fetchedBooks.where((book) {
          final key = book.title.trim().toLowerCase();
          return !_shownBookKeys.contains(key);
        }).toList();

        if (!skipCrossDedup) {
          for (final book in books) {
            _shownBookKeys.add(book.title.trim().toLowerCase());
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
    final moodSection = BookSection(title: 'Because you like $mood', query: '$mood genre books novel');
    sections.insert(0, moodSection);
    notifyListeners();
    await _loadSection(moodSection, skipCrossDedup: true); // <-- key change
  }
}