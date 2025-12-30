import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/data/models/responses/profile_response_model.dart';
import 'package:wello_frontend/domain/entities/question.dart';
import 'package:wello_frontend/domain/providers/question_provider.dart';
import 'package:wello_frontend/ui/question/age_weight_question/weight_page.dart';
import 'package:wello_frontend/ui/question/target_question/target_screen.dart';
import 'package:wello_frontend/ui/question/activity_question/activity_level_screen.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'edit_basic_info_page.dart';

class PhysicalProfilePage extends StatefulWidget {
  final ProfileResponseModel profile;
  final Future<bool> Function(int userId, String fullname)? onUpdateFullname;
  final Future<bool> Function(int userId, String gender)? onUpdateGender;
  final Future<bool> Function(int userId, int age)? onUpdateAge;
  final Future<bool> Function(int userId, int height)? onUpdateHeight;
  final Future<bool> Function(int userId, int weight)? onUpdateWeight;
  final Future<bool> Function(int userId, String goal)? onUpdateGoal;
  final Future<bool> Function(int userId, String activityLevel)?
  onUpdateActivityLevel;
  final Future<ProfileResponseModel?> Function()? onRefreshProfile;

  const PhysicalProfilePage({
    super.key,
    required this.profile,
    this.onUpdateFullname,
    this.onUpdateGender,
    this.onUpdateAge,
    this.onUpdateHeight,
    this.onUpdateWeight,
    this.onUpdateGoal,
    this.onUpdateActivityLevel,
    this.onRefreshProfile,
  });

  @override
  State<PhysicalProfilePage> createState() => _PhysicalProfilePageState();
}

class _PhysicalProfilePageState extends State<PhysicalProfilePage> {
  late ProfileResponseModel _currentProfile;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
  }

  String _mapGender(String gender) {
    final lower = gender.toLowerCase();
    if (lower.startsWith('f')) return 'Nữ';
    if (lower.startsWith('m')) return 'Nam';
    if (lower.startsWith('o')) return 'Khác';
    return gender;
  }

  String _mapGoal(String goal) {
    final lower = goal.toLowerCase();
    if (lower.contains('maintain')) return 'Duy trì cân nặng';
    if (lower.contains('lose')) return 'Giảm cân';
    if (lower.contains('gain')) return 'Tăng cân';
    return goal;
  }

  String _mapActivity(String level) {
    final upper = level.toUpperCase();
    if (upper == 'SEDENTARY') return 'Ít vận động';
    if (upper == 'LIGHT_ACTIVE') return 'Vận động nhẹ';
    if (upper == 'MODERATE_ACTIVE') return 'Vận động vừa';
    if (upper == 'HEAVY_ACTIVE') return 'Vận động nặng';
    if (upper == 'VERY_HEAVY_ACTIVE') return 'Vận động rất nặng';
    return level;
  }

  String _formatDate(String rawDate) {
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }

  String _formatWeight(double weight) {
    final hasDecimal = weight % 1 != 0;
    return hasDecimal
        ? '${weight.toStringAsFixed(1)} kg'
        : '${weight.toStringAsFixed(0)} kg';
  }

  DateTime? _expectedEndDate(String rawDate) {
    try {
      return DateTime.parse(rawDate).add(const Duration(days: 30));
    } catch (_) {
      return null;
    }
  }

  String _nicknameFromName(String name) {
    final parts = name.trim().split(' ');
    return parts.isNotEmpty ? parts.last : name;
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFFFF6D5);
    final startDate = _currentProfile.surveyDate;
    final endDate = _expectedEndDate(startDate);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4C494C)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Text(
          'Hồ sơ thể chất',
          style: GoogleFonts.baloo2(
            color: const Color(0xFFEACF2C),
            fontWeight: FontWeight.w800,
            fontSize: context.sp(7.5),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(0.05),
          vertical: context.h(0.02),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thông tin cơ bản',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(6.2),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4C494C),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final updated = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => EditBasicInfoPage(
                          nickname: _nicknameFromName(_currentProfile.fullname),
                          gender: _mapGender(_currentProfile.gender),
                          age: _currentProfile.age,
                          height: _currentProfile.height,
                          weight: _currentProfile.weight.toInt(),
                          userId: _currentProfile.userId,
                          onUpdateFullname: widget.onUpdateFullname,
                          onUpdateGender: widget.onUpdateGender,
                          onUpdateAge: widget.onUpdateAge,
                          onUpdateHeight: widget.onUpdateHeight,
                          onUpdateWeight: widget.onUpdateWeight,
                        ),
                      ),
                    );

                    // If updated, refresh profile
                    if (updated == true && widget.onRefreshProfile != null) {
                      final refreshed = await widget.onRefreshProfile!();
                      if (refreshed != null && mounted) {
                        setState(() {
                          _currentProfile = refreshed;
                        });
                      }
                    }
                  },
                  icon: const Icon(Icons.edit, color: Color(0xFF8B898B)),
                ),
              ],
            ),
            SizedBox(height: context.h(0.01)),
            _BasicInfoCard(
              nickname: _nicknameFromName(_currentProfile.fullname),
              gender: _mapGender(_currentProfile.gender),
              age: _currentProfile.age,
              height: _currentProfile.height,
            ),
            SizedBox(height: context.h(0.03)),
            Text(
              'Mục tiêu cân nặng',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(6.2),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4C494C),
              ),
            ),
            SizedBox(height: context.h(0.012)),
            _WeightGoalCard(
              goalLabel: _mapGoal(_currentProfile.goal),
              goal: _currentProfile.goal,
              targetWeight: _formatWeight(_currentProfile.weight),
              currentWeight: _formatWeight(_currentProfile.weight),
              currentWeightInt: _currentProfile.weight.toInt(),
              userId: _currentProfile.userId,
              activity: _mapActivity(_currentProfile.activityLevel),
              activityLevel: _currentProfile.activityLevel,
              startDate: _formatDate(startDate),
              endDate: endDate != null
                  ? DateFormat('dd/MM/yyyy').format(endDate)
                  : 'Đang tính',
              onUpdateWeight: widget.onUpdateWeight,
              onUpdateGoal: widget.onUpdateGoal,
              onUpdateActivityLevel: widget.onUpdateActivityLevel,
              onRefresh: () async {
                if (widget.onRefreshProfile != null) {
                  final refreshed = await widget.onRefreshProfile!();
                  if (refreshed != null && mounted) {
                    setState(() {
                      _currentProfile = refreshed;
                    });
                  }
                }
              },
            ),
            SizedBox(height: context.h(0.02)),
          ],
        ),
      ),
    );
  }
}

