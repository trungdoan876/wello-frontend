import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class FavoriteEmptyState extends StatelessWidget {
  const FavoriteEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
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
}
