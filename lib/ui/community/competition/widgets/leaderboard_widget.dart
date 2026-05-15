import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/providers/competition_provider.dart';

class LeaderboardWidget extends StatefulWidget {
  const LeaderboardWidget({super.key});

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  String _selectedType = 'STEPS'; // STEPS, CALORIES, STREAK
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
    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: Consumer<CompetitionProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.leaderboardEntries.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (provider.leaderboardEntries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.leaderboard_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text('Chưa có dữ liệu xếp hạng'),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => provider.fetchLeaderboard(_selectedType, _selectedPeriod),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (provider.leaderboardEntries.length >= 3)
                      _buildPodium(provider.leaderboardEntries.take(3).toList()),
                    const SizedBox(height: 24),
                    ...provider.leaderboardEntries.skip(3).map((entry) => _buildRankItem(entry)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      color: Colors.white,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Bước chân',
                  isSelected: _selectedType == 'STEPS',
                  onTap: () {
                    setState(() => _selectedType = 'STEPS');
                    _onFilterChanged();
                  },
                ),
                _FilterChip(
                  label: 'Calo tiêu thụ',
                  isSelected: _selectedType == 'CALORIES',
                  onTap: () {
                    setState(() => _selectedType = 'CALORIES');
                    _onFilterChanged();
                  },
                ),
                _FilterChip(
                  label: 'Chuỗi hoạt động',
                  isSelected: _selectedType == 'STREAK',
                  onTap: () {
                    setState(() => _selectedType = 'STREAK');
                    _onFilterChanged();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PeriodButton(
                label: 'Ngày',
                isSelected: _selectedPeriod == 'DAILY',
                onTap: () {
                  setState(() => _selectedPeriod = 'DAILY');
                  _onFilterChanged();
                },
              ),
              _PeriodButton(
                label: 'Tuần',
                isSelected: _selectedPeriod == 'WEEKLY',
                onTap: () {
                  setState(() => _selectedPeriod = 'WEEKLY');
                  _onFilterChanged();
                },
              ),
              _PeriodButton(
                label: 'Tháng',
                isSelected: _selectedPeriod == 'MONTHLY',
                onTap: () {
                  setState(() => _selectedPeriod = 'MONTHLY');
                  _onFilterChanged();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> top3) {
    // top3 is sorted 1, 2, 3. For UI, we want [2, 1, 3]
    final first = top3[0];
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (second != null)
            _PodiumItem(
              rank: 2,
              name: second['fullName'] ?? 'User',
              score: _formatScore(second['score']),
              height: 150,
              color: const Color(0xFFBDBDBD), // Silver
              avatarUrl: second['avatarUrl'] ?? 'https://i.pravatar.cc/150?u=${second['userId']}',
            )
          else
            const Spacer(),
          _PodiumItem(
            rank: 1,
            name: first['fullName'] ?? 'User',
            score: _formatScore(first['score']),
            height: 190,
            color: const Color(0xFFFFD700), // Gold
            avatarUrl: first['avatarUrl'] ?? 'https://i.pravatar.cc/150?u=${first['userId']}',
            isFirst: true,
          ),
          if (third != null)
            _PodiumItem(
              rank: 3,
              name: third['fullName'] ?? 'User',
              score: _formatScore(third['score']),
              height: 130,
              color: const Color(0xFFCD7F32), // Bronze
              avatarUrl: third['avatarUrl'] ?? 'https://i.pravatar.cc/150?u=${third['userId']}',
            )
          else
            const Spacer(),
        ],
      ),
    );
  }

  String _formatScore(dynamic score) {
    if (score == null) return '0';
    if (_selectedType == 'STEPS') return '${score.toInt()}';
    if (_selectedType == 'CALORIES') return '${score.toInt()} kcal';
    if (_selectedType == 'STREAK') return '${score.toInt()} ngày';
    return score.toString();
  }

  Widget _buildRankItem(Map<String, dynamic> entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEBCF23).withOpacity(0.12),
            blurRadius: 12,
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
          SizedBox(
            width: 30,
            child: Text(
              '#${entry['rank']}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(entry['avatarUrl'] ?? 'https://i.pravatar.cc/150?u=${entry['userId']}'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['fullName'] ?? 'Người dùng Wello',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  'Hạng ${entry['rank']}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            _formatScore(entry['score']),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Color(0xFFE68F00),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEBCF23) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFB300) : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: const Color(0xFFEBCF23).withOpacity(0.3), blurRadius: 8)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF3F3D3F) : const Color(0xFF7D7A7D),
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFFEBCF23) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFE68F00) : const Color(0xFF7D7A7D),
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
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
  final Color color;
  final String avatarUrl;
  final bool isFirst;

  const _PodiumItem({
    required this.rank,
    required this.name,
    required this.score,
    required this.height,
    required this.color,
    required this.avatarUrl,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
                child: CircleAvatar(
                  radius: isFirst ? 35 : 28,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
              ),
              if (isFirst)
                Positioned(
                  top: -10,
                  child: Icon(Icons.workspace_premium, color: color, size: 24),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            height: height,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color, color.withOpacity(0.5)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '#$rank',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                ),
                Text(
                  score,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
