import 'package:flutter/material.dart';
import '../../../books/presentation/pages/books_screen.dart.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storyn')),
      body: const BooksScreen(),
    );
  }
}