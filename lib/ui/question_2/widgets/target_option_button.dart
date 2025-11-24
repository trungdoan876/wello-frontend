import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class TargetOptionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onPressed;

  const TargetOptionButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const Color mainYellow = Color(0xFFEBCF23); // Màu cam
    const Color lightText = Color(0xFFA3A1A1);

    // Nền luôn trắng
    final Color backgroundColor = Colors.white;

    // Viền: màu cam khi chọn, trong suốt khi không chọn
    final Border border = Border.all(
      color: isSelected ? mainYellow : Colors.transparent,
      width: isSelected ? 2.5 : 1.0,
    );

    // Chữ to hơn và màu cam khi chọn
    final Color titleColor = isSelected ?mainYellow : Color(0xff646460) ;

    // Chữ phụ
    final Color subtitleColor = lightText;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: context.h(0.01)),
        padding: EdgeInsets.symmetric(
          horizontal: context.w(0.03),
          vertical: context.h(0.02),
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(context.sp(10)),
          border: border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(
                  fontSize: context.sp(6.0),
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            SizedBox(height: context.h(0.005)),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(
                fontSize: context.sp(4.5),
                fontWeight: FontWeight.bold,
                color: subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
