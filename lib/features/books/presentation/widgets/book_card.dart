import 'package:flutter/material.dart';
import '../../domain/entities/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: book.thumbnailUrl != null
            ? Image.network(book.thumbnailUrl!, width: 50, fit: BoxFit.cover)
            : const Icon(Icons.book, size: 40),
        title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(book.authors),
        onTap: () {
          // TODO: navigate to book detail page (context.push('/book/${book.id}'))
        },
      ),
    );
  }
}