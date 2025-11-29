import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/question/gender_question/gender_page.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.addListener(() {
      setState(() {}); // cập nhật UI khi nhập
    });
  }

  @override
  Widget build(BuildContext context) {
   // final bool isEmpty = nameController.text.trim().isEmpty;

    return Scaffold(

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + context.h(0.05)),
        child: Padding(
          padding: EdgeInsets.only(top: context.h(0.05)),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            leadingWidth: context.w(0.2),
            iconTheme: IconThemeData(
              color: const Color(0xffEBCF23), // màu icon back
              size: context.sp(10),
            ),
            title: Text(
              "Wello",
              style: GoogleFonts.pacifico(
                fontSize: context.sp(12.0),
                color: const Color(0xffEBCF23),
              ),
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,

      body: Container(
        width: context.w(1),
        height: context.h(1),
        decoration: const BoxDecoration(
          color: Color(0xffFFF8E8),
          image: DecorationImage(
            image: AssetImage("assets/images/question_bg.png"),
            alignment: Alignment.bottomCenter,
            fit: BoxFit.contain,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.w(0.07)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: context.h(0.18)), // tăng lên để tránh AppBar

                Text(
                  'Bạn tên là gì?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(8.0),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffEBCF23),
                  ),
                ),

                SizedBox(height: context.h(0.05)),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.w(0.04)),
                  height: context.h(0.065),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xffEBCF23),
                      width: 2.0,
                    ),
                  ),
                  child: Center(
                    child: TextField(
                      controller: nameController,
                      style: TextStyle(fontSize: context.sp(4)),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Bạn muốn mình gọi bạn là ...",
                        hintStyle: TextStyle(fontSize: context.sp(4)),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: context.h(0.05)),

                SizedBox(
                  width: context.w(0.5),
                  child: AnimatedStartButton(
                    text: "Tiếp tục",
                    onPressed: nameController.text.trim().isEmpty
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const GenderPage(),
                              ),
                            );
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
}
