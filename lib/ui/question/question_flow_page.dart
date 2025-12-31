import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/providers/question_provider.dart';
import 'package:wello_frontend/ui/question/height_question/height_page.dart';
import 'package:wello_frontend/ui/widgets/loading_page.dart';

/// QuestionFlowPage loads questions from the provider and starts the survey flow
class QuestionFlowPage extends StatefulWidget {
  const QuestionFlowPage({super.key});

  @override
  State<QuestionFlowPage> createState() => _QuestionFlowPageState();
}

class _QuestionFlowPageState extends State<QuestionFlowPage> {
  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final provider = Provider.of<QuestionProvider>(context, listen: false);
      await provider.loadQuestions();
      
      // Navigate to first question (HeightPage at index 0)
      if (mounted) {
        final firstQuestion = provider.getQuestionByIndex(0);
        if (firstQuestion != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HeightPage(question: firstQuestion),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loi khi tai cau hoi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create a placeholder page that will be replaced once questions load
    return LoadingPage(
      nextPage: Container(), // Placeholder, will be replaced by navigation
    );
  }
}
