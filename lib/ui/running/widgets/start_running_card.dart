import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class StartRunningCard extends StatelessWidget {
  final VoidCallback onStartPressed;
  final bool isRunning;

  const StartRunningCard({
    Key? key,
    required this.onStartPressed,
    this.isRunning = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(0.05),
        vertical: context.h(0.04),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xffEBCF23).withOpacity(0.15),
            Color(0xffEBCF23).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(context.w(0.05)),
        border: Border.all(
          color: const Color(0xffEBCF23).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(context.w(0.05)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xffEBCF23).withOpacity(0.2),
            ),
            child: Icon(
              Icons.directions_run,
              size: context.sp(13),
              color: const Color(0xffEBCF23),
            ),
          ),
          SizedBox(height: context.h(0.025)),
          Text(
            'Sẵn sàng chạy?',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(7.5),
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: context.h(0.012)),
          Text(
            'Bắt đầu phiên chạy mới của bạn',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(4),
              color: Colors.grey[700],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.h(0.035)),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.w(0.04)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xffEBCF23).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isRunning ? null : onStartPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffEBCF23),
                disabledBackgroundColor: Colors.grey[300],
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(0.15),
                  vertical: context.h(0.018),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.w(0.04)),
                ),
                elevation: 0,
              ),
              child: Text(
                isRunning ? 'Đang chạy' : 'Bắt đầu chạy',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(5.5),
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
