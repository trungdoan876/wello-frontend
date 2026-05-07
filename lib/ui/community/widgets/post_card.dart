import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wello_frontend/domain/entities/post.dart';
import 'package:wello_frontend/ui/profile/profile_screen.dart';
import 'package:wello_frontend/ui/community/widgets/other_user_profile_screen.dart';
import 'package:wello_frontend/core/utils/avatar_helper.dart';
import 'package:wello_frontend/ui/community/widgets/comments_sheet.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final Function(ReactionType) onReact;
  final Function(int)? onProfileTap;
  final Function(String)? onTagTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onReact,
    this.onProfileTap,
    this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.w(0.04),
        vertical: context.h(0.01),
      ),
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.w(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar and User info
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (onProfileTap != null && post.authorId != null) {
                onProfileTap!(post.authorId!);
              } else if (post.authorId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtherUserProfileScreen(userId: post.authorId!),
                  ),
                );
              } else {
                debugPrint('[POST] Cannot navigate: authorId is null');
              }
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: context.w(0.06),
                  backgroundColor: const Color(0xff6C63FF).withOpacity(0.1),
                  backgroundImage: AvatarHelper.getImageProvider(post.authorAvatar),
                  child: post.authorAvatar == null
                      ? Icon(Icons.person,
                          color: const Color(0xff6C63FF), size: context.w(0.06))
                      : null,
                ),
                SizedBox(width: context.w(0.03)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.authorName,
                            style: GoogleFonts.baloo2(
                              fontSize: context.sp(4.5),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff2D2D2D),
                            ),
                          ),
                          if (post.postType == PostType.ACHIEVEMENT) ...[
                            SizedBox(width: context.w(0.02)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.w(0.02),
                                vertical: context.h(0.002),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.orange.withOpacity(0.5)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.stars,
                                      color: Colors.orange, size: context.sp(3.5)),
                                  SizedBox(width: 2),
                                  Text(
                                    "Thành tích",
                                    style: GoogleFonts.baloo2(
                                      fontSize: context.sp(3),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _formatDate(post.createdAt),
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(3.5),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
          
          SizedBox(height: context.h(0.015)),
          
          // Content
          if (post.content != null && post.content!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: context.h(0.015)),
              child: Text(
                post.content!,
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(4),
                  color: const Color(0xff4A4A4A),
                ),
              ),
            ),
            
          // Image
          if (post.imageUrl != null)
            Padding(
              padding: EdgeInsets.only(top: context.h(0.015)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildPostImage(post.imageUrl!),
              ),
            ),
            
          // Hashtags
          if (post.tags.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: context.h(0.01), bottom: context.h(0.005)),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: post.tags.map((tag) => GestureDetector(
                  onTap: () => onTagTap?.call(tag),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xff6C63FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#$tag',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(3.5),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff6C63FF),
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),
            
          SizedBox(height: context.h(0.015)),
          
          // Interaction bar
          Row(
            children: [
              _buildReactionButton(context),
              SizedBox(width: context.w(0.04)),
              _buildInteractionButton(
                context: context,
                icon: Icons.chat_bubble_outline,
                color: Colors.grey,
                label: post.commentsCount.toString(),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CommentsSheet(postId: post.idPost!),
                  );
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton(BuildContext context) {
    IconData icon;
    Color color;
    
    switch (post.currentUserReaction) {
      case ReactionType.LIKE:
        icon = Icons.favorite;
        color = Colors.red;
        break;
      case ReactionType.FIRE:
        icon = Icons.local_fire_department;
        color = Colors.orange;
        break;
      case ReactionType.STRENGTH:
        icon = Icons.fitness_center;
        color = Colors.blue;
        break;
      case ReactionType.NONE:
      default:
        icon = Icons.favorite_border;
        color = Colors.grey;
        break;
    }

    return GestureDetector(
      onTap: () {
        // Toggle current reaction or default to LIKE
        if (post.currentUserReaction == ReactionType.NONE) {
          onReact(ReactionType.LIKE);
        } else {
          onReact(post.currentUserReaction);
        }
      },
      onLongPress: () {
        _showReactionPicker(context);
      },
      child: Row(
        children: [
          Icon(icon, color: color, size: context.sp(6)),
          SizedBox(width: context.w(0.01)),
          Text(
            post.likesCount.toString(),
            style: GoogleFonts.baloo2(
              fontSize: context.sp(4),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showReactionPicker(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _reactionIcon(context, ReactionType.LIKE, Icons.favorite, Colors.red),
            _reactionIcon(context, ReactionType.FIRE, Icons.local_fire_department, Colors.orange),
            _reactionIcon(context, ReactionType.STRENGTH, Icons.fitness_center, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _reactionIcon(BuildContext context, ReactionType type, IconData icon, Color color) {
    return IconButton(
      icon: Icon(icon, color: color, size: 30),
      onPressed: () {
        Navigator.pop(context);
        onReact(type);
      },
    );
  }

  Widget _buildPostImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageError(),
      );
    } else {
      try {
        // Xử lý chuỗi Base64
        String base64Data = imageUrl;
        if (imageUrl.contains(',')) {
          base64Data = imageUrl.split(',').last;
        }
        return Image.memory(
          base64Decode(base64Data),
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildImageError(),
        );
      } catch (e) {
        return _buildImageError();
      }
    }
  }

  Widget _buildImageError() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  Widget _buildInteractionButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: context.sp(5)),
          SizedBox(width: context.w(0.01)),
          Text(
            label,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(4),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return "Vừa xong";
    if (difference.inMinutes < 60) return "${difference.inMinutes} phút trước";
    if (difference.inHours < 24) return "${difference.inHours} giờ trước";
    if (difference.inDays < 7) return "${difference.inDays} ngày trước";
    
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
