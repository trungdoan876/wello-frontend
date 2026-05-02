import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StreakDialog extends StatelessWidget {
  final String message;
  final VoidCallback onConfirm;

  const StreakDialog({
    super.key,
    required this.message,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF9E3),
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xffEBCF23).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              // Animated Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xffEBCF23).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/streak.png',
                  height: 80,
                  width: 80,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 1000.ms,
                    curve: Curves.easeInOut,
                  )
                  .shimmer(delay: 2000.ms, duration: 1500.ms),

              const SizedBox(height: 24),
              
              Text(
                'Streak Ngày Mới! 🔥',
                style: GoogleFonts.baloo2(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xffEBCF23),
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

              const SizedBox(height: 32),

              // Confirm Button
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffEBCF23),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Tuyệt vời',
                    style: GoogleFonts.baloo2(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate().scale(delay: 600.ms, duration: 400.ms, curve: Curves.elasticOut),
              ),
            ],
          ),
        ).animate().scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }
}
