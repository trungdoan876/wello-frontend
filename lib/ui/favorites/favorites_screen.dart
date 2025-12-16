import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/favorites/screens/add_favorite_screen.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/ui/widgets/quick_actions_overlay.dart';
import 'models/favorite_item.dart';
import 'widgets/empty_favorite_state.dart';
import 'widgets/favorites_tab_bar.dart';
import 'widgets/favorite_item_card.dart';

class FavoritesScreen extends StatefulWidget {
  final Function(bool)? onQuickActionsChanged;

  const FavoritesScreen({Key? key, this.onQuickActionsChanged})
    : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<FavoriteItem> favorites = [];
  int _selectedTabIndex = 0;
  bool _showQuickActions = false;

  @override
  void initState() {
    super.initState();
    // TODO: Lấy danh sách yêu thích từ API hoặc database
  }

  void _setQuickActionsVisible(bool show) {
    setState(() => _showQuickActions = show);
    widget.onQuickActionsChanged?.call(show);
  }

  void _handleQuickAction(String key) {
    _setQuickActionsVisible(false);
    // TODO: điều hướng theo key
  }

  void _addFavorite(FavoriteItem item) {
    setState(() {
      if (!favorites.any((f) => f.id == item.id)) {
        favorites.add(item);
      }
    });
  }

  void _removeFavorite(String id) {
    setState(() {
      favorites.removeWhere((f) => f.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double navHeight = _showQuickActions ? 0 : context.h(0.05);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFC107),
        title: Text(
          'Mục yêu thích',
          style: GoogleFonts.baloo2(
            fontSize: context.sp(7),
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(0.08)),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddFavoriteScreen(),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.add,
                    size: context.sp(6),
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: context.w(0.03)),
                Icon(Icons.search, size: context.sp(6), color: Colors.white),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Tab bar
              FavoritesTabBar(
                selectedIndex: _selectedTabIndex,
                onTabChanged: (index) =>
                    setState(() => _selectedTabIndex = index),
              ),
              SizedBox(height: context.h(0.02)),
              // Content
              Expanded(
                child: _selectedTabIndex == 0
                    ? const EmptyFavoriteState()
                    : _buildFavoritesContent(context),
              ),
            ],
          ),
          // Lớp phủ mờ khi mở quick actions
          if (_showQuickActions)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _setQuickActionsVisible(false),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: 0.45,
                  child: Container(color: Colors.black),
                ),
              ),
            ),
          // Panel quick actions + nút dấu cộng
          Positioned(
            right: context.w(0.05),
            bottom: _showQuickActions
                ? context.h(0.015)
                : navHeight + context.h(0.01),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedSlide(
                  offset: _showQuickActions
                      ? const Offset(0, 0)
                      : const Offset(0, 0.2),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _showQuickActions ? 1 : 0,
                    child: QuickActionsPanel(onAction: _handleQuickAction),
                  ),
                ),
                SizedBox(height: context.h(0.012)),
                PlusBubble(
                  onTap: () => _setQuickActionsVisible(!_showQuickActions),
                  open: _showQuickActions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesContent(BuildContext context) {
    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: context.sp(15),
              color: Colors.grey.shade300,
            ),
            SizedBox(height: context.h(0.02)),
            Text(
              'Chưa có món ăn yêu thích',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(4),
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(context.w(0.04)),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final item = favorites[index];
        return Padding(
          padding: EdgeInsets.only(bottom: context.h(0.015)),
          child: FavoriteItemCard(
            item: item,
            onAdd: () {
              // TODO: Thêm item vào meal
            },
            onRemove: () => _removeFavorite(item.id),
          ),
        );
      },
    );
  }
}
