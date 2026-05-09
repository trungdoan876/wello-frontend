import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import '../models/running_record.dart';

class RunningScheduleCard extends StatelessWidget {
  final RunningRecord record;
  final VoidCallback? onTap;

  const RunningScheduleCard({Key? key, required this.record, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(context.w(0.04)),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(context.w(0.04)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.w(0.04)),
            border: Border.all(color: Colors.grey[200]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: context.w(0.12),
                height: context.w(0.12),
                decoration: BoxDecoration(
                  color: const Color(0xffEBCF23).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(context.w(0.03)),
                ),
                child: Icon(
                  Icons.route,
                  color: const Color(0xffEBCF23),
                  size: context.sp(5.5),
                ),
              ),
              SizedBox(width: context.w(0.03)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buổi chạy gần nhất',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(5),
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: context.h(0.003)),
                    Text(
                      record.date,
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(3.5),
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: context.h(0.004)),
                    Text(
                      '${record.distance.toStringAsFixed(2)} km • ${record.duration} • ${record.pace.toStringAsFixed(1)} km/h',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(3.5),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                SizedBox(width: context.w(0.02)),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: context.sp(6),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
