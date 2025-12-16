import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'widgets/water_tracking_card.dart';
import 'package:wello_frontend/ui/summary/widgets/bmi_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int goal = 1950;
  int current = 500; // ml đã uống
  bool notif = false;
  String lastTime = "16:30";

  void _increase() {
    setState(() {
      current = (current + 200).clamp(0, goal);
    });
  }

  void _decrease() {
    setState(() {
      current = (current - 200).clamp(0, goal);
    });
  }

  void _toggleNotif() {
    setState(() => notif = !notif);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7DA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(0.04),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: context.h(0.02)),

                Text(
                  'Profile',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(9),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFAA00),
                  ),
                ),

                SizedBox(height: context.h(0.03)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Chỉ số cơ thể',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(7),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4C494C),
                    ),
                  ),
                ),

                SizedBox(height: context.h(0.015)),
                const BMICard(),

                SizedBox(height: context.h(0.03)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bạn nên uống bao nhiêu nước',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(6),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4C494C),
                    ),
                  ),
                ),

                SizedBox(height: context.h(0.015)),

                WaterTrackingCard(
                  amount: current,
                  goal: goal,
                  lastTime: lastTime,
                  isNotificationOn: notif,
                  onIncrease: _increase,
                  onDecrease: _decrease,
                  onToggleNotification: _toggleNotif,
                ),
                SizedBox(height: context.h(0.05)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
