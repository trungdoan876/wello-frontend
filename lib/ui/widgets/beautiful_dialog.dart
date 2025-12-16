import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom beautiful dialog widget
class BeautifulDialog extends StatelessWidget {
  final String title;
  final String message;
  final bool isError;

  const BeautifulDialog({
    super.key,
    required this.title,
    required this.message,
    this.isError = true,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryYellow = Color(0xFFEBCF23);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isError ? Colors.red.shade50 : Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                size: 56,
                color: isError ? Colors.red.shade400 : Colors.green.shade400,
              ),
            ),

            const SizedBox(height: 20),

            // Message
            Text(
              message,
              style: GoogleFonts.baloo2(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // OK Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryYellow,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'OK',
                  style: GoogleFonts.baloo2(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show dialog helper
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    bool isError = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          BeautifulDialog(title: title, message: message, isError: isError),
    );
  }
}
