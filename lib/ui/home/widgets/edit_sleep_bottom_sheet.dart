import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class EditSleepBottomSheet extends StatefulWidget {
  final String initialBedtime; // "HH:mm"
  final String initialWakeTime; // "HH:mm"
  final int initialQuality;
  final String? initialNotes;
  final String? displayDate;
  final Function(String bedtime, String wakeTime, int quality, String? notes) onSaved;

  const EditSleepBottomSheet({
    super.key,
    required this.initialBedtime,
    required this.initialWakeTime,
    required this.initialQuality,
    this.initialNotes,
    this.displayDate,
    required this.onSaved,
  });

  @override
  State<EditSleepBottomSheet> createState() => _EditSleepBottomSheetState();
}

class _EditSleepBottomSheetState extends State<EditSleepBottomSheet> {
  late TimeOfDay _bedtime;
  late TimeOfDay _wakeTime;
  late int _quality;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _bedtime = _parseTime(widget.initialBedtime);
    _wakeTime = _parseTime(widget.initialWakeTime);
    _quality = widget.initialQuality;
    _notesController = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(BuildContext context, bool isBedtime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isBedtime ? _bedtime : _wakeTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: isBedtime ? const Color(0xFF6C63FF) : const Color(0xFF4A90E2),
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
      });
    }
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

            // Title
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.sp(2)),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(context.sp(2)),
                  ),
                  child: Icon(
                    Icons.edit_calendar_rounded,
                    size: context.sp(6),
                    color: Colors.amber.shade800,
                  ),
                ),
                SizedBox(width: context.w(0.03)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chỉnh sửa giấc ngủ',
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(6.5),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4C494C),
                        ),
                      ),
                      Text(
                        'Ngày $formattedDate',
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

            // Time Selectors Row
            Row(
              children: [
                Expanded(
                  child: _buildTimeSelector(
                    label: '🌙 Đi ngủ',
                    time: _bedtime,
                    color: const Color(0xFF6C63FF),
                    onTap: () => _selectTime(context, true),
                  ),
                ),
                SizedBox(width: context.w(0.04)),
                Expanded(
                  child: _buildTimeSelector(
                    label: '☀️ Thức dậy',
                    time: _wakeTime,
                    color: const Color(0xFF4A90E2),
                    onTap: () => _selectTime(context, false),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(0.03)),

            // Quality Section
            Text(
              '⭐ Chất lượng giấc ngủ',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(4.5),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4C494C),
              ),
            ),
            SizedBox(height: context.h(0.01)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _quality = starValue),
                  icon: Icon(
                    starValue <= _quality ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: context.sp(10),
                    color: starValue <= _quality ? Colors.amber : Colors.grey.shade300,
                  ),
                );
              }),
            ),
            SizedBox(height: context.h(0.02)),

            // Notes Section
            Text(
              '📝 Ghi chú thêm',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(4.5),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4C494C),
              ),
            ),
            SizedBox(height: context.h(0.01)),
            TextField(
              controller: _notesController,
              maxLines: 2,
              style: GoogleFonts.baloo2(),
              decoration: InputDecoration(
                hintText: 'Hôm nay bạn ngủ thế nào?',
                hintStyle: GoogleFonts.baloo2(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.w(0.03)),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.w(0.03)),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            SizedBox(height: context.h(0.04)),

            // Save button
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9C93FF)],
                  ),
                  borderRadius: BorderRadius.circular(context.w(0.04)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSaved(
                      _formatTime(_bedtime),
                      _formatTime(_wakeTime),
                      _quality,
                      _notesController.text,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: context.h(0.018)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.w(0.04)),
                    ),
                  ),
                  child: Text(
                    'Cập nhật',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required TimeOfDay time,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(4),
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: context.h(0.008)),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.w(0.03)),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(0.03),
              vertical: context.h(0.015),
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              border: Border.all(color: color.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(context.w(0.03)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatTime(time),
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(5.5),
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                SizedBox(width: context.w(0.02)),
                Icon(Icons.access_time_rounded, size: context.sp(4.5), color: color),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
