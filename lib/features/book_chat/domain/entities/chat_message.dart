enum ChatSender { user, ai }

class ChatMessage {
  final String text;
  final ChatSender sender;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  bool get isUser => sender == ChatSender.user;
}