import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../books/domain/entities/book.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/exceptions/book_chat_exception.dart';
import '../../domain/repositories/book_chat_repository.dart';

class GeminiBookChatRepository implements BookChatRepository {
  final String apiKey;

  GeminiBookChatRepository({
    required this.apiKey,
  });

  @override
  Future<String> sendMessage({
    required Book book,
    required List<ChatMessage> history,
    required String message,
  }) async {
    if (apiKey.isEmpty) {
      throw const BookChatException(
        'AI chat isn\'t configured. Missing API key.',
      );
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-3.6-flash',
        apiKey: apiKey,
      );

      // Convert previous messages into Gemini's format.
      final chatHistory = history
          .map(
            (m) => Content(
          m.isUser ? 'user' : 'model',
          [
            TextPart(m.text),
          ],
        ),
      )
          .toList();

      // Create the chat with previous conversation history.
      final chat = model.startChat(
        history: chatHistory,
      );

      // Include the current book context with every request.
      final prompt = '''
${_systemPrompt(book)}

The user is now asking:

$message

Use the previous conversation as context.

If the user's question is short, such as:
- "plot"
- "characters"
- "themes"
- "author"
- "why?"
- "what about the ending?"
- "tell me more"

interpret it using the current book and the previous conversation.

Do not treat a short follow-up question as a completely new conversation.
''';

      final response = await chat.sendMessage(
        Content.text(prompt),
      );

      final text = response.text;

      if (text == null || text.trim().isEmpty) {
        throw const BookChatException(
          'Got an empty response. Try again.',
        );
      }

      return text.trim();
    } on BookChatException {
      rethrow;
    } catch (e) {
      throw BookChatException(
        'Something went wrong: $e',
      );
    }
  }

  String _systemPrompt(Book book) {
    final desc = book.description.trim().isEmpty
        ? 'No description available.'
        : book.description.trim();

    return '''
You are Storyn's AI book assistant.

You are currently discussing this book:

Title: ${book.title}
Author: ${book.authors}

Book description:
$desc

IMPORTANT INSTRUCTIONS:

1. Always keep this book as the main context.

2. Use the previous conversation when answering the user.

3. Short questions are valid questions.

For example:

User: plot

You should understand this as:
"Tell me the plot of ${book.title}."

User: characters

You should understand this as:
"Tell me about the characters in ${book.title}."

User: why?

You should look at the previous conversation to determine what
the user is asking "why?" about.

User: what about the ending?

You should understand this as a question about the ending of
${book.title}, using the previous conversation for additional context.

4. Do not say that the user's request is too brief if you can understand
it from the book context or previous conversation.

5. Discuss:
- Plot
- Themes
- Characters
- Author
- Setting
- Literary context
- Character relationships
- Important events
- Interpretation

6. Avoid major spoilers unless the user explicitly asks for them.

7. If you are going to reveal a major spoiler, warn the user first.

8. Keep answers conversational and concise unless the user asks
for a detailed explanation.

9. If the user asks something completely unrelated to the book,
politely redirect the conversation back to the book.

10. Never intentionally ignore previous messages in the conversation.
''';
  }
}
