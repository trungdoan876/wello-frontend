import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class BedtimeBottomSheet extends StatefulWidget {
  final TimeOfDay? initialBedtime;
  final String? displayDate;
  final Future<bool> Function(String bedtime)? onSaved;

  const BedtimeBottomSheet({
    super.key,
    this.initialBedtime,
    this.displayDate,
    this.onSaved,
  });

  @override
  State<BedtimeBottomSheet> createState() => _BedtimeBottomSheetState();
}

class _BedtimeBottomSheetState extends State<BedtimeBottomSheet> {
  TimeOfDay? _bedtime;
  DateTime? _bedDate; // Ngày đi ngủ

  @override
  void initState() {
    super.initState();
    _bedtime = widget.initialBedtime ?? TimeOfDay.now();
    // Set ngày đi ngủ là ngày dashboard hiện tại
    _bedDate = widget.displayDate != null
        ? DateTime.tryParse(widget.displayDate!)
        : DateTime.now();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _bedtime ?? const TimeOfDay(hour: 22, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF6C63FF)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _bedtime = picked;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _bedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF6C63FF)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _bedDate = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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

          // Title with icon
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.sp(2)),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(context.sp(2)),
                ),
                child: Icon(
                  Icons.nightlight_round,
                  size: context.sp(6),
                  color: const Color(0xFF6C63FF),
                ),
              ),
              SizedBox(width: context.w(0.03)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ghi nhận giờ đi ngủ',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(6.5),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6C63FF),
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
          SizedBox(height: context.h(0.03)),

          // Time selector
          Text(
            '🌙 Bạn đi ngủ lúc',
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
                color: const Color(0xFF6C63FF).withOpacity(0.08),
                borderRadius: BorderRadius.circular(context.w(0.03)),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: context.sp(4.5),
                    color: const Color(0xFF6C63FF),
                  ),
                  SizedBox(width: context.w(0.03)),
                  Text(
                    _bedDate != null
                        ? DateFormat('dd/MM/yyyy').format(_bedDate!)
                        : 'Chọn ngày',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(4),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6C63FF),
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
                    const Color(0xFF6C63FF).withOpacity(0.1),
                    const Color(0xFF9C93FF).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(context.w(0.04)),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _bedtime != null ? _formatTime(_bedtime!) : '--:--',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(8),
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF6C63FF),
                    ),
                  ),
                  Icon(
                    Icons.access_time_rounded,
                    color: const Color(0xFF6C63FF),
                    size: context.sp(7),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: context.h(0.02)),

          // Info box
          Container(
            padding: EdgeInsets.all(context.w(0.04)),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(context.w(0.03)),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade700,
                  size: context.sp(5),
                ),
                SizedBox(width: context.w(0.03)),
                Expanded(
                  child: Text(
                    'Sáng mai bạn có thể ghi nhận giờ thức dậy',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(3.8),
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
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
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF9C93FF)],
                    ),
                    borderRadius: BorderRadius.circular(context.w(0.03)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _bedtime != null && _bedDate != null
                        ? () async {
                            // Kết hợp ngày và giờ thành DateTime đầy đủ
                            final bedDateTime = DateTime(
                              _bedDate!.year,
                              _bedDate!.month,
                              _bedDate!.day,
                              _bedtime!.hour,
                              _bedtime!.minute,
                            );

                            // Format thành ISO string
                            final bedtimeStr = DateFormat(
                              "yyyy-MM-dd'T'HH:mm:ss",
                            ).format(bedDateTime);

                            final success =
                                await widget.onSaved?.call(bedtimeStr) ?? false;

                            if (!mounted) return;

                            if (success) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã lưu giờ đi ngủ! Ngủ ngon nhé 😴',
                                    style: GoogleFonts.baloo2(),
                                  ),
                                  backgroundColor: const Color(0xFF6C63FF),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Không thể lưu giờ đi ngủ. Vui lòng thử lại.',
                                    style: GoogleFonts.baloo2(),
                                  ),
                                  backgroundColor: Colors.red.shade600,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: context.h(0.018)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.w(0.03)),
                      ),
                    ),
                    child: Text(
                      'Lưu',
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
    );
  }
}
