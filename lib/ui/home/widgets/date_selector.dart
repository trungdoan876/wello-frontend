// lib/widgets/date_selector.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/domain/providers/nutrition_provider.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';

class DateSelector extends StatefulWidget {
  const DateSelector({super.key});

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  int _weekOffset = 0; // 0 = current week, -1 = previous week, +1 = next week

  @override
  void initState() {
    super.initState();
    // Automatically select today's date when widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<NutritionProvider>();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Only set if not already set or different
      if (provider.selectedDate != today) {
        final credentials = await AuthHelper.getCredentials();
        if (credentials != null) {
          await provider.changeDate(
            credentials.token,
            credentials.userIdString,
            today,
          );
        }
      }
      
      // Add listener to update week offset when selected date changes
      provider.addListener(_onDateChanged);
    });
  }

  @override
  void dispose() {
    // Remove listener when widget is disposed
    context.read<NutritionProvider>().removeListener(_onDateChanged);
    super.dispose();
  }

  void _onDateChanged() {
    // Update week offset when selected date changes
    _updateWeekOffsetForDate();
  }

  void _updateWeekOffsetForDate() {
    final provider = context.read<NutritionProvider>();
    final selectedDateStr = provider.selectedDate;
    
    if (selectedDateStr.isNotEmpty) {
      final selectedDate = DateTime.parse(selectedDateStr);
      final today = DateTime.now();
      
      // Calculate which week the selected date is in
      final selectedWeekStart = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
      final currentWeekStart = today.subtract(Duration(days: today.weekday - 1));
      
      final weekDiff = selectedWeekStart.difference(currentWeekStart).inDays ~/ 7;
      
      if (weekDiff != _weekOffset) {
        setState(() {
          _weekOffset = weekDiff;
        });
      }
    }
  }

  Future<void> _selectDateInWeek() async {
    final credentials = await AuthHelper.getCredentials();
    if (credentials == null) return;
    
    final provider = context.read<NutritionProvider>();
    final today = DateTime.now();
    final offsetDate = today.add(Duration(days: _weekOffset * 7));
    final weekStart = offsetDate.subtract(Duration(days: offsetDate.weekday - 1));
    
    // Try to select same weekday, or Monday if current day doesn't exist yet
    final currentSelectedDate = DateTime.tryParse(provider.selectedDate);
    final targetWeekday = currentSelectedDate?.weekday ?? 1; // Default to Monday
    
    final targetDate = weekStart.add(Duration(days: targetWeekday - 1));
    
    // Don't select future dates
    if (targetDate.isAfter(DateTime.now())) {
      // Select today instead
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await provider.changeDate(
        credentials.token,
        credentials.userIdString,
        todayStr,
      );
    } else {
      final dateStr = DateFormat('yyyy-MM-dd').format(targetDate);
      await provider.changeDate(
        credentials.token,
        credentials.userIdString,
        dateStr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFFEBCF23);
    const Color inactiveColor = Color(0xFFB2B2AF);

    // Current week + offset
    final DateTime today = DateTime.now();
    final DateTime offsetDate = today.add(Duration(days: _weekOffset * 7));
    final DateTime weekStart = offsetDate.subtract(Duration(days: offsetDate.weekday - 1));

    // Weekday labels
    const List<String> weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Consumer<NutritionProvider>(
      builder: (context, provider, child) {
        final selectedDate = provider.selectedDate;
        
        return Row(
          children: [
            // Previous week button
            IconButton(
              icon: Icon(Icons.chevron_left, color: activeColor, size: context.sp(5)),
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(),
              onPressed: () async {
                setState(() {
                  _weekOffset--;
                });
                
                // Auto-select same weekday in the previous week
                await _selectDateInWeek();
              },
            ),
            
            // Week days
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (i) {
                  final DateTime d = weekStart.add(Duration(days: i));
                  final String dateStr = DateFormat('yyyy-MM-dd').format(d);
                  final bool isActive = dateStr == selectedDate;
                  final Color color = isActive ? activeColor : inactiveColor;

                  return GestureDetector(
                    onTap: () async {
                      print('📅 Date tapped: $dateStr');
                      
                      final credentials = await AuthHelper.getCredentials();
                      if (credentials != null) {
                        await provider.changeDate(
                          credentials.token,
                          credentials.userIdString,
                          dateStr,
                        );
                      }
                    },
                    child: Column(
                      children: [
                        Text(
                          weekdayLabels[i],
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(4.5),
                            fontWeight: FontWeight.w900,
                            color: color,
                          ),
                        ),
                        SizedBox(height: context.h(0.005)),
                        Text(
                          d.day.toString(),
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(5.0),
                            fontWeight: FontWeight.w900,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            
            // Next week button (only show when viewing past weeks)
            _weekOffset < 0
                ? IconButton(
                    icon: Icon(Icons.chevron_right, color: activeColor, size: context.sp(5)),
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                    onPressed: () async {
                      setState(() {
                        _weekOffset++;
                      });
                      
                      // Auto-select same weekday in the next week
                      await _selectDateInWeek();
                    },
                  )
                : SizedBox(width: context.sp(5) + 16), // Same width as IconButton for alignment
          ],
        );
      },
    );
  }
}
