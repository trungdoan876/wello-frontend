import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/entities/question.dart';
import 'package:wello_frontend/domain/providers/question_provider.dart';
import 'package:wello_frontend/ui/question/name_question/name_page.dart';
import 'package:wello_frontend/ui/question/gender_question/gender_page.dart';
import 'package:wello_frontend/ui/question/age_weight_question/age_page.dart';
import 'package:wello_frontend/ui/question/age_weight_question/weight_page.dart';
import 'package:wello_frontend/ui/question/height_question/height_page.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class EditBasicInfoPage extends StatefulWidget {
  final String nickname;
  final String gender;
  final int age;
  final int height;
  final int weight;
  final int userId;
  final Future<bool> Function(int userId, String fullname)? onUpdateFullname;
  final Future<bool> Function(int userId, String gender)? onUpdateGender;
  final Future<bool> Function(int userId, int age)? onUpdateAge;
  final Future<bool> Function(int userId, int height)? onUpdateHeight;
  final Future<bool> Function(int userId, int weight)? onUpdateWeight;

  const EditBasicInfoPage({
    super.key,
    required this.nickname,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.userId,
    this.onUpdateFullname,
    this.onUpdateGender,
    this.onUpdateAge,
    this.onUpdateHeight,
    this.onUpdateWeight,
  });

  @override
  State<EditBasicInfoPage> createState() => _EditBasicInfoPageState();
}

class _EditBasicInfoPageState extends State<EditBasicInfoPage> {
  late String _nickname;
  late String _gender;
  late int _age;
  late int _height;
  late int _weight;
  bool _showUpdateSuccess = false;
  String? _successMessage;

  Future<Question?> _loadQuestion(
    bool Function(Question) matcher,
    String errorMessage,
  ) async {
    final questionProvider = context.read<QuestionProvider>();

    if (questionProvider.questions.isEmpty && !questionProvider.isLoading) {
      try {
        await questionProvider.loadQuestions();
      } catch (_) {
        _showQuestionError('Không tải được cấu hình câu hỏi từ server');
        return null;
      }
    }

    try {
      return questionProvider.questions.firstWhere(matcher);
    } catch (_) {
      _showQuestionError(errorMessage);
      return null;
    }
  }

