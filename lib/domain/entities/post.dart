import 'engagement_result.dart';

enum PostType { MANUAL, ACHIEVEMENT, CHALLENGE_PROOF }
enum ReactionType { LIKE, FIRE, STRENGTH, NONE }

class Post {
  final int? idPost;
  final int? authorId;
  final String? content;
  final String? imageUrl;
  final String authorName;
  final String? authorAvatar;
  final PostType postType;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final bool isLiked;
  final List<String> tags;
  final ReactionType currentUserReaction;
  final EngagementResult? engagement;

  Post({
    this.idPost,
    this.authorId,
    this.content,
    this.imageUrl,
    required this.authorName,
    this.authorAvatar,
    required this.postType,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.isLiked = false,
    this.tags = const [],
    this.currentUserReaction = ReactionType.NONE,
    this.engagement,
  });

  Post copyWith({
    bool? isLiked,
    int? likesCount,
    int? commentsCount,
    List<String>? tags,
    ReactionType? currentUserReaction,
    EngagementResult? engagement,
  }) {
    return Post(
      idPost: idPost,
      authorId: authorId,
      content: content,
      imageUrl: imageUrl,
      authorName: authorName,
      authorAvatar: authorAvatar,
      postType: postType,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt,
      isLiked: isLiked ?? this.isLiked,
      tags: tags ?? this.tags,
      currentUserReaction: currentUserReaction ?? this.currentUserReaction,
      engagement: engagement ?? this.engagement,
    );
  }
}
