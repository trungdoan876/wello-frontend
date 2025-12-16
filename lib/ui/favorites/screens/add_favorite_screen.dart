import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import '../models/favorite_item.dart';
import '../widgets/add_favorite_item_card.dart';

class AddFavoriteScreen extends StatefulWidget {
  const AddFavoriteScreen({Key? key}) : super(key: key);

  @override
  State<AddFavoriteScreen> createState() => _AddFavoriteScreenState();
}

class _AddFavoriteScreenState extends State<AddFavoriteScreen> {
  late TextEditingController _searchController;
  List<FavoriteItem> _filteredItems = [];
  List<FavoriteItem> _allItems = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadItems();
    _filterItems('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadItems() {
    _allItems = [
      const FavoriteItem(
        name: 'Cơm ếch',
        description: '1 khẩu phần ăn - 203 calo',
        calories: 203,
        id: '1',
      ),
      const FavoriteItem(
        name: 'Cơm gà',
        description: '1 khẩu phần ăn - 250 calo',
        calories: 250,
        id: '2',
      ),
      const FavoriteItem(
        name: 'Cơm bò',
        description: '1 khẩu phần ăn - 280 calo',
        calories: 280,
        id: '3',
      ),
      const FavoriteItem(
        name: 'Canh chua',
        description: '1 tô - 50 calo',
        calories: 50,
        id: '4',
      ),
      const FavoriteItem(
        name: 'Salad rau',
        description: '1 bát - 80 calo',
        calories: 80,
        id: '5',
      ),
      const FavoriteItem(
        name: 'Xúc xích',
        description: '1 cái - 150 calo',
        calories: 150,
        id: '6',
      ),
    ];
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems
            .where(
              (item) =>
                  item.name.toLowerCase().contains(query.toLowerCase()) ||
                  item.description.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back,
            color: Colors.grey.shade600,
            size: context.sp(6),
          ),
        ),
        title: Text(
          'Thêm yêu thích',
          style: GoogleFonts.baloo2(
            fontSize: context.sp(6),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4ECDC4),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(context.w(0.04)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterItems,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm...',
                  hintStyle: GoogleFonts.baloo2(
                    fontSize: context.sp(3.5),
                    color: Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                    size: context.sp(5),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: context.h(0.02),
                  ),
                ),
              ),
            ),
          ),
          // Items list
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Text(
                      'Không tìm thấy',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4),
                        color: Colors.grey.shade400,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: context.w(0.04)),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: context.h(0.015)),
                        child: AddFavoriteItemCard(
                          item: item,
                          onAdd: () {
                            Navigator.pop(context, item);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