class _BasicInfoCard extends StatelessWidget {
  final String nickname;
  final String gender;
  final int age;
  final int height;

  const _BasicInfoCard({
    required this.nickname,
    required this.gender,
    required this.age,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.w(0.04),
        vertical: context.h(0.02),
      ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NICKNAME',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(4.5),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF8B898B),
                    ),
                  ),
                  SizedBox(height: context.h(0.004)),
                  Text(
                    nickname,
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(7),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE7BA00),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: context.h(0.01)),
          Container(
            height: 1.5,
            color: const Color.fromARGB(255, 203, 203, 203),
          ),
          SizedBox(height: context.h(0.018)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoChip(
                label: 'Giới tính',
                value: gender,
                highlight: gender == 'Nữ',
              ),
              _InfoChip(label: 'Tuổi', value: age.toString()),
              _InfoChip(
                label: 'Chiều cao',
                value: '$height cm',
                highlight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _InfoChip({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? const Color(0xFFE7BA00) : const Color(0xFF4C494C);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(4.6),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF8B898B),
            ),
          ),
          SizedBox(height: context.h(0.003)),
          Text(
            value,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(5.6),
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightGoalCard extends StatelessWidget {
  final String goalLabel;
  final String goal;
  final String targetWeight;
  final String currentWeight;
  final String activity;
  final String activityLevel;
  final String startDate;
  final String endDate;
  final int currentWeightInt;
  final int userId;
  final Future<bool> Function(int userId, int weight)? onUpdateWeight;
  final Future<bool> Function(int userId, String goal)? onUpdateGoal;
  final Future<bool> Function(int userId, String activityLevel)?
  onUpdateActivityLevel;
  final VoidCallback? onRefresh;

  const _WeightGoalCard({
    required this.goalLabel,
    required this.goal,
    required this.targetWeight,
    required this.currentWeight,
    required this.activity,
    required this.activityLevel,
    required this.startDate,
    required this.endDate,
    required this.currentWeightInt,
    required this.userId,
    this.onUpdateWeight,
    this.onUpdateGoal,
    this.onUpdateActivityLevel,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.w(0.04),
        vertical: context.h(0.018),
      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(0.03),
                  vertical: context.h(0.007),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D1D1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  goalLabel,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4.8),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4C494C),
                  ),
                ),
              ),
              Text(
                targetWeight,
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(5.2),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4C494C),
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(0.015)),
          const Divider(height: 1, color: Color(0xFFE2E2E2)),
          SizedBox(height: context.h(0.015)),
          _GoalRow(
            title: 'Cân nặng hiện tại',
            value: currentWeight,
            onTap: onUpdateWeight != null ? () => _editWeight(context) : null,
          ),
          const Divider(height: 1, color: Color(0xFFE2E2E2)),
          SizedBox(height: context.h(0.015)),
          _GoalRow(
            title: 'Mục tiêu',
            value: goalLabel,
            onTap: onUpdateGoal != null ? () => _editGoal(context) : null,
          ),
          const Divider(height: 1, color: Color(0xFFE2E2E2)),
          SizedBox(height: context.h(0.015)),
          _GoalRow(
            title: 'Cường độ vận động',
            value: activity,
            onTap: onUpdateActivityLevel != null
                ? () => _editActivityLevel(context)
                : null,
          ),
          const Divider(height: 1, color: Color(0xFFE2E2E2)),
          SizedBox(height: context.h(0.015)),
          _GoalRow(title: 'Ngày bắt đầu', value: startDate),
          const Divider(height: 1, color: Color(0xFFE2E2E2)),
          SizedBox(height: context.h(0.015)),
          _GoalRow(title: 'Ngày kết thúc', value: endDate),
        ],
      ),
    );
  }

  Future<void> _editWeight(BuildContext context) async {
    final dummyQuestion = Question(
      id: 0,
      question: 'Cân nặng hiện tại của bạn?',
      type: 'number',
      options: [],
      unit: 'kg',
    );
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => WeightPage(
          question: dummyQuestion,
          initialWeight: currentWeightInt,
          buttonText: 'Cập nhật',
          onUpdate: (weight) async {
            if (onUpdateWeight != null) {
              return await onUpdateWeight!(userId, weight);
            }
            return false;
          },
        ),
      ),
    );
    if (result != null && onRefresh != null) {
      onRefresh!();
    }
  }

  Future<void> _editGoal(BuildContext context) async {
    final questionProvider = Provider.of<QuestionProvider>(
      context,
      listen: false,
    );

    // Find the goal question from the loaded questions
    Question? foundGoalQuestion;
    for (var q in questionProvider.questions) {
      if (q.type == 'goal' || q.question.toLowerCase().contains('mục tiêu')) {
        foundGoalQuestion = q;
        break;
      }
    }

    // Use found question or create fallback
    final goalQuestion =
        foundGoalQuestion ??
        Question(
          id: 0,
          question: 'Mục tiêu của bạn là gì?',
          type: 'goal',
          options: [
            QuestionOption(answer: 'GAIN_WEIGHT', moTa: 'Tăng cân'),
            QuestionOption(answer: 'LOSE_WEIGHT', moTa: 'Giảm cân'),
            QuestionOption(answer: 'KEEP_FIT', moTa: 'Giữ dáng'),
          ],
        );

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => TargetLevelScreen(
          question: goalQuestion,
          initialGoal: goal,
          buttonText: 'Cập nhật',
          onUpdate: (goal) async {
            if (onUpdateGoal != null) {
              return await onUpdateGoal!(userId, goal);
            }
            return false;
          },
        ),
      ),
    );
    if (result != null && onRefresh != null) {
      onRefresh!();
    }
  }

  Future<void> _editActivityLevel(BuildContext context) async {
    final questionProvider = Provider.of<QuestionProvider>(
      context,
      listen: false,
    );

    // Find the activity level question from the loaded questions
    Question? foundActivityQuestion;
    for (var q in questionProvider.questions) {
      if (q.type == 'activity' ||
          q.question.toLowerCase().contains('cường độ') ||
          q.question.toLowerCase().contains('hoạt động')) {
        foundActivityQuestion = q;
        break;
      }
    }

    // Use found question or create fallback
    final activityQuestion =
        foundActivityQuestion ??
        Question(
          id: 0,
          question: 'Cường độ hoạt động của bạn?',
          type: 'activity',
          options: [
            QuestionOption(answer: 'SEDENTARY', moTa: 'Ít vận động'),
            QuestionOption(answer: 'LIGHT_ACTIVE', moTa: 'Vận động nhẹ'),
            QuestionOption(
              answer: 'MODERATE_ACTIVE',
              moTa: 'Vận động vừa phải',
            ),
            QuestionOption(answer: 'HEAVY_ACTIVE', moTa: 'Vận động nặng'),
            QuestionOption(
              answer: 'VERY_HEAVY_ACTIVE',
              moTa: 'Vận động rất nặng',
            ),
          ],
        );

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityLevelScreen(
          question: activityQuestion,
          initialActivityLevel: activityLevel,
          buttonText: 'Cập nhật',
          onUpdate: (activityLevel) async {
            if (onUpdateActivityLevel != null) {
              return await onUpdateActivityLevel!(userId, activityLevel);
            }
            return false;
          },
        ),
      ),
    );
    if (result != null && onRefresh != null) {
      onRefresh!();
    }
  }
}

class _GoalRow extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _GoalRow({required this.title, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: EdgeInsets.symmetric(vertical: context.h(0.008)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.baloo2(
                fontSize: context.sp(5),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7A777A),
              ),
            ),
          ),
          SizedBox(width: context.w(0.02)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(5),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4C494C),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.right,
                  ),
                ),
                if (onTap != null) ...[
                  SizedBox(width: context.w(0.02)),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Color(0xFF4C494C),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;

    return InkWell(onTap: onTap, child: child);
  }
}
