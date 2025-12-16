import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/ui/widgets/quick_actions_overlay.dart';
import 'widgets/water_tracking_card.dart';
import 'package:wello_frontend/ui/summary/widgets/bmi_card.dart';

class ProfileScreen extends StatefulWidget {
  final Function(bool)? onQuickActionsChanged;

  const ProfileScreen({super.key, this.onQuickActionsChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int goal = 1950;
  int current = 500; // ml đã uống
  bool notif = false;
  String lastTime = "16:30";
  bool _showQuickActions = false;

  void _setQuickActionsVisible(bool show) {
    setState(() => _showQuickActions = show);
    widget.onQuickActionsChanged?.call(show);
  }

  void _handleQuickAction(String key) {
    _setQuickActionsVisible(false);
    // TODO: điều hướng theo key
  }

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
    final double navHeight = _showQuickActions ? 0 : context.h(0.05);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7DA),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(0.04)),
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
                    SizedBox(height: navHeight + context.h(0.05)),
                  ],
                ),
              ),
            ),
            // Lớp phủ mờ khi mở quick actions
            if (_showQuickActions)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _setQuickActionsVisible(false),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: 0.45,
                    child: Container(color: Colors.black),
                  ),
                ),
              ),
            // Panel quick actions + nút dấu cộng
            Positioned(
              right: context.w(0.05),
              bottom: _showQuickActions
                  ? context.h(0.015)
                  : navHeight + context.h(0.01),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedSlide(
                    offset: _showQuickActions
                        ? const Offset(0, 0)
                        : const Offset(0, 0.2),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _showQuickActions ? 1 : 0,
                      child: QuickActionsPanel(onAction: _handleQuickAction),
                    ),
                  ),
                  SizedBox(height: context.h(0.012)),
                  PlusBubble(
                    onTap: () => _setQuickActionsVisible(!_showQuickActions),
                    open: _showQuickActions,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
