import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/collection_model.dart';
import '../models/saved_book_model.dart';

abstract class LibraryLocalDataSource {
  Future<List<SavedBookModel>> getSavedBooks();
  Future<void> saveBook(SavedBookModel book);
  Future<void> removeBook(String bookId);
  Future<List<CollectionModel>> getCollections();
  Future<void> saveCollection(CollectionModel collection);
  Future<void> deleteCollection(String collectionId);
}

class LibraryLocalDataSourceImpl implements LibraryLocalDataSource {
  final SharedPreferences prefs;
  LibraryLocalDataSourceImpl({required this.prefs});

  static const String _booksKey = 'SAVED_BOOKS';
  static const String _collectionsKey = 'COLLECTIONS';

  @override
  Future<List<SavedBookModel>> getSavedBooks() async {
    try {
      final raw = prefs.getString(_booksKey);
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
      final updated = [...current.where((b) => b.id != book.id), book];
      await prefs.setString(_booksKey, json.encode(updated.map((b) => b.toJson()).toList()));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> removeBook(String bookId) async {
    try {
      final current = await getSavedBooks();
      final updated = current.where((b) => b.id != bookId).toList();
      await prefs.setString(_booksKey, json.encode(updated.map((b) => b.toJson()).toList()));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<CollectionModel>> getCollections() async {
    try {
      final raw = prefs.getString(_collectionsKey);
      if (raw == null) return [];
      final List decoded = json.decode(raw);
      return decoded.map((e) => CollectionModel.fromJson(e)).toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> saveCollection(CollectionModel collection) async {
    try {
      final current = await getCollections();
      final updated = [...current, collection];
      await prefs.setString(_collectionsKey, json.encode(updated.map((c) => c.toJson()).toList()));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    try {
      final current = await getCollections();
      final updated = current.where((c) => c.id != collectionId).toList();
      await prefs.setString(_collectionsKey, json.encode(updated.map((c) => c.toJson()).toList()));
    } catch (e) {
      throw CacheException();
    }
  }
}