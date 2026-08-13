import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/error/exceptions.dart';
import '../models/book_model.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> searchBooks(String query, {bool sortByNewest = false});
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final http.Client client;
  BookRemoteDataSourceImpl({required this.client});

  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  @override
  Future<List<BookModel>> searchBooks(String query, {bool sortByNewest = false}) async {
    final apiKey = dotenv.env['GOOGLE_BOOKS_API_KEY'];
    final orderByParam = sortByNewest ? '&orderBy=newest' : '';
    final encodedQuery = Uri.encodeQueryComponent(query);
    final url = Uri.parse('$_baseUrl?q=$encodedQuery&maxResults=20$orderByParam&key=$apiKey');

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