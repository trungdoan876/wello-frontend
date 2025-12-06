class Question {
  final int id;
  final String? key;
  final String type;
  final String question;
  final String? unit;
  final List<QuestionOption> options;

  Question({
    required this.id,
    this.key,
    required this.type,
    required this.question,
    this.unit,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      key: json['key'],
      type: json['type'],
      question: json['question'],
      unit: json['unit'],
      options: (json['options'] as List)
          .map((e) => QuestionOption.fromJson(e))
          .toList(),
    );
  }
}

class QuestionOption {
  final String answer;
  final String moTa;

  QuestionOption({
    required this.answer,
    required this.moTa,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      answer: json['answer'],
      moTa: json['moTa'],
    );
  }
}
