import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/domain/entities/running_session.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class StepsChartCard extends StatelessWidget {
  final List<RunningDailySummary> dailySummaries;

  static const Color _accent = Color(0xFFEBCF23);
  static const Color _surface = Color(0xFFFFFBEB);

  const StepsChartCard({Key? key, required this.dailySummaries})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final visibleSummaries = dailySummaries.toList()
      ..sort((a, b) {
        final aDate =
            DateTime.tryParse(a.date) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            DateTime.tryParse(b.date) ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
      });
    final recentSummaries = visibleSummaries.length > 7
        ? visibleSummaries.sublist(visibleSummaries.length - 7)
        : visibleSummaries;
    final values = recentSummaries.map((summary) => summary.steps).toList();
    final maxSteps = values.isEmpty
        ? 1.0
        : values.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: EdgeInsets.all(context.w(0.05)),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(context.w(0.05)),
        border: Border.all(color: _accent.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bước chân thực tế',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(6),
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: context.h(0.02)),
          if (recentSummaries.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.h(0.03)),
              child: Text(
                'Chưa có dữ liệu bước chân từ backend',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(4),
                  color: Colors.grey[700],
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < recentSummaries.length; i++)
                  Column(
                    children: [
                      Container(
                        width: context.w(0.08),
                        height: values[i] <= 0
                            ? context.w(0.02)
                            : (values[i] / maxSteps * context.h(0.12)).clamp(
                                context.w(0.02),
                                context.h(0.12),
                              ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [_accent, _accent.withValues(alpha: 0.78)],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(context.w(0.02)),
                            topRight: Radius.circular(context.w(0.02)),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _accent.withValues(alpha: 0.18),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.h(0.01)),
                      Text(
                        DateFormat('dd/MM').format(
                          DateTime.tryParse(recentSummaries[i].date) ??
                              DateTime.now(),
                        ),
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(3),
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: context.h(0.002)),
                      Text(
                        '${values[i]}',
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(2.8),
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          if (recentSummaries.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: context.h(0.015)),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(0.03),
                  vertical: context.h(0.008),
                ),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(context.w(0.02)),
                ),
                child: Text(
                  '${values.last} bước gần nhất',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4.5),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF9A7D00),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
