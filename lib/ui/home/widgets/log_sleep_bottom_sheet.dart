import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class LogSleepBottomSheet extends StatefulWidget {
  final bool isEdit;
  final String? initialBedtime;
  final String? initialWakeTime;
  final double targetHours;
  final Function(String bedtime, String wakeTime, double hours)? onSaved;

  const LogSleepBottomSheet({
    super.key,
    this.isEdit = false,
    this.initialBedtime,
    this.initialWakeTime,
    this.targetHours = 8.0,
    this.onSaved,
  });

  @override
  State<LogSleepBottomSheet> createState() => _LogSleepBottomSheetState();
}

class _LogSleepBottomSheetState extends State<LogSleepBottomSheet> {
  TimeOfDay? _bedtime;
  TimeOfDay? _wakeTime;
  double? _calculatedHours;

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if editing
    if (widget.initialBedtime != null) {
      final parts = widget.initialBedtime!.split(':');
      _bedtime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    if (widget.initialWakeTime != null) {
      final parts = widget.initialWakeTime!.split(':');
      _wakeTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    _calculateHours();
  }

  void _calculateHours() {
    if (_bedtime == null || _wakeTime == null) {
      setState(() => _calculatedHours = null);
      return;
    }

    // Convert to minutes since midnight
    final bedMinutes = _bedtime!.hour * 60 + _bedtime!.minute;
    var wakeMinutes = _wakeTime!.hour * 60 + _wakeTime!.minute;

    // If wake time is earlier than bed time, it means next day
    if (wakeMinutes <= bedMinutes) {
      wakeMinutes += 24 * 60; // Add 24 hours
    }

    final totalMinutes = wakeMinutes - bedMinutes;
    setState(() {
      _calculatedHours = totalMinutes / 60.0;
    });
  }

  Future<void> _selectTime(BuildContext context, bool isBedtime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isBedtime
          ? (_bedtime ?? const TimeOfDay(hour: 22, minute: 0))
          : (_wakeTime ?? const TimeOfDay(hour: 7, minute: 0)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C63FF),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isBedtime) {
          _bedtime = picked;
        } else {
          _wakeTime = picked;
        }
        _calculateHours();
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getDateLabel(bool isBedtime) {
    if (_bedtime == null || _wakeTime == null) {
      return DateFormat('dd/MM/yyyy').format(DateTime.now());
    }

    final bedMinutes = _bedtime!.hour * 60 + _bedtime!.minute;
    final wakeMinutes = _wakeTime!.hour * 60 + _wakeTime!.minute;
    final now = DateTime.now();

    if (isBedtime) {
      // Bedtime is yesterday if wake time is before bed time
      if (wakeMinutes <= bedMinutes) {
        final yesterday = now.subtract(const Duration(days: 1));
        return DateFormat('dd/MM/yyyy').format(yesterday);
      }
      return DateFormat('dd/MM/yyyy').format(now);
    } else {
      // Wake time is today
      return DateFormat('dd/MM/yyyy').format(now);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviation = _calculatedHours != null
        ? _calculatedHours! - widget.targetHours
        : 0.0;

    return Container(
      padding: EdgeInsets.only(
        top: context.h(0.03),
        left: context.w(0.05),
        right: context.w(0.05),
        bottom: MediaQuery.of(context).viewInsets.bottom + context.h(0.03),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.w(0.06)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: context.w(0.12),
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: context.h(0.02)),

          // Title
          Text(
            widget.isEdit ? 'Chỉnh sửa giấc ngủ' : 'Ghi nhận giấc ngủ',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(6.5),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF6C63FF),
            ),
          ),
          Text(
            DateFormat('dd/MM/yyyy').format(DateTime.now()),
            style: GoogleFonts.baloo2(
              fontSize: context.sp(4),
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: context.h(0.03)),

          // Bedtime selector
          _buildTimeSelector(
            context,
            '🌙 Tối qua đi ngủ lúc',
            _bedtime,
            _getDateLabel(true),
            () => _selectTime(context, true),
          ),
          SizedBox(height: context.h(0.02)),

          // Wake time selector
          _buildTimeSelector(
            context,
            '☀️ Sáng nay thức dậy lúc',
            _wakeTime,
            _getDateLabel(false),
            () => _selectTime(context, false),
          ),
          SizedBox(height: context.h(0.03)),

          // Calculated summary
          Container(
            padding: EdgeInsets.all(context.w(0.04)),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(context.w(0.03)),
              border: Border.all(
                color: const Color(0xFF6C63FF).withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '⏱️ Tổng giờ ngủ:',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _calculatedHours != null
                          ? '${_calculatedHours!.toStringAsFixed(1)} giờ'
                          : '--',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(5.5),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.h(0.01)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🎯 Mục tiêu:',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${widget.targetHours.toStringAsFixed(1)} giờ',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4),
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (_calculatedHours != null) ...[
                  SizedBox(height: context.h(0.01)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        deviation >= 0 ? '✅ Vượt:' : '📉 Thiếu:',
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(4),
                          color: deviation >= 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                      Text(
                        '${deviation.abs().toStringAsFixed(1)} giờ',
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(4),
                          fontWeight: FontWeight.w700,
                          color: deviation >= 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: context.h(0.03)),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: context.h(0.018)),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.w(0.03)),
                    ),
                  ),
                  child: Text(
                    'Hủy',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(4.5),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.w(0.03)),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _bedtime != null && _wakeTime != null
                      ? () {
                          widget.onSaved?.call(
                            _formatTime(_bedtime),
                            _formatTime(_wakeTime),
                            _calculatedHours!,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.isEdit
                                    ? 'Đã cập nhật giấc ngủ!'
                                    : 'Đã lưu giấc ngủ!',
                                style: GoogleFonts.baloo2(),
                              ),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: EdgeInsets.symmetric(vertical: context.h(0.018)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.w(0.03)),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: Text(
                    'Lưu',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(4.5),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(
    BuildContext context,
    String label,
    TimeOfDay? time,
    String dateLabel,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(4.2),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4C494C),
          ),
        ),
        SizedBox(height: context.h(0.01)),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.w(0.03)),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(0.04),
              vertical: context.h(0.015),
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(context.w(0.03)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(time),
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(6),
                        fontWeight: FontWeight.w800,
                        color: time != null
                            ? const Color(0xFF6C63FF)
                            : Colors.grey.shade400,
                      ),
                    ),
                    Text(
                      'Ngày: $dateLabel',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(3.2),
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.access_time,
                  color: const Color(0xFF6C63FF),
                  size: context.sp(6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
