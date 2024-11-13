final comment1 = Comment(id: '1', content: 'Hello', likes: 0);
final comment2 = Comment(id: '2', content: 'World', likes: 0);

class Comment {
  Comment({
    required this.id,
    required this.content,
    required this.likes,
  });

  final String id;
  final String content;
  final int likes;

  Comment copyWith({
    String? id,
    String? content,
    int? likes,
  }) =>
      Comment(
        id: id ?? this.id,
        content: content ?? this.content,
        likes: likes ?? this.likes,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Comment && other.id == id && other.content == content && other.likes == likes;
  }

  @override
  int get hashCode => id.hashCode ^ content.hashCode ^ likes.hashCode;

  @override
  String toString() => 'Comment(id: $id, content: $content, likes: $likes)';
}
