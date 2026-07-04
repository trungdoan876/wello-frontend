import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/providers/competition_provider.dart';
import '../../../../domain/providers/profile_provider.dart';
import '../../../../core/utils/avatar_helper.dart';

class LeaderboardWidget extends StatefulWidget {
  const LeaderboardWidget({super.key});

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  String _selectedType = 'STEPS'; // STEPS, CALORIES, STREAKS
  String _selectedPeriod = 'WEEKLY'; // DAILY, WEEKLY, MONTHLY

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompetitionProvider>().fetchLeaderboard(_selectedType, _selectedPeriod);
    });
  }

  void _onFilterChanged() {
    context.read<CompetitionProvider>().fetchLeaderboard(_selectedType, _selectedPeriod);
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final currentUserId = profileProvider.profileData?.userId;

    return Container(
      color: const Color(0xFFF9F9FB),
      child: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Consumer<CompetitionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.leaderboardEntries.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFFB300),
                    ),
                  );
                }

                if (provider.leaderboardEntries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFDE7),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFB300).withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.leaderboard_outlined,
                            size: 64,
                            color: Color(0xFFFFB300),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Chưa có dữ liệu xếp hạng',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF3F3D3F),
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hãy bắt đầu luyện tập để có tên trên bảng vàng!',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: const Color(0xFFFFB300),
                  onRefresh: () => provider.fetchLeaderboard(_selectedType, _selectedPeriod),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      if (provider.leaderboardEntries.isNotEmpty)
                        _buildPodium(provider.leaderboardEntries.take(3).toList()),
                      const SizedBox(height: 16),
                      // List title
                      Row(
                        children: [
                          const Icon(Icons.star_outline_rounded, color: Color(0xFFE68F00), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Xếp Hạng Bước Chân',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: const Color(0xFF3F3D3F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...provider.leaderboardEntries.skip(provider.leaderboardEntries.length < 3 ? provider.leaderboardEntries.length : 3).map((entry) => _buildRankItem(entry, currentUserId)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildPeriodSelector(),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F4),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: 'Ngày',
              isSelected: _selectedPeriod == 'DAILY',
              onTap: () {
                setState(() => _selectedPeriod = 'DAILY');
                _onFilterChanged();
              },
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: 'Tuần',
              isSelected: _selectedPeriod == 'WEEKLY',
              onTap: () {
                setState(() => _selectedPeriod = 'WEEKLY');
                _onFilterChanged();
              },
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: 'Tháng',
              isSelected: _selectedPeriod == 'MONTHLY',
              onTap: () {
                setState(() => _selectedPeriod = 'MONTHLY');
                _onFilterChanged();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> top3) {
    final first = top3[0];
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Container(
      height: 300,
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEBCF23).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFEBCF23).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (second != null)
            _PodiumItem(
              rank: 2,
              name: second['fullName'] ?? 'User',
              score: _formatScore(second['score']),
              height: 120,
              gradientColors: const [Color(0xFFCFD8DC), Color(0xFF90A4AE)], // Silver
              avatarUrl: second['avatarUrl'],
            )
          else
            const Spacer(),
          _PodiumItem(
            rank: 1,
            name: first['fullName'] ?? 'User',
            score: _formatScore(first['score']),
            height: 155,
            gradientColors: const [Color(0xFFFFF176), Color(0xFFFFB300)], // Gold
            avatarUrl: first['avatarUrl'],
            isFirst: true,
          ),
          if (third != null)
            _PodiumItem(
              rank: 3,
              name: third['fullName'] ?? 'User',
              score: _formatScore(third['score']),
              height: 100,
              gradientColors: const [Color(0xFFFFCC80), Color(0xFFCA9072)], // Bronze
              avatarUrl: third['avatarUrl'],
            )
          else
            const Spacer(),
        ],
      ),
    );
  }

  String _formatScore(dynamic score) {
    if (score == null) return '0';
    return '${score.toInt()}';
  }

  IconData _getScoreIcon() {
    return Icons.directions_walk_rounded;
  }

  Color _getScoreIconColor() {
    return const Color(0xFF4CAF50);
  }

  Widget _buildRankItem(Map<String, dynamic> entry, int? currentUserId) {
    final bool isCurrentUser = entry['userId'] != null && entry['userId'] == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFFFFFDF0) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isCurrentUser
                ? const Color(0xFFFFB300).withOpacity(0.12)
                : Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isCurrentUser
              ? const Color(0xFFFFB300).withOpacity(0.6)
              : const Color(0xFFF0F0F2),
          width: isCurrentUser ? 2.0 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Rank text
          SizedBox(
            width: 32,
            child: Text(
              '#${entry['rank']}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: entry['rank'] <= 10 ? const Color(0xFF3F3D3F) : Colors.grey[400],
              ),
            ),
          ),
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrentUser ? const Color(0xFFFFB300) : Colors.grey[100]!,
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xffF0F2F5),
              backgroundImage: AvatarHelper.getImageProvider(entry['avatarUrl']),
              child: AvatarHelper.getImageProvider(entry['avatarUrl']) == null
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Profile Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        entry['fullName'] ?? 'Người dùng Wello',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isCurrentUser ? const Color(0xFFE68F00) : const Color(0xFF3F3D3F),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                         decoration: BoxDecoration(
                           gradient: const LinearGradient(
                             colors: [Color(0xFFE68F00), Color(0xFFFFB300)],
                             begin: Alignment.topLeft,
                             end: Alignment.bottomRight,
                           ),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: const Text(
                           'Bạn',
                           style: TextStyle(
                             color: Colors.white,
                             fontWeight: FontWeight.w900,
                             fontSize: 10,
                           ),
                         ),
                       ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Hạng ${entry['rank']}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Score and icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getScoreIcon(),
                color: _getScoreIconColor(),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                _formatScore(entry['score']),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: _getScoreIconColor(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFEBCF23), Color(0xFFFFB300)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFB300) : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? const Color(0xFF3F3D3F) : const Color(0xFF7D7A7D),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF3F3D3F) : const Color(0xFF7D7A7D),
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFE68F00), Color(0xFFFFB300)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFE68F00).withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF7D7A7D),
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final int rank;
  final String name;
  final String score;
  final double height;
  final List<Color> gradientColors;
  final String? avatarUrl;
  final bool isFirst;

  const _PodiumItem({
    required this.rank,
    required this.name,
    required this.score,
    required this.height,
    required this.gradientColors,
    required this.avatarUrl,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = gradientColors.first;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: isFirst ? 14 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: isFirst ? 36 : 28,
                  backgroundColor: const Color(0xffF0F2F5),
                  backgroundImage: AvatarHelper.getImageProvider(avatarUrl),
                  child: AvatarHelper.getImageProvider(avatarUrl) == null
                      ? Icon(
                          Icons.person,
                          size: isFirst ? 36 : 28,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
              Positioned(
                top: isFirst ? -22 : -16,
                child: isFirst
                    ? const Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFFFFD700),
                        size: 28,
                      )
                    : Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: isFirst ? 18 : 14,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: isFirst ? 14 : 12,
                color: const Color(0xFF3F3D3F),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: height,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  accentColor,
                  accentColor.withOpacity(0.8),
                  gradientColors.last.withOpacity(0.6),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '#$rank',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: isFirst ? 32 : 24,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.25),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    score,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: isFirst ? 13 : 11,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
