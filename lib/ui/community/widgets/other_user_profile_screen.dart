import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/providers/profile_provider.dart';
import 'package:wello_frontend/domain/providers/community_provider.dart';
import '../../../data/models/responses/profile_response_model.dart';
import 'package:wello_frontend/core/utils/avatar_helper.dart';
import 'package:wello_frontend/ui/community/chat/chat_screen.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/ui/community/widgets/post_card.dart';
import 'package:wello_frontend/ui/community/tagged_posts_screen.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final int userId;

  const OtherUserProfileScreen({super.key, required this.userId});

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  // Local copy of the profile to prevent UI being updated if global
  // ProfileProvider is changed elsewhere (e.g., to current user's profile).
  ProfileResponseModel? _localProfile;
  VoidCallback? _providerListener;
  @override
  void initState() {
    super.initState();
    debugPrint('[OtherProfile] initState for userId: ${widget.userId}');
    _loadData();
  }

  @override
  void dispose() {
    if (_providerListener != null) {
      try {
        context.read<ProfileProvider>().removeListener(_providerListener!);
      } catch (_) {}
      _providerListener = null;
    }
    super.dispose();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();

      // Attach a one-time listener to capture the loaded profile for this
      // user and keep a local copy so the UI doesn't change if the global
      // provider is later updated with another user's profile.
      _providerListener = () {
        final p = provider.profileData;
        if (p != null && p.userId == widget.userId) {
          setState(() => _localProfile = p);
          // remove listener after capture
          if (_providerListener != null)
            provider.removeListener(_providerListener!);
          _providerListener = null;
        }
      };
      provider.addListener(_providerListener!);

      provider.loadProfile(widget.userId);
      context.read<CommunityProvider>().fetchUserPosts(
        widget.userId,
        refresh: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          final profile = _localProfile ?? profileProvider.profileData;
          final isLoading = profileProvider.isLoading;

          if (isLoading && profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profile == null) {
            return const Center(child: Text('Không tìm thấy người dùng'));
          }

          return CustomScrollView(
            slivers: [
              // Header section
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(
                    top: context.h(0.02),
                    bottom: context.h(0.03),
                    left: context.w(0.06),
                    right: context.w(0.06),
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(
                          0xFFEBCF23,
                        ).withOpacity(0.2),
                        backgroundImage: AvatarHelper.getImageProvider(
                          profile.avatarUrl,
                        ),
                        child: profile.avatarUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.fullname,
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(7),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatBadge(
                            context,
                            Icons.local_fire_department,
                            '${profile.streakCount} streaks',
                            Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          _buildStatBadge(
                            context,
                            Icons.article_rounded,
                            '${context.watch<CommunityProvider>().userPosts.length} bài viết',
                            Colors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildChatButton(
                        context,
                        profile.userId,
                        profile.fullname,
                        profile.avatarUrl,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Posts Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.w(0.06)),
                  child: Text(
                    'Hoạt động gần đây',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(5.5),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4C494C),
                    ),
                  ),
                ),
              ),

              // Posts list
              Consumer<CommunityProvider>(
                builder: (context, communityProvider, _) {
                  final posts = communityProvider.userPosts;

                  if (communityProvider.isLoading && posts.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (posts.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.post_add,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có bài viết nào.',
                              style: GoogleFonts.baloo2(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final post = posts[index];
                        return PostCard(
                          post: post,
                          onReact: (type) =>
                              communityProvider.reactPost(post.idPost!, type),
                          onTagTap: (tag) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TaggedPostsScreen(tag: tag),
                              ),
                            );
                          },
                        );
                      }, childCount: posts.length),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatBadge(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(3.8),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatButton(
    BuildContext context,
    int userId,
    String fullname,
    String? avatarUrl,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final creds = await AuthHelper.getCredentials();
          final currentUserId = creds?.userId;
          debugPrint(
            '[OtherProfile] open chat: target=$userId, current=$currentUserId',
          );

          if (currentUserId != null && currentUserId == userId) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể nhắn tin với chính mình'),
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                partnerId: userId,
                partnerName: fullname,
                partnerAvatarUrl: avatarUrl,
              ),
            ),
          );
        },
        icon: const Icon(Icons.chat_bubble_outline_rounded),
        label: Text(
          'Nhắn tin',
          style: GoogleFonts.baloo2(
            fontSize: context.sp(4.2),
            fontWeight: FontWeight.w900,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEBCF23),
          foregroundColor: const Color(0xFF2D2D2D),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
