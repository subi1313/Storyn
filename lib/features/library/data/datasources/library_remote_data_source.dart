import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../models/collection_model.dart';
import '../models/saved_book_model.dart';
import 'library_local_data_source.dart';

class LibraryRemoteDataSourceImpl implements LibraryLocalDataSource {
  final FirebaseFirestore firestore;
  LibraryRemoteDataSourceImpl({required this.firestore});

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw CacheException();
    return uid;
  }

  CollectionReference get _booksRef => firestore.collection('users').doc(_uid).collection('savedBooks');
  CollectionReference get _collectionsRef => firestore.collection('users').doc(_uid).collection('collections');

  @override
  Future<List<SavedBookModel>> getSavedBooks() async {
    try {
      final snapshot = await _booksRef.get();
      return snapshot.docs.map((doc) => SavedBookModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> saveBook(SavedBookModel book) async {
    try {
      await _booksRef.doc(book.id).set(book.toJson());
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> removeBook(String bookId) async {
    try {
      await _booksRef.doc(bookId).delete();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<CollectionModel>> getCollections() async {
    try {
      final snapshot = await _collectionsRef.get();
      return snapshot.docs.map((doc) => CollectionModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> saveCollection(CollectionModel collection) async {
    try {
      await _collectionsRef.doc(collection.id).set(collection.toJson());
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    try {
      await _collectionsRef.doc(collectionId).delete();
    } catch (e) {
      throw CacheException();
    }
  }
}