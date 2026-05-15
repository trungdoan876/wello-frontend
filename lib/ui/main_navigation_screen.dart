import 'package:flutter/material.dart';
import 'package:wello_frontend/ui/favorites/favorites_screen.dart';
import 'package:wello_frontend/ui/home/home_screen.dart';
import 'package:wello_frontend/ui/profile/profile_screen.dart';
import 'package:wello_frontend/ui/community/community_screen.dart';
import 'package:wello_frontend/ui/running/running_screen.dart';
import 'package:wello_frontend/ui/widgets/centered_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/providers/profile_provider.dart';
import 'package:wello_frontend/core/utils/user_session.dart';

//màn hình điều hướng chính với bottom navbar tùy chỉnh
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _hideBottomNav = false;
  int _homeReloadId = 0;
  int _favoritesReloadId = 0;
  int _communityReloadId = 0;
  int _profileReloadId = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final userId = await UserSession.getUserId();
    if (userId != null && mounted) {
      context.read<ProfileProvider>().loadProfile(userId);
    }
  }

  int _runningReloadId = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) _homeReloadId++;
      if (index == 1) _favoritesReloadId++;
      if (index == 2) _communityReloadId++;
      if (index == 3) _profileReloadId++;
      if (index == 4) _runningReloadId++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(
              key: ValueKey('home_$_homeReloadId'),
              onQuickActionsChanged: (show) {
                setState(() {
                  _hideBottomNav = show;
                });
              },
            ),
            FavoritesScreen(
              key: ValueKey('fav_$_favoritesReloadId'),
              onQuickActionsChanged: (show) {
                setState(() {
                  _hideBottomNav = show;
                });
              },
            ),
            CommunityScreen(
              key: ValueKey('community_$_communityReloadId'),
              onQuickActionsChanged: (show) {
                setState(() {
                  _hideBottomNav = show;
                });
              },
            ),
            ProfileScreen(
              key: ValueKey('profile_$_profileReloadId'),
              onQuickActionsChanged: (show) {
                setState(() {
                  _hideBottomNav = show;
                });
              },
            ),
            RunningScreen(
              key: ValueKey('running_$_runningReloadId'),
              onQuickActionsChanged: (show) {
                setState(() {
                  _hideBottomNav = show;
                });
              },
            ),
          ],
        ),
        bottomNavigationBar: _hideBottomNav
            ? null
            : CenteredBottomNavBar(
                currentIndex: _currentIndex,
                onTap: _onTabSelected,
                items: const [
                  CenteredBottomNavItem(icon: Icons.home, label: 'Nhật ký'),
                  CenteredBottomNavItem(
                    icon: Icons.favorite,
                    label: 'Mục yêu thích',
                  ),
                  CenteredBottomNavItem(icon: Icons.people, label: 'Wello'),
                  CenteredBottomNavItem(icon: Icons.person, label: 'Cá nhân'),
                  CenteredBottomNavItem(
                    icon: Icons.directions_run,
                    label: 'Chạy bộ',
                  ),
                ],
              ),
      );
  }
}
