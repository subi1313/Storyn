import 'package:flutter/foundation.dart';

import '../../../books/domain/entities/book.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/exceptions/book_chat_exception.dart';
import '../../domain/repositories/book_chat_repository.dart';

class BookChatProvider extends ChangeNotifier {
  final Book book;
  final BookChatRepository repository;

  BookChatProvider({
    required this.book,
    required this.repository,
  }) {
    _messages.add(
      ChatMessage(
        text: 'Hi! Ask me anything about "${book.title}" — plot, themes, '
            'characters, or the author. What would you like to know?',
        sender: ChatSender.ai,
        timestamp: DateTime.now(),
      ),
    );
  }

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isSending = false;
  bool get isSending => _isSending;

  String? _error;
  String? get error => _error;

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return;

    _error = null;

    final userMessage = ChatMessage(
      text: trimmed,
      sender: ChatSender.user,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isSending = true;
    notifyListeners();

    try {
      // History excludes the just-added user message and the initial
      // greeting — the greeting isn't a real model turn.
      final history = _messages
          .sublist(1, _messages.length - 1)
          .toList();

      final reply = await repository.sendMessage(
        book: book,
        history: history,
        message: trimmed,
      );

      _messages.add(
        ChatMessage(
          text: reply,
          sender: ChatSender.ai,
          timestamp: DateTime.now(),
        ),
      );
    } on BookChatException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}