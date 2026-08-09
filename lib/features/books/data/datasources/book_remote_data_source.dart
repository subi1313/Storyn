import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../models/book_model.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> searchBooks(String query);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final http.Client client;
  BookRemoteDataSourceImpl({required this.client});

  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  @override
  Future<List<BookModel>> searchBooks(String query) async {
    final url = Uri.parse('$_baseUrl?q=$query&maxResults=20');
    final response = await client.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List? ?? [];
      return items.map((item) => BookModel.fromJson(item)).toList();
    } else {
      throw ServerException();
    }
  }
}