import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class WaketimeBottomSheet extends StatefulWidget {
  final String bedtime; // "21:00"
  final String? bedtimeDateTimeIso; // "2026-01-03T22:00:00"
  final TimeOfDay? initialWakeTime;
  final double targetHours;
  final String? displayDate;
  final Function(
    String wakeTime,
    double actualHours,
    int quality,
    String? notes,
  )?
  onSaved;

  const WaketimeBottomSheet({
    super.key,
    required this.bedtime,
    this.bedtimeDateTimeIso,
    this.initialWakeTime,
    this.targetHours = 8.0,
    this.displayDate,
    this.onSaved,
  });

  @override
  State<WaketimeBottomSheet> createState() => _WaketimeBottomSheetState();
}

class _WaketimeBottomSheetState extends State<WaketimeBottomSheet> {
  TimeOfDay? _wakeTime;
  DateTime? _wakeDate; // Ngày thức dậy
  double? _calculatedHours;
  int _quality = 4; // Default to 4 stars
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _wakeTime = widget.initialWakeTime ?? const TimeOfDay(hour: 7, minute: 0);

    final bedtimeDateTime = widget.bedtimeDateTimeIso != null
        ? DateTime.tryParse(widget.bedtimeDateTimeIso!)
        : null;

    if (bedtimeDateTime != null) {
      _wakeDate = bedtimeDateTime.add(const Duration(days: 1));
    } else {
      // Fallback when we only have HH:mm bedtime
      final baseDate = widget.displayDate != null
          ? DateTime.tryParse(widget.displayDate!) ?? DateTime.now()
          : DateTime.now();
      _wakeDate = baseDate.add(const Duration(days: 1));
    }

