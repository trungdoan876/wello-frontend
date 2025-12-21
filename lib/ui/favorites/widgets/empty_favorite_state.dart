import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class EmptyFavoriteState extends StatelessWidget {
  const EmptyFavoriteState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(context.w(0.04)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(context.w(0.06)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: context.w(0.25),
                height: context.w(0.25),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 241, 207, 56),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb,
                  size: context.sp(12),
                  color: Colors.white,
                ),
              ),
              SizedBox(height: context.h(0.03)),
              Text(
                'Có thể bạn chưa biết?',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(5),
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
