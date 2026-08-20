import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/saved_book_model.dart';

abstract class LibraryLocalDataSource {
  Future<List<SavedBookModel>> getSavedBooks();
  Future<void> saveBook(SavedBookModel book);
  Future<void> removeBook(String bookId);
}

class LibraryLocalDataSourceImpl implements LibraryLocalDataSource {
  final SharedPreferences prefs;
  LibraryLocalDataSourceImpl({required this.prefs});

  static const String _key = 'SAVED_BOOKS';

  @override
  Future<List<SavedBookModel>> getSavedBooks() async {
    try {
      final raw = prefs.getString(_key);
      if (raw == null) return [];
      final List decoded = json.decode(raw);
      return decoded.map((e) => SavedBookModel.fromJson(e)).toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> saveBook(SavedBookModel book) async {
    try {
      final current = await getSavedBooks();
      final updated = [
        ...current.where((b) => b.id != book.id), // remove old entry if present
        book, // add the new/updated one
      ];
      await prefs.setString(_key, json.encode(updated.map((b) => b.toJson()).toList()));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> removeBook(String bookId) async {
    try {
      final current = await getSavedBooks();
      final updated = current.where((b) => b.id != bookId).toList();
      await prefs.setString(_key, json.encode(updated.map((b) => b.toJson()).toList()));
    } catch (e) {
      throw CacheException();
    }
  }
}