    _calculateHours();
  }

  DateTime? _resolveBedDateTime(DateTime wakeDateTime) {
    if (widget.bedtimeDateTimeIso != null) {
      final parsed = DateTime.tryParse(widget.bedtimeDateTimeIso!);
      if (parsed != null) return parsed;
    }

    final bedtimeParts = widget.bedtime.split(':');
    if (bedtimeParts.length < 2) return null;

    final bedHour = int.tryParse(bedtimeParts[0]);
    final bedMinute = int.tryParse(bedtimeParts[1]);
    if (bedHour == null || bedMinute == null) return null;

    var bedDateTime = DateTime(
      wakeDateTime.year,
      wakeDateTime.month,
      wakeDateTime.day,
      bedHour,
      bedMinute,
    );

    if (!wakeDateTime.isAfter(bedDateTime)) {
      bedDateTime = bedDateTime.subtract(const Duration(days: 1));
    }

    return bedDateTime;
  }

  void _calculateHours() {
    if (_wakeTime == null || _wakeDate == null) {
      setState(() => _calculatedHours = null);
      return;
    }

    final wakeDateTime = DateTime(
      _wakeDate!.year,
      _wakeDate!.month,
      _wakeDate!.day,
      _wakeTime!.hour,
      _wakeTime!.minute,
    );
    final bedDateTime = _resolveBedDateTime(wakeDateTime);
    if (bedDateTime == null) {
      setState(() => _calculatedHours = null);
      return;
    }

    final totalMinutes = wakeDateTime.difference(bedDateTime).inMinutes;
    setState(() {
      _calculatedHours = totalMinutes / 60.0;
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _wakeTime ?? const TimeOfDay(hour: 7, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF4A90E2)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _wakeTime = picked;
        _calculateHours();
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _wakeDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF4A90E2)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _wakeDate = picked;
        _calculateHours();
      });
    }
  }

  Color _getStatusColor() {
    if (_calculatedHours == null) return Colors.grey;
    final deviation = _calculatedHours! - widget.targetHours;
    if (deviation >= 0) return Colors.green.shade600;
    if (deviation >= -1) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate;
    if (widget.displayDate != null) {
      try {
        final date = DateTime.parse(widget.displayDate!);
        formattedDate = DateFormat('dd/MM/yyyy').format(date);
      } catch (e) {
        formattedDate = widget.displayDate!;
      }
    } else {
      formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }

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
      child: SingleChildScrollView(
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

            // Title with icon
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.sp(2)),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(context.sp(2)),
                  ),
                  child: Icon(
                    Icons.wb_sunny_rounded,
                    size: context.sp(6),
                    color: const Color(0xFF4A90E2),
                  ),
                ),
                SizedBox(width: context.w(0.03)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ghi nhận giờ thức dậy',
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(6.5),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4A90E2),
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(3.8),
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(0.02)),

            // Bedtime info (read-only)
            Container(
              padding: EdgeInsets.all(context.w(0.04)),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(context.w(0.03)),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.nightlight_round,
                    size: context.sp(5),
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: context.w(0.03)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đã đi ngủ lúc',
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(3.5),
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        widget.bedtime,
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(5.5),
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: context.h(0.025)),

            // Wake time selector
            Text(
              '☀️ Bạn thức dậy lúc',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(4.5),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4C494C),
              ),
            ),
            SizedBox(height: context.h(0.01)),

            // Date picker row
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(context.w(0.03)),
              child: Container(
                padding: EdgeInsets.all(context.w(0.03)),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(context.w(0.03)),
                  border: Border.all(
                    color: const Color(0xFF4A90E2).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: context.sp(4.5),
                      color: const Color(0xFF4A90E2),
                    ),
                    SizedBox(width: context.w(0.03)),
                    Text(
                      _wakeDate != null
                          ? DateFormat('dd/MM/yyyy').format(_wakeDate!)
                          : 'Chọn ngày',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4A90E2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.h(0.015)),
            InkWell(
              onTap: () => _selectTime(context),
              borderRadius: BorderRadius.circular(context.w(0.04)),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(0.05),
                  vertical: context.h(0.02),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4A90E2).withOpacity(0.1),
                      const Color(0xFF5AB9EA).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(context.w(0.04)),
                  border: Border.all(
                    color: const Color(0xFF4A90E2).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _wakeTime != null ? _formatTime(_wakeTime!) : '--:--',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(8),
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF4A90E2),
                      ),
                    ),
                    Icon(
                      Icons.access_time_rounded,
                      color: const Color(0xFF4A90E2),
                      size: context.sp(7),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.h(0.025)),

            // Calculated summary
            if (_calculatedHours != null)
              Container(
                padding: EdgeInsets.all(context.w(0.04)),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.w(0.03)),
                  border: Border.all(color: _getStatusColor().withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '⏱️ Tổng giờ ngủ:',
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(4.2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_calculatedHours!.toStringAsFixed(1)} giờ',
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(5.5),
                            fontWeight: FontWeight.w800,
                            color: _getStatusColor(),
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
                            fontSize: context.sp(3.8),
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${widget.targetHours.toStringAsFixed(1)} giờ',
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(3.8),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.h(0.01)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          deviation >= 0 ? '✅ Vượt:' : '📉 Thiếu:',
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(3.8),
                            color: _getStatusColor(),
                          ),
                        ),
                        Text(
                          '${deviation.abs().toStringAsFixed(1)} giờ',
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(3.8),
                            fontWeight: FontWeight.w700,
                            color: _getStatusColor(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            SizedBox(height: context.h(0.025)),

            // Quality Rating (Stars)
            Text(
              '⭐ Chất lượng giấc ngủ',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(4.5),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4C494C),
              ),
            ),
            SizedBox(height: context.h(0.01)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _quality = index + 1),
                  icon: Icon(
                    index < _quality
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: context.sp(9),
                    color: index < _quality
                        ? const Color(0xFFFFC107)
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),
            SizedBox(height: context.h(0.015)),

            // Notes
            Text(
              '📝 Ghi chú',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(4.5),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4C494C),
              ),
            ),
            SizedBox(height: context.h(0.01)),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Hôm nay bạn ngủ thế nào?',
                hintStyle: GoogleFonts.baloo2(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.w(0.03)),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.w(0.03)),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.w(0.03)),
                  borderSide: const BorderSide(
                    color: Color(0xFF4A90E2),
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.all(context.w(0.03)),
              ),
              style: GoogleFonts.baloo2(),
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
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A90E2), Color(0xFF5AB9EA)],
                      ),
                      borderRadius: BorderRadius.circular(context.w(0.03)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A90E2).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed:
                          _wakeTime != null &&
                              _calculatedHours != null &&
                              _wakeDate != null
                          ? () {
                              print('[DEBUG WAKETIME] Save button clicked');
                              print(
                                '[DEBUG WAKETIME] _wakeTime: $_wakeTime, _wakeDate: $_wakeDate, _quality: $_quality',
                              );

                              // Kết hợp ngày và giờ thành DateTime đầy đủ
                              var wakeDateTime = DateTime(
                                _wakeDate!.year,
                                _wakeDate!.month,
                                _wakeDate!.day,
                                _wakeTime!.hour,
                                _wakeTime!.minute,
                              );

                              final bedDateTime = _resolveBedDateTime(
                                wakeDateTime,
                              );
                              if (bedDateTime == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Không xác định được giờ đi ngủ. Vui lòng thử lại.',
                                      style: GoogleFonts.baloo2(),
                                    ),
                                    backgroundColor: Colors.red.shade600,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              final durationHours =
                                  wakeDateTime
                                      .difference(bedDateTime)
                                      .inMinutes /
                                  60.0;
                              if (durationHours <= 0 || durationHours > 16) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Thời lượng ngủ phải lớn hơn 0 và không quá 16 giờ.',
                                      style: GoogleFonts.baloo2(),
                                    ),
                                    backgroundColor: Colors.red.shade600,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              // Format thành ISO string
                              final wakeTimeStr = DateFormat(
                                "yyyy-MM-dd'T'HH:mm:ss",
                              ).format(wakeDateTime);
                              print(
                                '[DEBUG WAKETIME] Formatted wakeTime: $wakeTimeStr',
                              );
                              print(
                                '[DEBUG WAKETIME] Calling onSaved callback...',
                              );

                              widget.onSaved?.call(
                                wakeTimeStr, // Gửi full timestamp
                                durationHours,
                                _quality,
                                _notesController.text.isNotEmpty
                                    ? _notesController.text
                                    : null,
                              );

                              print('[DEBUG WAKETIME] Closing bottom sheet...');
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã lưu giấc ngủ! Chúc bạn ngày mới tốt lành 🌅',
                                    style: GoogleFonts.baloo2(),
                                  ),
                                  backgroundColor: const Color(0xFF4A90E2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                          vertical: context.h(0.018),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.w(0.03)),
                        ),
                      ),
                      child: Text(
                        'Hoàn thành',
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(4.5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
