class BookChatException implements Exception {
  final String message;
  const BookChatException(this.message);

  @override
  String toString() => message;
}