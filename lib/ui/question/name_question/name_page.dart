import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/providers/question_provider.dart';
import 'package:wello_frontend/data/models/question.dart';
import 'package:wello_frontend/ui/question/gender_question/gender_page.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class NamePage extends StatefulWidget {
  final Question? question;
  final int? userId;
  const NamePage({super.key, this.question, this.userId});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final TextEditingController nameController = TextEditingController();
  Question? _currentQuestion;

  @override
  void initState() {
    super.initState();
    nameController.addListener(() {
      setState(() {}); // cập nhật UI khi nhập
    });

    // Load questions from backend if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<QuestionProvider>(context, listen: false);
      if (provider.questions.isEmpty && !provider.isLoading) {
        provider.loadQuestions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestionProvider>(
      builder: (context, questionProvider, child) {
        // Show loading state
        if (questionProvider.isLoading) {
          return _buildLoadingScreen();
        }

        // Show error state
        if (questionProvider.hasError) {
          return _buildErrorScreen(questionProvider);
        }

        // Get current question (from prop or from provider)
        _currentQuestion =
            widget.question ?? questionProvider.getQuestionByIndex(0);

        if (_currentQuestion == null) {
          return _buildErrorScreen(questionProvider);
        }

        return _buildNameQuestionScreen(questionProvider);
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8E8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: const Color(0xffEBCF23)),
            SizedBox(height: 20),
            Text(
              'Đang tải câu hỏi...',
              style: GoogleFonts.baloo2(
                fontSize: 18,
                color: const Color(0xffEBCF23),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(QuestionProvider provider) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8E8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red),
              SizedBox(height: 20),
              Text(
                'Không thể tải câu hỏi',
                style: GoogleFonts.baloo2(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xffEBCF23),
                ),
              ),
              SizedBox(height: 10),
              Text(
                provider.errorMessage ?? 'Đã xảy ra lỗi',
                textAlign: TextAlign.center,
                style: GoogleFonts.baloo2(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => provider.retry(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffEBCF23),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  'Thử lại',
                  style: GoogleFonts.baloo2(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameQuestionScreen(QuestionProvider questionProvider) {
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
              color: const Color(0xffEBCF23),
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
                SizedBox(height: context.h(0.18)),

                Text(
                  _currentQuestion!.question,
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
                            // Get next question from provider
                            final nextQuestion = questionProvider
                                .getQuestionByIndex(1);
                            if (nextQuestion != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GenderPage(
                                    question: nextQuestion,
                                    fullname: nameController.text.trim(),
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            }
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
