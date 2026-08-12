import 'package:flutter/foundation.dart';
import '../../domain/usecases/search_books.dart';
import '../models/book_section.dart';

class BooksProvider extends ChangeNotifier {
  final SearchBooks searchBooksUseCase;
  BooksProvider({required this.searchBooksUseCase});

  String selectedMood = '';

  final List<BookSection> sections = [
    BookSection(title: 'Trending now', query: 'bestselling romance novels', sortByNewest: true),
    BookSection(title: 'Romance', query: 'romance novels bestseller'),
    BookSection(title: 'Mystery & thriller', query: 'mystery thriller bestseller'),
    BookSection(title: 'Horror', query: 'horror novels bestseller'),
    BookSection(title: 'Sci-fi', query: 'science fiction novels bestseller'),
    BookSection(title: 'Self help', query: 'self help bestseller books'),
  ];

  Future<void> loadHomeSections() async {
    for (final section in sections) {
      _loadSection(section);
    }
  }

  Future<void> _loadSection(BookSection section) async {
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
        section.status = SectionStatus.loaded;
        section.books = fetchedBooks;
      },
    );
    notifyListeners();
  }

  Future<void> searchByMood(String mood) async {
    selectedMood = mood;
    sections.removeWhere((s) => s.title.startsWith('Because you like'));
    final moodSection = BookSection(title: 'Because you like $mood', query: '$mood books bestseller');
    sections.insert(0, moodSection);
    notifyListeners();
    _loadSection(moodSection);
  }
}