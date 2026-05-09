import 'package:wello_frontend/domain/entities/post.dart';

class PostModel extends Post {
  PostModel({
    super.idPost,
    super.authorId,
    super.content,
    super.imageUrl,
    required super.authorName,
    super.authorAvatar,
    required super.postType,
    super.likesCount = 0,
    super.commentsCount = 0,
    required super.createdAt,
    super.isLiked = false,
    super.tags = const [],
    super.currentUserReaction = ReactionType.NONE,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      idPost: json['idPost'],
      authorId: json['idUser'], // Map idUser to authorId
      content: json['content'],
      imageUrl: json['imageUrl'],
      authorName: json['authorName'] ?? 'Anonymous',
      authorAvatar: json['authorAvatar'],
      postType: _parsePostType(json['postType']),
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      isLiked: json['liked'] ?? false,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
      currentUserReaction: _parseReactionType(json['currentUserReaction']),
    );
  }

  static PostType _parsePostType(String? type) {
    switch (type) {
      case 'ACHIEVEMENT':
        return PostType.ACHIEVEMENT;
      case 'MANUAL':
      default:
        return PostType.MANUAL;
    }
  }

  static ReactionType _parseReactionType(String? type) {
    switch (type) {
      case 'LIKE':
        return ReactionType.LIKE;
      case 'FIRE':
        return ReactionType.FIRE;
      case 'STRENGTH':
        return ReactionType.STRENGTH;
      case 'NONE':
      default:
        return ReactionType.NONE;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'imageUrl': imageUrl,
    };
  }
}
