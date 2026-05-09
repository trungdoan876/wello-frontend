import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:wello_frontend/domain/entities/post.dart';
import 'package:wello_frontend/domain/providers/community_provider.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  PostType _selectedType = PostType.MANUAL;

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
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Máy ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_contentController.text.trim().isEmpty && _imageFile == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: 'Vui lòng nhập nội dung hoặc chọn ảnh!',
      );
      return;
    }

    final success = await context.read<CommunityProvider>().createPost(
          content: _contentController.text.trim(),
          imageFile: _imageFile,
        );

    if (success) {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Đăng bài thành công!',
          onConfirmBtnTap: () {
            Navigator.pop(context); // Close alert
            Navigator.pop(context); // Back to feed
          },
        );
      }
    } else {
      if (mounted) {
        final error = context.read<CommunityProvider>().errorMessage;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Lỗi khi đăng bài: $error',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Tạo bài viết',
          style: GoogleFonts.baloo2(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: context.watch<CommunityProvider>().isUploading ? null : _submit,
            child: Text(
              'Đăng',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(5),
                fontWeight: FontWeight.bold,
                color: const Color(0xff6C63FF),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(context.w(0.04)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info placeholder
                Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
                    SizedBox(width: context.w(0.03)),
                    Text(
                      'Bạn đang nghĩ gì?',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4.5),
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.h(0.02)),
                
                // Content input
                TextField(
                  controller: _contentController,
                  maxLines: 8,
                  minLines: 3,
                  style: GoogleFonts.baloo2(fontSize: context.sp(4.5)),
                  decoration: const InputDecoration(
                    hintText: 'Nhập nội dung bài viết...',
                    border: InputBorder.none,
                  ),
                ),
                
                SizedBox(height: context.h(0.02)),
                
                // Image preview
                if (_imageFile != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(context.w(0.04)),
                        child: Image.file(
                          _imageFile!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => setState(() => _imageFile = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                
                SizedBox(height: context.h(0.05)),
                
                // Attachment buttons
                Row(
                  children: [
                    _buildActionButton(
                      context,
                      Icons.image_rounded,
                      'Thêm ảnh',
                      const Color(0xff4CAF50),
                      _showImageSourceActionSheet,
                    ),
                    SizedBox(width: context.w(0.04)),
                    _buildActionButton(
                      context,
                      Icons.stars_rounded,
                      'Thành tích',
                      const Color(0xffFF9800),
                      () {
                        setState(() {
                          _selectedType = _selectedType == PostType.MANUAL 
                              ? PostType.ACHIEVEMENT 
                              : PostType.MANUAL;
                        });
                      },
                      isSelected: _selectedType == PostType.ACHIEVEMENT,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          if (context.watch<CommunityProvider>().isUploading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap, {
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(0.04),
          vertical: context.h(0.015),
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: color) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: context.sp(5)),
            SizedBox(width: context.w(0.02)),
            Text(
              label,
              style: GoogleFonts.baloo2(
                fontSize: context.sp(4),
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
