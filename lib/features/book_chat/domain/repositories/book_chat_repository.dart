import '../../../books/domain/entities/book.dart';
import '../entities/chat_message.dart';

abstract class BookChatRepository {
  /// Sends [message] with the given conversation [history] for context,
  /// scoped to [book]. Returns the AI's reply text.
  Future<String> sendMessage({
    required Book book,
    required List<ChatMessage> history,
    required String message,
  });
}