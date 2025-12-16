import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import '../models/favorite_item.dart';

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
              SizedBox(height: context.h(0.02)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(0.08)),
                child: Text(
                  'THỰC PHẨM TỐT CHO HỆ TIÊU HÓA',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4.5),
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: context.h(0.02)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(0.06)),
                child: Text(
                  'Thực phẩm này chứa nhiều vi khuẩn tốt và nhiều chất xơ giúp bộ máy tiêu hóa làm việc trong trạng thái tốt nhất.',
                  //textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(3.2),
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: context.h(0.02)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(0.02)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      [
                            'Hạnh nhân',
                            'Măng tây',
                            'Dừa',
                            'Gừng',
                            'Mật ong',
                          ]
                          .map(
                            (item) => Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(0.008),
                              ),
                              child: Text(
                                '- $item',
                                style: GoogleFonts.baloo2(
                                  fontSize: context.sp(3.2),
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              SizedBox(height: context.h(0.03)),
          
            ],
          ),
        ),
      ),
    );
  }
}
