import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/ui/home/widgets/date_selector.dart';
import 'package:wello_frontend/ui/home/widgets/calorie_summary.dart';
import 'package:wello_frontend/ui/home/widgets/water_tracker.dart';
import 'package:wello_frontend/ui/home/widgets/weight_chart.dart';
import 'package:wello_frontend/ui/home/widgets/activity_summary_card.dart';
import 'package:wello_frontend/ui/widgets/quick_actions_overlay.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<bool>? onQuickActionsChanged;

  const HomeScreen({super.key, this.onQuickActionsChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showQuickActions = false; // trạng thái mở panel

  void _setQuickActionsVisible(bool show) {
    setState(() => _showQuickActions = show);
    widget.onQuickActionsChanged?.call(show);
  }

  void _handleQuickAction(String key) {
    _setQuickActionsVisible(false);
    // TODO: điều hướng theo key
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = context.h(
      0.51,
    ); // chiều cao phần header bo tròn
    // Ẩn bottom navbar khi mở quick actions
    final double navHeight = _showQuickActions ? 0 : context.h(0.05);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Stack(
          children: [
            // Nội dung cuộn
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: headerHeight,
                    width: double.infinity,
                    child: _buildHeaderSection(context, headerHeight),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: context.w(0.05),
                      right: context.w(0.05),
                      top: context.h(0.02),
                      bottom: _showQuickActions
                          ? context.h(0.02)
                          : navHeight + context.h(0.02),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const WaterTracker(),
                        SizedBox(height: context.h(0.04)),
                        const WeightGoalCard(),
                        SizedBox(height: context.h(0.04)),
                        const ActivitySummaryCard(),
                        SizedBox(height: context.h(0.02)),
                      ],
                    ),
                  ),
                ],
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
              // Thu hẹp khoảng cách: khi mở panel sát mép hơn, khi có navbar giảm đệm
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

  Widget _buildHeaderSection(BuildContext context, double height) {
    const Color headerBg = Color(0xFFFFF7DA);

    return ClipPath(
      clipper: BottomCurveClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        color: headerBg,
        padding: EdgeInsets.only(
          top: context.h(0.02),
          left: context.w(0.05),
          right: context.w(0.05),
          bottom: context.h(0.04),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Home',
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(
                fontSize: context.sp(10.0),
                fontWeight: FontWeight.bold,
                color: Color(0xffEBCF23),
              ),
            ),
            SizedBox(height: context.h(0.02)),
            const DateSelector(),
            SizedBox(height: context.h(0.02)),
            const CalorieSummary(),
          ],
        ),
      ),
    );
  }
}

// Các widget QuickActions đã được tách ra file riêng quick_actions_overlay.dart

// kết thúc file

class BottomCurveClipper extends CustomClipper<Path> {
  //vẽ cái vòng tròn ở trên
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 40,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
