import 'package:flutter/material.dart';
import 'package:wello_frontend/ui/favorites/favorites_screen.dart';
import 'package:wello_frontend/ui/favorites/screens/add_favorite_screen.dart';
import 'package:wello_frontend/ui/home/home_screen.dart';
import 'package:wello_frontend/ui/profile/profile_screen.dart';
import 'package:wello_frontend/ui/widgets/centered_bottom_nav_bar.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

//màn hình điều hướng chính với bottom navbar tùy chỉnh
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _hideBottomNav = false;
  bool _quickActionsOpen = false;

  void _onFloatingButtonPressed() {
    if (_currentIndex == 0) {
      // Home screen - toggle quick actions
      setState(() => _quickActionsOpen = !_quickActionsOpen);
    } else if (_currentIndex == 1) {
      // Favorites screen - navigate to add favorite
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddFavoriteScreen()),
      );
    }
  }

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
                _quickActionsOpen = show;
              });
            },
          ),
          const FavoritesScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: _hideBottomNav
          ? null
          : FloatingActionButton(
              onPressed: _onFloatingButtonPressed,
              backgroundColor: const Color(0xFF4ECDC4),
              child: AnimatedRotation(
                turns: (_currentIndex == 0 && _quickActionsOpen) ? 0.125 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.add,
                  size: context.sp(8),
                  color: Colors.white,
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _hideBottomNav
          ? null
          : CenteredBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
    );
  }
}
