import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../models/book_model.dart';

abstract class OpenLibraryRemoteDataSource {
  Future<List<BookModel>> searchBooks(String query, {bool sortByNewest = false});
}

class OpenLibraryRemoteDataSourceImpl implements OpenLibraryRemoteDataSource {
  final http.Client client;
  OpenLibraryRemoteDataSourceImpl({required this.client});

  static const String _baseUrl = 'https://openlibrary.org/search.json';

  @override
  Future<List<BookModel>> searchBooks(String query, {bool sortByNewest = false}) async {
    final encodedQuery = Uri.encodeQueryComponent(query);
    final sortParam = sortByNewest ? '&sort=new' : '';
    final url = Uri.parse('$_baseUrl?q=$encodedQuery&limit=20$sortParam');

    final response = await client.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final docs = data['docs'] as List? ?? [];
      return docs.map((doc) => BookModel.fromOpenLibraryJson(doc)).toList();
    } else {
      throw ServerException();
    }
  }
}