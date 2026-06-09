import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class QuickStatsRow extends StatelessWidget {
  final int calories;
  final double distance;

  const QuickStatsRow({
    Key? key,
    required this.calories,
    required this.distance,
  }) : super(key: key);

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
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(context.w(0.04)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.w(0.04)),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: context.sp(5),
                      color: Colors.red[400],
                    ),
                    SizedBox(width: context.w(0.02)),
                    Expanded(
                      child: Text(
                        'Tổng calo',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(3.5),
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.h(0.008)),
                Text(
                  '$calories kcal',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(6.5),
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: context.w(0.03)),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(context.w(0.04)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.w(0.04)),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.straighten,
                      size: context.sp(5),
                      color: const Color(0xffEBCF23),
                    ),
                    SizedBox(width: context.w(0.02)),
                    Expanded(
                      child: Text(
                        'Tổng quãng đường',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(3.5),
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.h(0.008)),
                Text(
                  '${_formatDistance(distance)} km',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(6.5),
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
