import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class CenteredBottomNavItem {
  final IconData icon;
  final String label;
  const CenteredBottomNavItem({required this.icon, required this.label});
}

class CenteredBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CenteredBottomNavItem>? items;
  // Customization
  final double iconSize;
  final double selectedIconSize;
  final double iconOffsetY; // positive pushes icon down (for non-selected)
  final double selectedIconOffsetY; // extra downward offset for selected icon
  final EdgeInsets iconPadding; // padding around icon (both states)
  final TextStyle? labelTextStyle;
  final double? barHeight; // CurvedNavigationBar height
  final double itemTopPadding; // add extra top space inside each item

  const CenteredBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items,
    this.iconSize = 24.0,
    this.selectedIconSize = 34.0,
    this.iconOffsetY = 2.0,
    this.selectedIconOffsetY = 6.0,
    this.iconPadding = const EdgeInsets.all(6.0),
    this.labelTextStyle,
    this.barHeight,
    this.itemTopPadding = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFFFC107);
    final data =
        items ??
        const [
          CenteredBottomNavItem(icon: Icons.home, label: 'Nhật ký'),
          CenteredBottomNavItem(icon: Icons.favorite, label: 'Mục yêu thích'),
          CenteredBottomNavItem(icon: Icons.person, label: 'Cá nhân'),
        ];

    return CurvedNavigationBar(
      index: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.transparent,
      color: bgColor,
      height: barHeight ?? 75.0, // Max allowed by curved_navigation_bar
      animationDuration: const Duration(milliseconds: 300),
      items: [
        for (int i = 0; i < data.length; i++)
          Padding(
            padding: EdgeInsets.only(top: itemTopPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  // push selected icon further down so it appears closer to bottom
                  offset: Offset(
                    0,
                    i == currentIndex ? selectedIconOffsetY : iconOffsetY,
                  ),
                  child: i == currentIndex
                      ? Padding(
                          padding: iconPadding,
                          child: Icon(
                            data[i].icon,
                            color: Colors.white,
                            size: selectedIconSize,
                          ),
                        )
                      : Icon(data[i].icon, color: Colors.white, size: iconSize),
                ),
                if (i != currentIndex) ...[
                  SizedBox(height: context.h(0.005)),
                  Text(
                    data[i].label,
                    style:
                        (labelTextStyle ??
                        GoogleFonts.baloo2(
                          color: Colors.white,
                          fontSize: context.sp(3.5),
                          fontWeight: FontWeight.w900,
                        )),
                  ),
                ] else ...[
                  // Reserve the same vertical space as label to keep alignment
                  SizedBox(height: context.h(0.003)),
                  SizedBox(height: context.sp(3.4)),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

// Using CurvedNavigationBar for the bottom bar items.
