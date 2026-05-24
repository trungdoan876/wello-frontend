import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import '../../core/utils/auth_helper.dart';
import '../../domain/entities/food_request.dart';
import '../../domain/entities/exercise_request.dart';
import '../../domain/providers/contribution_provider.dart';
import '../widgets/responsive.dart';

class ContributionScreen extends StatefulWidget {
  final String initialType; // 'food' or 'exercise'

  const ContributionScreen({super.key, this.initialType = 'food'});

  @override
  State<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends State<ContributionScreen> {
  final _foodFormKey = GlobalKey<FormState>();
  final _exerciseFormKey = GlobalKey<FormState>();

  // Food Controllers
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _servingUnitController = TextEditingController(text: 'g');
  final _foodNoteController = TextEditingController();

  // Exercise Controllers
  final _exerciseNameController = TextEditingController();
  final _exerciseDescController = TextEditingController();
  final _metValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _servingSizeController.dispose();
    _servingUnitController.dispose();
    _foodNoteController.dispose();
    _exerciseNameController.dispose();
    _exerciseDescController.dispose();
    _metValueController.dispose();
    super.dispose();
  }

  Future<void> _submitFood() async {
    if (!_foodFormKey.currentState!.validate()) return;

    final credentials = await AuthHelper.getCredentials();
    if (credentials == null) return;

    final request = FoodRequest(
      foodName: _foodNameController.text,
      calories: int.parse(_caloriesController.text),
      protein: double.parse(_proteinController.text),
      carbs: double.parse(_carbsController.text),
      fat: double.parse(_fatController.text),
      servingSize: double.parse(_servingSizeController.text),
      servingUnit: _servingUnitController.text,
    );

    final provider = context.read<ContributionProvider>();
    final success = await provider.submitFoodRequest(credentials.token, request);

    if (success && mounted) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Thành công',
        text: 'Yêu cầu thêm thực phẩm của bạn đã được gửi và đang chờ duyệt!',
        confirmBtnColor: const Color(0xffEBCF23),
        onConfirmBtnTap: () {
          Navigator.pop(context); // Close alert
          Navigator.pop(context); // Go back
        },
      );
    } else if (mounted) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Lỗi',
        text: provider.error ?? 'Đã có lỗi xảy ra. Vui lòng thử lại.',
        confirmBtnColor: const Color(0xffEBCF23),
      );
    }
  }

  Future<void> _submitExercise() async {
    if (!_exerciseFormKey.currentState!.validate()) return;

    final credentials = await AuthHelper.getCredentials();
    if (credentials == null) return;

    final request = ExerciseRequest(
      exerciseName: _exerciseNameController.text,
      metValue: double.tryParse(_metValueController.text),
    );

    final provider = context.read<ContributionProvider>();
    final success = await provider.submitExerciseRequest(credentials.token, request);

    if (success && mounted) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Thành công',
        text: 'Yêu cầu thêm bài tập của bạn đã được gửi và đang chờ duyệt!',
        confirmBtnColor: const Color(0xffEBCF23),
        onConfirmBtnTap: () {
          Navigator.pop(context); // Close alert
          Navigator.pop(context); // Go back
        },
      );
    } else if (mounted) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Lỗi',
        text: provider.error ?? 'Đã có lỗi xảy ra. Vui lòng thử lại.',
        confirmBtnColor: const Color(0xffEBCF23),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isExercise = widget.initialType == 'exercise';
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(context.sp(5))),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.symmetric(vertical: context.h(0.015)),
                width: context.w(0.15),
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Title
              Text(
                isExercise ? 'Yêu cầu Bài tập mới' : 'Yêu cầu Thực phẩm mới',
                style: GoogleFonts.baloo2(
                  color: const Color(0xffEBCF23),
                  fontWeight: FontWeight.bold,
                  fontSize: context.sp(7),
                ),
              ),
              SizedBox(height: context.h(0.02)),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    0,
                    0,
                    context.h(0.02),
                  ),
                  child: isExercise ? _buildExerciseForm() : _buildFoodForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodForm() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(0.05)),
      child: Form(
        key: _foodFormKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _foodNameController,
              label: 'Tên thực phẩm',
              hint: 'Ví dụ: Cơm tấm sườn bì chả',
              validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên' : null,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _caloriesController,
                    label: 'Calories (kcal)',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Yêu cầu' : null,
                  ),
                ),
                SizedBox(width: context.w(0.04)),
                Expanded(
                  child: _buildTextField(
                    controller: _servingSizeController,
                    label: 'Định lượng',
                    hint: '100',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Yêu cầu' : null,
                  ),
                ),
                SizedBox(width: context.w(0.04)),
                Expanded(
                  child: _buildTextField(
                    controller: _servingUnitController,
                    label: 'Đơn vị',
                    hint: 'g',
                    validator: (v) => v!.isEmpty ? 'Yêu cầu' : null,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _proteinController,
                    label: 'Đạm (g)',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Yêu cầu' : null,
                  ),
                ),
                SizedBox(width: context.w(0.04)),
                Expanded(
                  child: _buildTextField(
                    controller: _carbsController,
                    label: 'Carbs (g)',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Yêu cầu' : null,
                  ),
                ),
                SizedBox(width: context.w(0.04)),
                Expanded(
                  child: _buildTextField(
                    controller: _fatController,
                    label: 'Béo (g)',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Yêu cầu' : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(0.03)),
            _buildSubmitButton(_submitFood),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseForm() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(0.05)),
      child: Form(
        key: _exerciseFormKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _exerciseNameController,
              label: 'Tên bài tập',
              hint: 'Ví dụ: Nhảy dây cường độ cao',
              validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên' : null,
            ),
            _buildTextField(
              controller: _metValueController,
              label: 'Giá trị MET (Nếu biết)',
              hint: 'Ví dụ: 8.0',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: context.h(0.03)),
            _buildSubmitButton(_submitExercise),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: context.h(0.005)),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: context.sp(4)),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.sp(3)),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.sp(3)),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.sp(3)),
              borderSide: const BorderSide(color: Color(0xffEBCF23)),
            ),
          ),
        ),
        SizedBox(height: context.h(0.02)),
      ],
    );
  }

  Widget _buildSubmitButton(VoidCallback onPressed) {
    final isLoading = context.watch<ContributionProvider>().isLoading;

    return SizedBox(
      width: double.infinity,
      height: context.h(0.065),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffEBCF23),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.sp(3)),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Gửi yêu cầu',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(5.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
