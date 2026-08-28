import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../books/domain/entities/book.dart';
import '../../domain/repositories/book_chat_repository.dart';
import '../providers/book_chat_provider.dart';
import '../widgets/chat_bubble.dart';

class BookChatPage extends StatelessWidget {
  final Book book;
  const BookChatPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookChatProvider(
        book: book,
        repository: sl<BookChatRepository>(),
      ),
      child: _BookChatView(book: book),
    );
  }
}

class _BookChatView extends StatefulWidget {
  final Book book;
  const _BookChatView({required this.book});

  @override
  State<_BookChatView> createState() => _BookChatViewState();
}

class _BookChatViewState extends State<_BookChatView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _send(BookChatProvider provider) {
    final text = _controller.text;
    if (text.trim().isEmpty) return;

    _controller.clear();
    provider.sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookChatProvider>();

    // Keep pinned to the latest message whenever the list grows.
    _scrollToBottom();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          widget.book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: provider.messages.length,
                itemBuilder: (context, index) {
                  return ChatBubble(message: provider.messages[index]);
                },
              ),
            ),

            if (provider.isSending)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 16),
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Thinking…',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.dotActive),
                    ),
                  ],
                ),
              ),

            if (provider.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  provider.error!,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.red),
                ),
              ),

            // Input bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(provider),
                      decoration: InputDecoration(
                        hintText: 'Ask about this book…',
                        hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                        filled: true,
                        fillColor: AppColors.dotInactive.withOpacity(0.3),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.onboardingButton,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                      onPressed: provider.isSending ? null : () => _send(provider),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}