import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import '../../../domain/providers/competition_provider.dart';
import 'widgets/badge_grid_widget.dart';
import 'widgets/leaderboard_widget.dart';

class CompetitionScreen extends StatefulWidget {
  const CompetitionScreen({super.key});

  @override
  State<CompetitionScreen> createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging || _tabController.index == 1) {
      if (_tabController.index == 1) {
        // Refresh badges when navigating to Badges tab
        context.read<CompetitionProvider>().fetchBadges();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEBCF23), Color(0xFFFFB300)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Thi Đua & Thành Tích',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF3F3D3F),
            fontSize: 22,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF3F3D3F),
          indicatorWeight: 4,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: const Color(0xFF3F3D3F),
          unselectedLabelColor: const Color(0xFF7D7A7D),
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          isScrollable: false,
          tabs: const [
            Tab(text: 'Xếp Hạng'),
            Tab(text: 'Huy Hiệu'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const LeaderboardWidget(),
          _buildBadgesTab(),
        ],
      ),
    );
  }

  Widget _buildBadgesTab() {
    return Consumer<CompetitionProvider>(
      builder: (context, provider, child) {
        try {
          if (provider.badges.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có huy hiệu nào',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bộ Sưu Tập Của Bạn',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bạn đã đạt được ${provider.badges.where((b) => b.isUnlocked).length}/${provider.badges.length} huy hiệu',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                BadgeGridWidget(badges: provider.badges),
              ],
            ),
          );
        } catch (e) {
          return Center(child: Text('Lỗi tải huy hiệu: $e'));
        }
      },
    );
  }
}
