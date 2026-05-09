import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import '../models/running_record.dart';

class RunningHistoryCard extends StatelessWidget {
  final List<RunningRecord> records;

  const RunningHistoryCard({Key? key, this.records = const []})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(0.05),
        vertical: context.h(0.03),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(context.w(0.025)),
                decoration: BoxDecoration(
                  color: const Color(0xffEBCF23).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history,
                  size: context.sp(5.5),
                  color: const Color(0xffEBCF23),
                ),
              ),
              SizedBox(width: context.w(0.03)),
              Text(
                'Lịch sử chạy gần đây',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(6.5),
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(0.02)),
          if (records.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: context.h(0.03)),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(context.w(0.03)),
              ),
              child: Center(
                child: Text(
                  'Chưa có lịch sử chạy',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4),
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < records.length && i < 5; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: context.h(0.012)),
                    child: _buildHistoryItem(context, records[i]),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, RunningRecord record) {
    return Container(
      padding: EdgeInsets.all(context.w(0.035)),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(context.w(0.03)),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(0.12),
            height: context.w(0.12),
            decoration: BoxDecoration(
              color: const Color(0xffEBCF23).withOpacity(0.15),
              borderRadius: BorderRadius.circular(context.w(0.03)),
            ),
            child: Icon(
              Icons.directions_run,
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
                  record.date,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4.5),
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: context.h(0.004)),
                Text(
                  '${record.distance.toStringAsFixed(2)} km  •  ${record.duration}',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(3.5),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(0.03),
              vertical: context.h(0.01),
            ),
            decoration: BoxDecoration(
              color: const Color(0xffEBCF23).withOpacity(0.12),
              borderRadius: BorderRadius.circular(context.w(0.03)),
            ),
            child: Text(
              '${record.pace.toStringAsFixed(1)}',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(5),
                fontWeight: FontWeight.w900,
                color: const Color(0xffD6A400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
