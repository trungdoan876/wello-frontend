import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import '../selection_screen.dart';

class SuggestionMealCard extends StatelessWidget {
  final MealItem item;
  final VoidCallback onAdd;

  const SuggestionMealCard({
    super.key,
    required this.item,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final caloriesColor = const Color(0xFFFF6B6B);
    final accent = const Color(0xFFEBCF23);

    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(context.sp(4)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(context.sp(4)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.sp(4)),
          border: Border.all(
            color: const Color(0xFFFFC107).withOpacity(0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(6.2),
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade900,
                      letterSpacing: 0.3,
                    ),
                  ),

                  SizedBox(height: context.h(0.006)),

                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: context.sp(4),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                      height: 1.25,
                    ),
                  ),


                ],
              ),
            ),

            SizedBox(width: context.w(0.02)),

            // Add button
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: context.sp(4),
                  vertical: context.sp(2.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.sp(3)),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: context.sp(4.8)),
                  SizedBox(width: context.sp(1.2)),
                  Text(
                    'Thêm',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(4.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(3),
        vertical: context.sp(1.4),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC107).withOpacity(0.15),
        borderRadius: BorderRadius.circular(context.sp(3)),
        border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.beVietnamPro(
          fontSize: context.sp(3.8),
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }
}
