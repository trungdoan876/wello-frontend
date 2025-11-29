// lib/widgets/date_selector.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFFEBCF23);
    const Color inactiveColor = Color(0xFFB2B2AF);

    // Compute current week (Monday .. Sunday) based on today's date
    final DateTime today = DateTime.now();
    // start of week (Monday)
    final DateTime weekStart = today.subtract(
      Duration(days: today.weekday - 1),
    );

    // Labels for weekdays in Vietnamese (T2..T7, CN)
    const List<String> weekdayLabels = [
      'H',
      'B',
      'T',
      'N',
      'S',
      'B',
      'CN',
    ];

    final List<Widget> items = List.generate(7, (i) {
      final DateTime d = weekStart.add(Duration(days: i));
      final bool isActive =
          d.year == today.year && d.month == today.month && d.day == today.day;
      final Color color = isActive ? activeColor : inactiveColor;

      return Column(
        children: [
          Text(
            weekdayLabels[i],
            style: GoogleFonts.baloo2(
              fontSize: context.sp(5),
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          SizedBox(height: context.h(0.005)),
          Text(
            d.day.toString(),
            style: GoogleFonts.baloo2(
              fontSize: context.sp(5.0),
              fontWeight:FontWeight.w900,
              color: color,
            ),
          ),
        ],
      );
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items,
    );
  }
}
