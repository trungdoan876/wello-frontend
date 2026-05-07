import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/providers/community_provider.dart';
import 'package:wello_frontend/ui/community/widgets/post_card.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class TaggedPostsScreen extends StatefulWidget {
  final String tag;

  const TaggedPostsScreen({super.key, required this.tag});

  @override
  State<TaggedPostsScreen> createState() => _TaggedPostsScreenState();
}

class _TaggedPostsScreenState extends State<TaggedPostsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().fetchPostsByTag(widget.tag, refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      appBar: AppBar(
        title: Text(
          '#${widget.tag}',
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.bold,
            color: const Color(0xff2D2D2D),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CommunityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.taggedPosts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.taggedPosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tag_faces, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy bài viết nào cho #${widget.tag}',
                    style: GoogleFonts.baloo2(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchPostsByTag(widget.tag, refresh: true),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: context.h(0.01)),
              itemCount: provider.taggedPosts.length,
              itemBuilder: (context, index) {
                final post = provider.taggedPosts[index];
                return PostCard(
                  post: post,
                  onReact: (type) => provider.reactPost(post.idPost!, type),
                  onTagTap: (tag) {
                    if (tag != widget.tag) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaggedPostsScreen(tag: tag),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
