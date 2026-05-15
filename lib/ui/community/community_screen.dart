import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/providers/profile_provider.dart';
import 'package:wello_frontend/domain/providers/community_provider.dart';
import 'package:wello_frontend/core/utils/avatar_helper.dart';
import 'package:wello_frontend/ui/community/widgets/post_card.dart';
import 'package:wello_frontend/ui/community/create_post_screen.dart';
import 'package:wello_frontend/ui/profile/profile_screen.dart';
import 'package:wello_frontend/ui/community/widgets/other_user_profile_screen.dart';
import 'package:wello_frontend/ui/community/tagged_posts_screen.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/ui/community/competition/competition_screen.dart';

class CommunityScreen extends StatefulWidget {
  final Function(bool)? onQuickActionsChanged;

  const CommunityScreen({super.key, this.onQuickActionsChanged});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int? _selectedUserId;

  @override
  Widget build(BuildContext context) {
    if (_selectedUserId != null) {
      return WillPopScope(
        onWillPop: () async {
          setState(() => _selectedUserId = null);
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xff2D2D2D)),
              onPressed: () => setState(() => _selectedUserId = null),
            ),
            title: Text(
              'Trang cá nhân',
              style: GoogleFonts.baloo2(
                fontWeight: FontWeight.bold,
                color: const Color(0xff2D2D2D),
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: OtherUserProfileScreen(
            userId: _selectedUserId!,
          ),
        ),
      );
    }

    return _buildFeed(context);
  }

  Widget _buildFeed(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Wello',
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.bold,
            color: const Color(0xff2D2D2D),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined, color: Color(0xff2D2D2D)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CompetitionScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<CommunityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đã có lỗi xảy ra',
                    style: GoogleFonts.baloo2(fontSize: context.sp(5)),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => provider.fetchPosts(refresh: true),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchPosts(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: context.h(0.1)),
              itemCount: provider.posts.length + (provider.hasMore ? 1 : 1), // Always 1 more for the header
              itemBuilder: (context, index) {
                // Header: Create Post Bar
                if (index == 0) {
                  return _buildCreatePostHeader(context);
                }

                final postIndex = index - 1; // Adjust index due to header

                if (postIndex == provider.posts.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xff6C63FF),
                      ),
                    ),
                  );
                }

                final post = provider.posts[postIndex];
                return PostCard(
                  post: post,
                  onReact: (type) => provider.reactPost(post.idPost!, type),
                  onProfileTap: (userId) {
                    setState(() {
                      _selectedUserId = userId;
                    });
                  },
                  onTagTap: (tag) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaggedPostsScreen(tag: tag),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().fetchPosts(refresh: true);
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
      context.read<CommunityProvider>().fetchPosts();
    }
  }

  Widget _buildCreatePostHeader(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final avatarUrl = profileProvider.profileData?.avatarUrl;

    return Container(
      margin: EdgeInsets.all(context.w(0.04)),
      padding: EdgeInsets.all(context.w(0.03)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.w(0.04)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEBCF23).withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFEBCF23).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xffF0F2F5),
            backgroundImage: AvatarHelper.getImageProvider(avatarUrl),
            child: avatarUrl == null 
                ? const Icon(Icons.person, color: Colors.grey) 
                : null,
          ),
          SizedBox(width: context.w(0.03)),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(0.04),
                  vertical: context.h(0.012),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffF0F2F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Bạn đang nghĩ gì?',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4),
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: context.w(0.02)),
          IconButton(
            icon: const Icon(Icons.photo_library, color: Color(0xff45BD62)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePostScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
