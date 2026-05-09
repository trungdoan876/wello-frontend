import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class RunningTimerCard extends StatefulWidget {
  final bool isRunning;
  final VoidCallback onPauseResume;
  final VoidCallback onStop;

  const RunningTimerCard({
    Key? key,
    this.isRunning = false,
    required this.onPauseResume,
    required this.onStop,
  }) : super(key: key);

  @override
  State<RunningTimerCard> createState() => _RunningTimerCardState();
}

class _RunningTimerCardState extends State<RunningTimerCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(hours: 23, minutes: 59, seconds: 59),
      vsync: this,
    );

    _controller.addListener(() {
      setState(() {
        _elapsed = _controller.duration! * _controller.value;
      });
    });
  }

  @override
  void didUpdateWidget(RunningTimerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !oldWidget.isRunning) {
      _controller.forward();
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

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
          colors: [
            const Color(0xff1F2937),
            const Color(0xff111827),
          ],
        ),
        borderRadius: BorderRadius.circular(context.w(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
                width: context.w(0.02),
                height: context.w(0.02),
                decoration: const BoxDecoration(
                  color: Color(0xffEBCF23),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: context.w(0.02)),
              Text(
                'Đang chạy',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(5.5),
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(0.02)),
          Text(
            _formatTime(_elapsed),
            style: GoogleFonts.baloo2(
              fontSize: context.sp(12),
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2.5,
            ),
          ),
          SizedBox(height: context.h(0.03)),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onPauseResume,
                  icon: Icon(widget.isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(
                    widget.isRunning ? 'Tạm dừng' : 'Tiếp tục',
                    style: GoogleFonts.baloo2(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffEBCF23),
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(
                      vertical: context.h(0.015),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.w(0.035)),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              SizedBox(width: context.w(0.03)),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onStop,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: Text(
                    'Dừng',
                    style: GoogleFonts.baloo2(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.25)),
                    padding: EdgeInsets.symmetric(
                      vertical: context.h(0.015),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.w(0.035)),
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
