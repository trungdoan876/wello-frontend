import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'models/favorite_item.dart';
import 'widgets/empty_favorite_state.dart';
import 'widgets/favorites_tab_bar.dart';
import 'widgets/favorite_item_card.dart';
import 'screens/add_favorite_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<FavoriteItem> favorites = [];
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // TODO: Lấy danh sách yêu thích từ API hoặc database
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
                Icon(Icons.add, size: context.sp(6), color: Colors.white),
                SizedBox(width: context.w(0.03)),
                Icon(Icons.search, size: context.sp(6), color: Colors.white),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          FavoritesTabBar(
            selectedIndex: _selectedTabIndex,
            onTabChanged: (index) => setState(() => _selectedTabIndex = index),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFavoriteScreen()),
          ).then((addedItem) {
            if (addedItem != null && addedItem is FavoriteItem) {
              _addFavorite(addedItem);
            }
          });
        },
        backgroundColor: const Color(0xFF4ECDC4),
        child: Icon(Icons.add, size: context.sp(8), color: Colors.white),
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
