import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import '../models/favorite_item.dart';

class FavoriteItemCard extends StatelessWidget {
  final FavoriteItem item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const FavoriteItemCard({
    required this.item,
    required this.onAdd,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(0.04),
          vertical: context.h(0.015),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(4),
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: context.h(0.005)),
                  Text(
                    item.description,
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(3),
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _circleButton(context, icon: Icons.add, onTap: () {}),
                SizedBox(width: context.w(0.02)),
                _circleButton(context, icon: Icons.close, onTap: onRemove),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.sp(10),
        height: context.sp(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: context.sp(5), color: Colors.grey.shade600),
      ),
    );
  }
}
