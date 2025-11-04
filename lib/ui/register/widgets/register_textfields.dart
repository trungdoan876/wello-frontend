import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterTextFields extends StatelessWidget {
  const RegisterTextFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Email field
        TextField(
          decoration: InputDecoration(
            labelText: "Email",
            hintStyle: GoogleFonts.beVietnamPro(
              color: const Color(0xFFF1F4FF),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFF),
            contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Color(0xFF7D90D2),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF7D90D2),
                width: 2.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Password field
        TextField(
            obscureText: true, //ẩn ký tự
          decoration: InputDecoration(
            labelText: "Password",
            hintStyle: GoogleFonts.beVietnamPro(
              color: const Color(0xFFF1F4FF),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFF),
            contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Color(0xFF7D90D2),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF7D90D2),
                width: 2.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

         // Confirm Password field
        TextField(
            obscureText: true, //ẩn ký tự
          decoration: InputDecoration(
            labelText: "Confirm Password",
            hintStyle: GoogleFonts.beVietnamPro(
              color: const Color(0xFFF1F4FF),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFF),
            contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Color(0xFF7D90D2),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF7D90D2),
                width: 2.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );

  }
}
