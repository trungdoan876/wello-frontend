import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/domain/providers/streak_provider.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  late DateTime _currentMonth;

  static const Color primaryOrange = Color(0xFFFF9800);
  static const Color lightOrange = Color(0xFFFFF3E0);
  static const Color waterBlue = Color(0xFF42A5F5);
  static const Color mealRed = Color(0xFFEF5350);

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStreak();
    });
  }

  Future<void> _loadStreak() async {
    final credentials = await AuthHelper.getCredentials();
    if (credentials == null) return;

    await context.read<StreakProvider>().loadMonthlyStreak(
          token: credentials.token,
          userId: credentials.userId,
          year: _currentMonth.year,
          month: _currentMonth.month,
        );
  }

  // ================= LOGIC =================

  int _calculateCurrentStreak(Map<DateTime, dynamic> streaks) {
    int count = 0;
    DateTime day = DateTime.now();

    while (true) {
      final key = DateTime(day.year, day.month, day.day);
      final streak = streaks[key];

      if (streak == null || (!streak.water && !streak.meal)) break;

      count++;
      day = day.subtract(const Duration(days: 1));
    }

    return count;
  }

  Color _dayColor(bool water, bool meal) {
    if (water && meal) return primaryOrange;
    if (water) return waterBlue;
    if (meal) return mealRed;
    return Colors.grey.shade200;
  }

  // ================= UI =================

  Widget _streakSummary(int streakCount) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(0.05),
        vertical: context.h(0.015),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(0.06),
          vertical: context.h(0.025),
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [lightOrange, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: primaryOrange.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streakCount 🔥',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(11),
                    fontWeight: FontWeight.bold,
                    color: primaryOrange,
                  ),
                ),
                Text(
                  'Ngày duy trì',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(3.8),
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: primaryOrange,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'GOOD',
                style: GoogleFonts.baloo2(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: context.sp(3.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(3.2),
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat.yMMMM().format(_currentMonth);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: Text(
          'Streak',
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Consumer<StreakProvider>(
        builder: (context, provider, _) {
          final streaks = provider.streaks;
          final streakCount = _calculateCurrentStreak(streaks);

          final daysInMonth = DateUtils.getDaysInMonth(
            _currentMonth.year,
            _currentMonth.month,
          );

          final firstWeekday =
              DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7;

          return Column(
            children: [
              _streakSummary(streakCount),

              // ===== MONTH HEADER =====
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(0.06),
                  vertical: context.h(0.01),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      monthLabel,
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(
                                _currentMonth.year,
                                _currentMonth.month - 1,
                              );
                            });
                            _loadStreak();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(
                                _currentMonth.year,
                                _currentMonth.month + 1,
                              );
                            });
                            _loadStreak();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ===== CALENDAR =====
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(0.05)),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: daysInMonth + firstWeekday,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    if (index < firstWeekday) return const SizedBox();

                    final day = index - firstWeekday + 1;
                    final dateKey = DateTime(
                      _currentMonth.year,
                      _currentMonth.month,
                      day,
                    );

                    final streak = streaks[dateKey];
                    final color = streak == null
                        ? Colors.grey.shade200
                        : _dayColor(streak.water, streak.meal);

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        boxShadow: streak == null
                            ? []
                            : [
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: GoogleFonts.baloo2(
                            fontWeight: FontWeight.bold,
                            color:
                                streak == null ? Colors.grey : Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Spacer(),

              // ===== LEGEND =====
              Padding(
                padding: EdgeInsets.all(context.w(0.05)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _legendItem(waterBlue, 'Uống nước'),
                    _legendItem(mealRed, 'Ăn uống'),
                    _legendItem(primaryOrange, 'Cả hai'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
