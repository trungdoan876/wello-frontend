import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import '../models/favorite_item.dart';

class AddFavoriteItemCard extends StatelessWidget {
  final FavoriteItem item;
  final VoidCallback onAdd;

  const AddFavoriteItemCard({Key? key, required this.item, required this.onAdd})
    : super(key: key);

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
                mainAxisSize: MainAxisSize.min,
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
            SizedBox(width: context.w(0.02)),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: context.sp(11),
                height: context.sp(11),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: context.sp(6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
