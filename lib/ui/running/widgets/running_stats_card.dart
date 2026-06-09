import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class RunningStatsCard extends StatelessWidget {
  final double distance; // km
  final int calories; // kcal
  final Duration duration;
  final double pace; // km/h

  const RunningStatsCard({
    Key? key,
    this.distance = 0.0,
    this.calories = 0,
    this.duration = const Duration(),
    this.pace = 0.0,
  }) : super(key: key);

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDistance(double val) {
    if (val <= 0) return '0.0';
    if (val < 10.0) {
      return val.toStringAsFixed(2); // e.g., 9.87
    } else if (val < 100.0) {
      return val.toStringAsFixed(1); // e.g., 98.8
    } else {
      return val.round().toString(); // e.g., 988
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(0.045),
        vertical: context.h(0.024),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(context.w(0.05)),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Thống kê chạy',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(6.1),
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: context.h(0.018)),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: context.w(0.025),
            mainAxisSpacing: context.h(0.01),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.9,
            children: [
              _buildStatItemNew(
                context,
                icon: Icons.straighten,
                label: 'Quãng đường',
                value: '${_formatDistance(distance)} km',
              ),
              _buildStatItemNew(
                context,
                icon: Icons.local_fire_department,
                label: 'Calo',
                value: '$calories kcal',
              ),
              _buildStatItemNew(
                context,
                icon: Icons.timer,
                label: 'Thời gian',
                value: _formatDuration(duration),
              ),
              _buildStatItemNew(
                context,
                icon: Icons.speed,
                label: 'Tốc độ',
                value: '${pace.toStringAsFixed(1)} km/h',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItemNew(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(0.02),
        vertical: context.h(0.01),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xffEBCF23).withOpacity(0.08),
            const Color(0xffEBCF23).withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(context.w(0.035)),
        border: Border.all(
          color: const Color(0xffEBCF23).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(context.w(0.02)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xffEBCF23).withOpacity(0.15),
            ),
            child: Icon(
              icon,
              size: context.sp(6.2),
              color: const Color(0xffEBCF23),
            ),
          ),
          SizedBox(height: context.h(0.006)),
          Text(
            label,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(3.2),
              color: Colors.grey[800],
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.h(0.004)),
          Text(
            value,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(5.0),
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
