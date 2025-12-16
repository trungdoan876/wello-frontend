import 'package:flutter/material.dart';
import 'package:wello_frontend/ui/favorites/favorites_screen.dart';
import 'package:wello_frontend/ui/home/home_screen.dart';
import 'package:wello_frontend/ui/profile/profile_screen.dart';
import 'package:wello_frontend/ui/widgets/centered_bottom_nav_bar.dart';

//màn hình điều hướng chính với bottom navbar tùy chỉnh
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _hideBottomNav = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onQuickActionsChanged: (show) {
              setState(() {
                _hideBottomNav = show;
              });
            },
          ),
          FavoritesScreen(
            onQuickActionsChanged: (show) {
              setState(() {
                _hideBottomNav = show;
              });
            },
          ),
          ProfileScreen(
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
              onTap: (index) => setState(() => _currentIndex = index),
            ),
    );
  }
}
