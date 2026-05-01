import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

enum StreakType {
  water,
  meal,
}

class StreakPopup extends StatelessWidget {
  final StreakType type;

  const StreakPopup({
    super.key,
    required this.type,
  });

  String get _title {
    switch (type) {
      case StreakType.water:
        return 'Tuyệt vời!';
      case StreakType.meal:
        return 'Làm tốt lắm!';
    }
  }

  String get _message {
    switch (type) {
      case StreakType.water:
        return 'Bạn đã bắt đầu ngày mới bằng việc uống nước 💧';
      case StreakType.meal:
        return 'Bạn đã ghi nhận bữa ăn đầu tiên hôm nay 🍽️';
    }
  }

  Color get _color {
    switch (type) {
      case StreakType.water:
        return const Color(0xff61C8F5);
      case StreakType.meal:
        return const Color(0xffFF6F61);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: context.w(0.1)),
      child: Container(
        padding: EdgeInsets.all(context.w(0.06)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: context.sp(18),
              color: _color,
            ),
            SizedBox(height: context.h(0.02)),
            Text(
              _title,
              style: GoogleFonts.baloo2(
                fontSize: context.sp(8),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: context.h(0.01)),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(
                fontSize: context.sp(4.8),
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: context.h(0.03)),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(0.12),
                  vertical: context.h(0.015),
                ),
              ),
              child: Text(
                'Tiếp tục',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(4.8),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
