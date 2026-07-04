import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:wello_frontend/domain/entities/post.dart';
import 'package:wello_frontend/ui/profile/profile_screen.dart';
import 'package:wello_frontend/ui/community/widgets/other_user_profile_screen.dart';
import 'package:wello_frontend/core/utils/avatar_helper.dart';
import 'package:wello_frontend/ui/community/widgets/comments_sheet.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/domain/providers/profile_provider.dart';
import 'package:wello_frontend/domain/providers/community_provider.dart';

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
            color: const Color(0xFFEBCF23).withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFEBCF23).withOpacity(0.1),
          width: 1,
        ),
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
                  backgroundColor: const Color(0xFFFFF7DA),
                  backgroundImage: AvatarHelper.getImageProvider(post.authorAvatar),
                  child: post.authorAvatar == null
                      ? Icon(Icons.person,
                          color: const Color(0xFFEBCF23), size: context.w(0.06))
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
                                color: const Color(0xFFEBCF23).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFFEBCF23).withOpacity(0.5)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.stars,
                                      color: const Color(0xFFE68F00), size: context.sp(3.5)),
                                  const SizedBox(width: 2),
                                  Text(
                                    "Thành tích",
                                    style: GoogleFonts.baloo2(
                                      fontSize: context.sp(3),
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFFE68F00),
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
                _buildMoreButton(context),
              ],
            ),
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
                      color: const Color(0xFFEBCF23).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#$tag',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(3.5),
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFE68F00),
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

  Widget _buildMoreButton(BuildContext context) {
    final currentUserId = context.watch<ProfileProvider>().profileData?.userId;
    if (post.authorId == null || post.authorId != currentUserId) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: const Icon(Icons.more_horiz, color: Colors.grey),
      onPressed: () => _showPostOptions(context),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Colors.blue),
              title: Text(
                'Chỉnh sửa bài viết',
                style: GoogleFonts.baloo2(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _showEditDialog(context);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                'Xóa bài viết',
                style: GoogleFonts.baloo2(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _showDeleteConfirmation(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Xóa bài viết',
      text: 'Bạn có chắc chắn muốn xóa bài viết này không?',
      confirmBtnText: 'Xóa',
      cancelBtnText: 'Hủy',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        Navigator.pop(sheetContextOfAlert(context)); // Close QuickAlert
        
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFEBCF23),
            ),
          ),
        );
        
        final success = await context.read<CommunityProvider>().deletePost(post.idPost!);
        
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
        }
        
        if (success) {
          if (context.mounted) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              text: 'Đã xóa bài viết thành công!',
            );
          }
        } else {
          if (context.mounted) {
            final error = context.read<CommunityProvider>().errorMessage;
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              text: 'Lỗi khi xóa bài viết: $error',
            );
          }
        }
      },
    );
  }

  // Helper method to safely pop the alert dialog context
  BuildContext sheetContextOfAlert(BuildContext context) => context;

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _EditPostDialog(post: post);
      },
    );
  }
}

class _EditPostDialog extends StatefulWidget {
  final Post post;
  const _EditPostDialog({required this.post});

  @override
  State<_EditPostDialog> createState() => _EditPostDialogState();
}

class _EditPostDialogState extends State<_EditPostDialog> {
  late TextEditingController _controller;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _removeImage = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.post.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _removeImage = false;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Thư viện'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Máy ảnh'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUploading = context.watch<CommunityProvider>().isLoading;
    
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Chỉnh sửa bài viết',
        style: GoogleFonts.baloo2(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                maxLines: 5,
                style: GoogleFonts.baloo2(fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Bạn đang nghĩ gì?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (!_removeImage && (_imageFile != null || widget.post.imageUrl != null)) ...[
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _imageFile != null
                          ? Image.file(
                              _imageFile!,
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                            )
                          : _buildDialogPostImage(widget.post.imageUrl!),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _imageFile = null;
                            _removeImage = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _showImagePickerOptions,
                    icon: const Icon(Icons.add_photo_alternate, color: Colors.green),
                    label: Text(
                      'Đổi ảnh',
                      style: GoogleFonts.baloo2(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isUploading ? null : () => Navigator.pop(context),
          child: Text(
            'Hủy',
            style: GoogleFonts.baloo2(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEBCF23),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: isUploading ? null : _submitEdit,
          child: isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  'Lưu',
                  style: GoogleFonts.baloo2(color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Widget _buildDialogPostImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
      );
    } else {
      try {
        String base64Data = imageUrl;
        if (imageUrl.contains(',')) {
          base64Data = imageUrl.split(',').last;
        }
        return Image.memory(
          base64Decode(base64Data),
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
        );
      } catch (e) {
        return Container(
          width: double.infinity,
          height: 150,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      }
    }
  }

  Future<void> _submitEdit() async {
    if (_controller.text.trim().isEmpty && _imageFile == null && _removeImage) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: 'Vui lòng nhập nội dung hoặc chọn ảnh!',
      );
      return;
    }

    final success = await context.read<CommunityProvider>().editPost(
          postId: widget.post.idPost!,
          content: _controller.text.trim(),
          imageFile: _imageFile,
          keepImage: !_removeImage,
        );

    if (success) {
      if (mounted) {
        Navigator.pop(context); // Close dialog
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Đã cập nhật bài viết thành công!',
        );
      }
    } else {
      if (mounted) {
        final error = context.read<CommunityProvider>().errorMessage;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Lỗi khi cập nhật bài viết: $error',
        );
      }
    }
  }
}