  void _showQuestionError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    _nickname = widget.nickname;
    _gender = widget.gender;
    _age = widget.age;
    _height = widget.height;
    _weight = widget.weight;
  }

  Future<void> _editField(String fieldName, dynamic currentValue) async {
    if (fieldName == 'Nickname') {
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => NamePage(
            initialName: _nickname,
            buttonText: 'Cập nhật',
            returnNameOnSubmit: true,
            updateUserId: widget.userId,
            onUpdate: (fullname) async {
              if (widget.onUpdateFullname != null) {
                return await widget.onUpdateFullname!(widget.userId, fullname);
              }
              return false;
            },
          ),
        ),
      );
      if (result != null && result.trim().isNotEmpty) {
        final fullname = result.trim();
        final parts = fullname.split(' ');
        setState(() {
          _nickname = parts.isNotEmpty ? parts.last : fullname;
          _showUpdateSuccess = true;
          _successMessage = 'Cập nhật tên thành công';
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showUpdateSuccess = false);
        });
      }
      return;
    }

    if (fieldName == 'Giới tính') {
      final genderQuestion = await _loadQuestion((q) {
        final text = q.question.toLowerCase();
        final key = q.key?.toLowerCase();
        return q.type == 'gender' ||
            key == 'gender' ||
            text.contains('giới tính');
      }, 'Không tìm thấy cấu hình câu hỏi giới tính.');
      if (genderQuestion == null) return;

      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => GenderPage(
            question: genderQuestion,
            initialGender: _gender,
            buttonText: 'Cập nhật',
            onUpdate: widget.onUpdateGender != null
                ? (gender) async {
                    String apiGender;
                    if (gender == 'Nam') {
                      apiGender = 'MALE';
                    } else if (gender == 'Nữ') {
                      apiGender = 'FEMALE';
                    } else {
                      apiGender = 'OTHER';
                    }
                    return await widget.onUpdateGender!(
                      widget.userId,
                      apiGender,
                    );
                  }
                : null,
          ),
        ),
      );
      if (result != null) {
        setState(() {
          _gender = result;
          _showUpdateSuccess = true;
          _successMessage = 'Cập nhật giới tính thành công';
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showUpdateSuccess = false);
        });
      }
      return;
    }

    if (fieldName == 'Tuổi') {
      final ageQuestion = await _loadQuestion((q) {
        final text = q.question.toLowerCase();
        final key = q.key?.toLowerCase();
        return q.type == 'age' || key == 'age' || text.contains('tuổi');
      }, 'Không tìm thấy cấu hình câu hỏi tuổi.');
      if (ageQuestion == null) return;

      final result = await Navigator.push<int>(
        context,
        MaterialPageRoute(
          builder: (_) => AgePage(
            question: ageQuestion,
            initialAge: _age,
            buttonText: 'Cập nhật',
            onUpdate: (age) async {
              if (widget.onUpdateAge != null) {
                return await widget.onUpdateAge!(widget.userId, age);
              }
              return false;
            },
          ),
        ),
      );
      if (result != null) {
        setState(() {
          _age = result;
          _showUpdateSuccess = true;
          _successMessage = 'Cập nhật tuổi thành công';
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showUpdateSuccess = false);
        });
      }
      return;
    }

    if (fieldName == 'Chiều cao') {
      final heightQuestion = await _loadQuestion((q) {
        final text = q.question.toLowerCase();
        final key = q.key?.toLowerCase();
        return q.type == 'height' ||
            key == 'height' ||
            text.contains('chiều cao');
      }, 'Không tìm thấy cấu hình câu hỏi chiều cao.');
      if (heightQuestion == null) return;

      final result = await Navigator.push<int>(
        context,
        MaterialPageRoute(
          builder: (_) => HeightPage(
            question: heightQuestion,
            initialHeight: _height,
            buttonText: 'Cập nhật',
            onUpdate: (height) async {
              if (widget.onUpdateHeight != null) {
                return await widget.onUpdateHeight!(widget.userId, height);
              }
              return false;
            },
          ),
        ),
      );
      if (result != null) {
        setState(() {
          _height = result;
          _showUpdateSuccess = true;
          _successMessage = 'Cập nhật chiều cao thành công';
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showUpdateSuccess = false);
        });
      }
      return;
    }

    if (fieldName == 'Cân nặng hiện tại') {
      final weightQuestion = await _loadQuestion((q) {
        final text = q.question.toLowerCase();
        final key = q.key?.toLowerCase();
        return q.type == 'weight' ||
            key == 'weight' ||
            text.contains('cân nặng');
      }, 'Không tìm thấy cấu hình câu hỏi cân nặng.');
      if (weightQuestion == null) return;

      final result = await Navigator.push<int>(
        context,
        MaterialPageRoute(
          builder: (_) => WeightPage(
            question: weightQuestion,
            initialWeight: _weight,
            buttonText: 'Cập nhật',
            onUpdate: (weight) async {
              if (widget.onUpdateWeight != null) {
                return await widget.onUpdateWeight!(widget.userId, weight);
              }
              return false;
            },
          ),
        ),
      );
      if (result != null) {
        setState(() {
          _weight = result;
          _showUpdateSuccess = true;
          _successMessage = 'Cập nhật cân nặng thành công';
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showUpdateSuccess = false);
        });
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFFFF6D5);

    return WillPopScope(
      onWillPop: () async {
        // Return true if any field was updated
        final hasChanges =
            _nickname != widget.nickname ||
            _gender != widget.gender ||
            _age != widget.age ||
            _height != widget.height ||
            _weight != widget.weight;
        Navigator.of(context).pop(hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF4C494C),
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          centerTitle: true,
          title: Text(
            'Thông tin cơ bản',
            style: GoogleFonts.baloo2(
              color: const Color(0xFFEACF2C),
              fontWeight: FontWeight.w800,
              fontSize: context.sp(7.5),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(0.07),
            vertical: context.h(0.01),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: context.h(0.02)),
              if (_showUpdateSuccess)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(0.04),
                    vertical: context.h(0.012),
                  ),
                  margin: EdgeInsets.only(bottom: context.h(0.012)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF22C55E)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF22C55E)),
                      SizedBox(width: context.w(0.02)),
                      Expanded(
                        child: Text(
                          _successMessage ?? 'Cập nhật thành công',
                          style: GoogleFonts.baloo2(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF166534),
                            fontSize: context.sp(4.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _EditableRow(
                      label: 'Nickname của bạn',
                      value: _nickname,
                      onTap: () => _editField('Nickname', _nickname),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E2E2)),
                    _EditableRow(
                      label: 'Giới tính',
                      value: _gender,
                      onTap: () => _editField('Giới tính', _gender),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E2E2)),
                    _EditableRow(
                      label: 'Tuổi',
                      value: '$_age',
                      onTap: () => _editField('Tuổi', _age),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E2E2)),
                    _EditableRow(
                      label: 'Chiều cao',
                      value: '$_height cm',
                      onTap: () => _editField('Chiều cao', _height),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E2E2)),
                    _EditableRow(
                      label: 'Cân nặng hiện tại',
                      value: '$_weight kg',
                      onTap: () => _editField('Cân nặng hiện tại', _weight),
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditableRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isLast;

  const _EditableRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(0.04),
          vertical: context.h(0.015),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.baloo2(
                fontSize: context.sp(5.2),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF999999),
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(5.2),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4C494C),
                  ),
                ),
                SizedBox(width: context.w(0.02)),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFFB0AEB0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
