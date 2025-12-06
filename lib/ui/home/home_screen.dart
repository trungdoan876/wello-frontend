import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/ui/home/widgets/date_selector.dart';
import 'package:wello_frontend/ui/home/widgets/calorie_summary.dart';
import 'package:wello_frontend/ui/home/widgets/water_tracker.dart';
import 'package:wello_frontend/ui/home/widgets/weight_chart.dart';
import 'package:wello_frontend/ui/home/widgets/activity_summary_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double headerHeight = context.h(0.51); //chiều cao của cái bo tròn
    final double navHeight = context.h(0.12);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      bottomNavigationBar: SizedBox(
        height: navHeight,
        child: const CustomBottomNavigationBar(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header is part of the scrollable content and will scroll away
              SizedBox(
                height: headerHeight,
                width: double.infinity,
                child: _buildHeaderSection(context, headerHeight),
              ),

              // Main content with side padding
              Padding(
                padding: EdgeInsets.only(
                  left: context.w(0.05),
                  right: context.w(0.05),
                  top: context.h(0.02),
                  bottom: navHeight + context.h(0.02),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    const Color mainYellow = Color(0xFFFFC107);

    return Container(
      height: context.h(0.12),
      decoration: BoxDecoration(
        color: mainYellow,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.sp(5.0)),
          topRight: Radius.circular(context.sp(5.0)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home, 'Home', true),
          _buildNavItem(context, Icons.favorite_border, 'Mục yêu thích', false),
          _buildNavItem(context, Icons.person_outline, 'Cá nhân', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
  ) {
    const Color activeIconColor = Colors.white;
    const Color inactiveIconColor = Colors.white70;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? activeIconColor : inactiveIconColor,
          size: context.sp(6.0),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: context.sp(3.0),
            color: isActive ? activeIconColor : inactiveIconColor,
          ),
        ),
      ],
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
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
