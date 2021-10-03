class Message {
  final String id;
  final String type;
  final String content;
  final int createdAt;
  final String writer;
  final String receiver;

  Message({
    required this.id,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.writer,
    required this.receiver,
  });
}
