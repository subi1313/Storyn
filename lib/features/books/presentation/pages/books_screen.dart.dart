import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection_container.dart';
import '../providers/books_provider.dart';
import '../widgets/book_card.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<BooksProvider>()..searchBooks('flutter'),
      child: const _BooksView(),
    );
  }
}

class _BooksView extends StatefulWidget {
  const _BooksView();

  @override
  State<_BooksView> createState() => _BooksViewState();
}

class _BooksViewState extends State<_BooksView> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BooksProvider>();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search books...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onSubmitted: (query) {
              if (query.trim().isNotEmpty) {
                context.read<BooksProvider>().searchBooks(query.trim());
              }
            },
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildBody(BooksProvider provider) {
    switch (provider.status) {
      case BooksStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case BooksStatus.error:
        return Center(child: Text(provider.errorMessage));
      case BooksStatus.loaded:
        if (provider.books.isEmpty) {
          return const Center(child: Text('No books found.'));
        }
        return ListView.builder(
          itemCount: provider.books.length,
          itemBuilder: (context, index) => BookCard(book: provider.books[index]),
        );
      case BooksStatus.initial:
        return const SizedBox.shrink();
    }
  }
}