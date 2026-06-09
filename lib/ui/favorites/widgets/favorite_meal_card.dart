import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/ui/meal_selection/selection_screen.dart';

class FavoriteMealCard extends StatelessWidget {
  final MealItem item;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FavoriteMealCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: context.h(0.008)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFFC107).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(context.w(0.05)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Info section
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tên món ăn
                    Text(
                      item.name,
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(5.5),
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF132439),
                        letterSpacing: 0.5,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.h(0.012)),
                    // Dinh dưỡng badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.w(0.035),
                        vertical: context.h(0.007),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFC107).withOpacity(0.25),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        item.description,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: context.sp(3.9),
                          color: const Color(0xFFE68F00),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.calories > 0) ...[
                      SizedBox(height: context.h(0.01)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.w(0.03),
                          vertical: context.h(0.005),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              size: context.sp(4.2),
                              color: const Color(0xFFFF6B6B),
                            ),
                            SizedBox(width: context.w(0.015)),
                            Text(
                              '${item.calories} kcal',
                              style: GoogleFonts.baloo2(
                                fontSize: context.sp(4),
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFFF6B6B),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: context.w(0.04)),
              // Right: Buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit button
                  if (onEdit != null)
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        width: context.sp(12),
                        height: context.sp(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4ECDC4),
                              const Color(0xFF44A3A0),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4ECDC4).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: context.sp(6),
                        ),
                      ),
                    ),
                  if (onEdit != null && onDelete != null) SizedBox(height: context.h(0.01)),
                  // Delete button
                  if (onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: context.sp(12),
                        height: context.sp(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFF6B6B),
                              const Color(0xFFEE5A6F),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B6B).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: context.sp(6),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
