import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class MealSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const MealSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.w(0.04)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 254, 254, 254),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm...',
            hintStyle: GoogleFonts.baloo2(
              fontSize: context.sp(4.5),
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
    );
  }
}
