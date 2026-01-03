import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/domain/providers/sleep_provider.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/data/models/responses/sleep_today_response.dart';

enum SleepStatus {
  notLogged,    // Chưa ghi nhận gì
  sleeping,     // Đã nhập giờ ngủ, chưa nhập giờ dậy
  completed,    // Đã hoàn thành cả 2
}

class DailySleepCard extends StatelessWidget {
  final SleepStatus status;
  final SleepLogData? completedRecord;
  final SleepLogData? activeRecord;
  final DateTime? dashboardDate;
  final double targetHours;
  final VoidCallback? onLogBedtime;
  final VoidCallback? onLogWaketime;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DailySleepCard({
    super.key,
    this.status = SleepStatus.notLogged,
    this.completedRecord,
    this.activeRecord,
    this.dashboardDate,
    this.targetHours = 8.0,
    this.onLogBedtime,
    this.onLogWaketime,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(0.05)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.w(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.sp(2)),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(context.sp(2.5)),
                ),
                child: Icon(
                  Icons.bedtime,
                  size: context.sp(5),
                  color: const Color(0xFF6C63FF),
                ),
              ),
              SizedBox(width: context.w(0.03)),
              Expanded(
                child: Text(
                  'Giấc ngủ hôm nay',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(5.5),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4C494C),
                  ),
                ),
              ),
              // Debug: Date picker
              IconButton(
                icon: Icon(Icons.calendar_today, size: context.sp(5)),
                color: Colors.grey.shade600,
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    // Set test date in provider
                    final provider = context.read<SleepProvider>();
                    provider.setTestDate(picked);
                    // Reload sleep data for selected date
                    final credentials = await AuthHelper.getCredentials();
                    if (credentials != null) {
                      await provider.loadTodaySleep(credentials.userId);
                    }
                  }
                },
              ),
            ],
          ),
          SizedBox(height: context.h(0.02)),

          // Content based on dual state
          Column(
            children: [
              // 1. If we have a completed sleep for today, show its results
              if (completedRecord != null) ...[
                _buildCompletedSummary(context),
                SizedBox(height: context.h(0.02)),
              ],

              // 2. Logging / Active section (Tonight -> Tomorrow morning)
              if (status == SleepStatus.notLogged)
                _buildNotLoggedSection(context)
              else if (status == SleepStatus.sleeping)
                _buildSleepingSection(context)
              else if (activeRecord?.status?.toUpperCase() == 'COMPLETED')
                 _buildActiveCompletedSummary(context),
            ],
          ),
        ],
      ),
    );
  }

  // Section 1: Not Logged (The big button flow)
  Widget _buildNotLoggedSection(BuildContext context) {
    final String tomorrowLabel = dashboardDate != null 
        ? DateFormat('dd/MM').format(dashboardDate!.add(const Duration(days: 1))) 
        : '';
    return Column(
      children: [
        _buildSectionHeader(context, 'Đêm nay -> Sáng mai'),
        SizedBox(height: context.h(0.015)),
        Center(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9C93FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(context.w(0.08)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: onLogBedtime,
              icon: Icon(Icons.bedtime_outlined, size: context.sp(5)),
              label: Text(
                'Bắt đầu giấc ngủ đêm nay',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(4.2),
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(0.08),
                  vertical: context.h(0.018),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.w(0.08)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Section 2: Active Sleeping
  Widget _buildSleepingSection(BuildContext context) {
    final String tomorrowLabel = dashboardDate != null 
        ? DateFormat('dd/MM').format(dashboardDate!.add(const Duration(days: 1))) 
        : '';
    return Column(
      children: [
        _buildSectionHeader(context, 'Đêm nay -> Sáng mai ($tomorrowLabel)'),
        SizedBox(height: context.h(0.015)),
        // Status indicator with pulse effect (conceptual)
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(0.04),
            vertical: context.h(0.01),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6C63FF).withOpacity(0.15),
                const Color(0xFF9C93FF).withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(context.w(0.06)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF6C63FF),
                ),
              ),
              SizedBox(width: context.w(0.02)),
              Text(
                'Đang ngủ...',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(4),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6C63FF),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.h(0.025)),

        // Unified 2-column layout for consistency
        Container(
          padding: EdgeInsets.all(context.w(0.04)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6C63FF).withOpacity(0.08),
                const Color(0xFF9C93FF).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(context.w(0.03)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTimeInfoModern(
                  context,
                  Icons.nightlight_round,
                  'Đi ngủ',
                  _formatTime(activeRecord?.sleepTime) ?? '--:--',
                  date: _formatDate(activeRecord?.sleepTime),
                ),
              ),
              Container(
                width: 1,
                height: context.h(0.05),
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: _buildTimeInfoModern(
                  context,
                  Icons.wb_sunny_rounded,
                  'Thức dậy',
                  '--:--',
                  date: activeRecord != null 
                    ? DateFormat('dd/MM/yyyy').format(
                        DateTime.parse(activeRecord!.sleepTime).add(const Duration(days: 1))
                      )
                    : 'Đang ghi nhận...',
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.h(0.025)),

        // Wake up button (Premium style)
        GestureDetector(
          onTap: onLogWaketime,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: context.h(0.015)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF8E84FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(context.w(0.03)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wb_sunny_rounded,
                  size: context.sp(5),
                  color: Colors.white,
                ),
                SizedBox(width: context.w(0.02)),
                Text(
                  'Tôi đã thức dậy',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4.2),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Summary: Completed Sleep Results
  Widget _buildCompletedSummary(BuildContext context) {
    final bool isPending = completedRecord?.status?.toUpperCase() == 'PENDING';
    final String dateLabel = dashboardDate != null ? DateFormat('dd/MM').format(dashboardDate!) : '';

    return Column(
      children: [
        _buildSectionHeader(context, 'Kết quả sáng nay ($dateLabel)'),
        SizedBox(height: context.h(0.015)),
        if (isPending) ...[
          _buildActiveWakeupSection(context),
        ] else ...[
          _buildCompletedStatsRow(context),
        ],
      ],
    );
  }

  Widget _buildActiveWakeupSection(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(0.04),
            vertical: context.h(0.01),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(context.w(0.06)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.alarm_on, size: 16, color: Color(0xFF6C63FF)),
              SizedBox(width: context.w(0.02)),
              Text(
                'Đang trong giấc ngủ...',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(3.8),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6C63FF),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.h(0.015)),
        _buildTimeInfoContainer(context, completedRecord),
        SizedBox(height: context.h(0.015)),
        _buildActionButton(
          context,
          onLogWaketime,
          'Tôi đã thức dậy',
          Icons.wb_sunny_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF8E84FF)],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedStatsRow(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Left: Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        completedRecord?.durationHours?.toStringAsFixed(1) ?? '0.0',
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(9),
                          fontWeight: FontWeight.w900,
                          color: _getSleepStatusColor(completedRecord?.durationHours ?? 0),
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: context.h(0.005)),
                        child: Text(
                          ' / ${targetHours.toStringAsFixed(1)}',
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(5),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: context.h(0.005),
                          left: context.w(0.01),
                        ),
                        child: Text(
                          'giờ',
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(4.2),
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(0.005)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(0.025),
                      vertical: context.h(0.005),
                    ),
                    decoration: BoxDecoration(
                      color: _getSleepStatusColor(completedRecord?.durationHours ?? 0).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(context.w(0.015)),
                    ),
                    child: Text(
                      _getDeviationText(completedRecord?.durationHours ?? 0),
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(3.5),
                        fontWeight: FontWeight.w700,
                        color: _getSleepStatusColor(completedRecord?.durationHours ?? 0),
                      ),
                    ),
                  ),
                  if (completedRecord?.quality != null) ...[
                    SizedBox(height: context.h(0.01)),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < (completedRecord?.quality ?? 0)
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: context.sp(4.5),
                          color: index < (completedRecord?.quality ?? 0)
                              ? const Color(0xFFFFC107)
                              : Colors.grey.shade300,
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
            // Right: Progress Ring
            SizedBox(
              width: context.sp(18),
              height: context.sp(18),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: context.sp(18),
                    height: context.sp(18),
                    child: CircularProgressIndicator(
                      value: (completedRecord?.durationHours ?? 0) > 0 && targetHours > 0
                          ? ((completedRecord?.durationHours ?? 0) / targetHours).clamp(0.0, 1.0)
                          : 0.0,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          AlwaysStoppedAnimation(_getSleepStatusColor(completedRecord?.durationHours ?? 0)),
                    ),
                  ),
                  Icon(
                    Icons.bedtime_rounded,
                    size: context.sp(7),
                    color: _getSleepStatusColor(completedRecord?.durationHours ?? 0),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: context.h(0.025)),
        // Sleep times with gradient background
        Container(
          padding: EdgeInsets.all(context.w(0.04)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6C63FF).withOpacity(0.08),
                const Color(0xFF9C93FF).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(context.w(0.03)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTimeInfoModern(
                  context,
                  Icons.nightlight_round,
                  'Đi ngủ',
                  _formatTime(completedRecord?.sleepTime) ?? '--:--',
                  date: _formatDate(completedRecord?.sleepTime),
                ),
              ),
              Container(
                width: 1,
                height: context.h(0.05),
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: _buildTimeInfoModern(
                  context,
                  Icons.wb_sunny_rounded,
                  'Thức dậy',
                  _formatTime(completedRecord?.wakeTime) ?? '--:--',
                  date: _formatDate(completedRecord?.wakeTime),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.h(0.02)),
        // Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: Icon(Icons.edit_outlined, size: context.sp(4.5)),
                label: Text(
                  'Chỉnh sửa',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6C63FF),
                  side: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
                  padding: EdgeInsets.symmetric(vertical: context.h(0.015)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.w(0.025)),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.h(0.02)),
      ],
    );
  }

  Widget _buildDoneForTodaySection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.w(0.03)),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.w(0.03)),
        border: Border.all(color: Colors.green.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green, size: context.sp(5)),
          SizedBox(width: context.w(0.02)),
          Text(
            'Bạn đã hoàn thành mục tiêu hôm nay!',
            style: GoogleFonts.baloo2(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w600,
              fontSize: context.sp(3.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCompletedSummary(BuildContext context) {
    final String tomorrowLabel = dashboardDate != null 
        ? DateFormat('dd/MM').format(dashboardDate!.add(const Duration(days: 1))) 
        : '';
    return Column(
      children: [
        _buildSectionHeader(context, 'Đêm nay -> Sáng mai ($tomorrowLabel)'),
        SizedBox(height: context.h(0.015)),
        _buildTimeInfoContainer(context, activeRecord),
        SizedBox(height: context.h(0.01)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.w(0.03)),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.05),
            borderRadius: BorderRadius.circular(context.w(0.03)),
            border: Border.all(color: Colors.green.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: context.sp(5)),
              SizedBox(width: context.w(0.02)),
              Text(
                'Giấc ngủ này đã hoàn thành!',
                style: GoogleFonts.baloo2(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: context.sp(3.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: context.w(0.03)),
        Text(
          title,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(4),
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfoModern(
    BuildContext context,
    IconData icon,
    String label,
    String time, {
    String? date,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: context.sp(6),
          color: const Color(0xFF6C63FF),
        ),
        SizedBox(height: context.h(0.008)),
        Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(3.5),
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          time,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(5.5),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF4C494C),
          ),
        ),
        if (date != null)
          Text(
            date,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(2.8),
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
      ],
    );
  }

  Widget _buildTimeInfoContainer(BuildContext context, SleepLogData? record) {
    return Container(
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.08),
            const Color(0xFF9C93FF).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.w(0.03)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTimeInfoModern(
              context,
              Icons.nightlight_round,
              'Đi ngủ',
              _formatTime(record?.sleepTime) ?? '--:--',
              date: _formatDate(record?.sleepTime),
            ),
          ),
          Container(
            width: 1,
            height: context.h(0.05),
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: _buildTimeInfoModern(
              context,
              Icons.wb_sunny_rounded,
              'Thức dậy',
              _formatTime(record?.wakeTime) ?? '--:--',
              date: _formatDate(record?.wakeTime),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    VoidCallback? onTap,
    String label,
    IconData icon, {
    Gradient? gradient,
  }) {
    print('[DEBUG] _buildActionButton: label=$label, onTap=${onTap != null ? "SET" : "NULL"}');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('[DEBUG] Button "$label" tapped, callback is ${onTap != null ? "SET" : "NULL"}');
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(context.w(0.03)),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient ?? const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF9C93FF)],
            ),
            borderRadius: BorderRadius.circular(context.w(0.03)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: context.h(0.015)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: context.sp(5), color: Colors.white),
                SizedBox(width: context.w(0.02)),
                Text(
                  label,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4.2),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return null;
    }
  }

  String? _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (e) {
      return null;
    }
  }

  Color _getSleepStatusColor(double hours) {
    final deviation = hours - targetHours;
    if (deviation >= 0) return Colors.green.shade600;
    if (deviation >= -1) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  String _getDeviationText(double hours) {
    final deviation = hours - targetHours;
    if (deviation >= 0) {
      return 'Đạt mục tiêu +${deviation.toStringAsFixed(1)}h';
    } else {
      return 'Thiếu ${(-deviation).toStringAsFixed(1)}h';
    }
  }
}
