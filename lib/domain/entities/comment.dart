class Comment {
  final int? idComment;
  final int postId;
  final int userId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final DateTime createdAt;

  Comment({
    this.idComment,
    required this.postId,
    required this.userId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      idComment: json['idComment'],
      postId: json['postId'] ?? 0,
      userId: json['userId'] ?? 0,
      authorName: json['authorName'] ?? 'Anonymous',
      authorAvatar: json['authorAvatar'],
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}
