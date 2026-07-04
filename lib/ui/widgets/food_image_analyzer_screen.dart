import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/data/repositories/chat_repository.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/providers/nutrition_provider.dart';

class FoodImageAnalyzerScreen extends StatefulWidget {
  final File imageFile;

  const FoodImageAnalyzerScreen({super.key, required this.imageFile});

  @override
  State<FoodImageAnalyzerScreen> createState() => _FoodImageAnalyzerScreenState();
}

class _FoodImageAnalyzerScreenState extends State<FoodImageAnalyzerScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _analysisResult;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      final bytes = await widget.imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final creds = await AuthHelper.getCredentials();
      if (creds == null) throw Exception('Chưa đăng nhập');

      final repo = ChatRepository();
      final res = await repo.analyzeFoodImage(base64Image: base64Image, token: creds.token);

      if (res['statusCode'] == 200) {
        final replyText = res['data']['reply']?.toString() ?? '';
        final RegExp jsonRegExp = RegExp(r'\{[\s\S]*\}');
        final match = jsonRegExp.firstMatch(replyText);
        
        if (match != null) {
          final jsonString = match.group(0)!;
          setState(() {
            _analysisResult = jsonDecode(jsonString);
            _isLoading = false;
          });
        } else {
          throw Exception('Hệ thống không nhận diện được thành phần dinh dưỡng. Vui lòng thử chụp lại món ăn rõ hơn nhé!');
        }
      } else {
        throw Exception('Lỗi Server: ${res['statusCode']}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Phân tích Món ăn', style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2D2D2D),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 100),
            
            // Image Preview
            Center(
              child: Container(
                height: 250,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.file(
                    widget.imageFile,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Bottom Sheet Area
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: _isLoading
                    ? Column(
                        children: [
                          const SizedBox(height: 40),
                          const CircularProgressIndicator(color: Color(0xFF34D399)),
                          const SizedBox(height: 24),
                          Text(
                            'AI đang quét và phân tích món ăn...',
                            style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 100),
                        ],
                      )
                    : _errorMessage.isNotEmpty
                        ? Column(
                            children: [
                              const SizedBox(height: 40),
                              const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.baloo2(fontSize: 16, color: Colors.red.shade700, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 100),
                            ],
                          )
                        : _buildResult(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final String foodName = _analysisResult?['food_name'] ?? 'Không rõ món ăn';
    final int totalCalories = _analysisResult?['total_calories'] ?? 0;
    final List<dynamic> ingredients = _analysisResult?['ingredients'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          foodName,
          textAlign: TextAlign.center,
          style: GoogleFonts.baloo2(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D2D2D),
            height: 1.2,
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF34D399).withOpacity(0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF34D399).withOpacity(0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department_rounded, color: Color(0xFF059669), size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Tổng Calo Ước Tính: $totalCalories kcal',
                    style: GoogleFonts.baloo2(fontSize: 16, color: const Color(0xFF059669), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        Text(
          'Thành phần phát hiện được',
          style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF2D2D2D)),
        ),
        const SizedBox(height: 16),
        
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ingredients.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ing = ingredients[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.restaurant_menu_rounded, color: Colors.orange, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ing['name']?.toString() ?? '',
                          style: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2D2D2D)),
                        ),
                        Text(
                          'Khối lượng: ${ing['weight'] ?? 'N/A'}',
                          style: GoogleFonts.baloo2(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${ing['calories']} kcal',
                    style: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.orange),
                  ),
                ],
              ),
            );
          },
        ),
        
        const SizedBox(height: 24),
        _buildGradientButton(
          label: 'Lưu vào Nhật ký Ăn uống',
          icon: Icons.restaurant_rounded,
          gradientColors: const [Color(0xFF34D399), Color(0xFF059669)],
          onPressed: () => _showLogFoodDialog(foodName, totalCalories.toDouble()),
        ),
        const SizedBox(height: 12),
        _buildGradientButton(
          label: 'Nhờ Wello AI tư vấn thêm',
          icon: Icons.auto_awesome,
          gradientColors: const [Color(0xFFFFB72B), Color(0xFFF59E0B)],
          onPressed: () {
            Navigator.pop(context, "Tôi vừa chụp bức ảnh của món $foodName, nó chứa khoảng $totalCalories kcal. Hãy cho tôi biết món này có phù hợp để thêm vào thực đơn giảm cân không?");
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildGradientButton({
    required String label,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback? onPressed,
  }) {
    final bool isDisabled = onPressed == null;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDisabled ? [Colors.grey.shade300, Colors.grey.shade400] : gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDisabled ? null : [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 24),
        label: Text(
          label,
          style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledForegroundColor: Colors.white,
          disabledBackgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  void _showLogFoodDialog(String productName, double totalCalories) {
    final TextEditingController amountController = TextEditingController(text: '100');
    double amount = 100;
    String selectedMeal = 'Bữa sáng';
    final meals = ['Bữa sáng', 'Bữa trưa', 'Bữa tối', 'Bữa nhẹ'];
    bool isSaving = false;
    String? warningMessage;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Lưu Món Ăn',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.baloo2(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2D2D2D)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      productName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.baloo2(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: const Icon(Icons.scale_rounded, color: Color(0xFF10B981)),
                          labelText: 'Khối lượng / Khẩu phần (%)',
                          labelStyle: GoogleFonts.baloo2(color: Colors.grey.shade500),
                        ),
                        style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.bold),
                        onChanged: (val) {
                          amount = double.tryParse(val) ?? 0;
                          setModalState(() {
                            if (amount > 2500) {
                              errorMessage = '⚠️ Lượng nhập quá lớn, không thể lưu!';
                              warningMessage = null;
                            } else if (amount > 1000) {
                              errorMessage = null;
                              warningMessage = 'Cảnh báo: Bạn đang nhập một lượng rất lớn.';
                            } else {
                              errorMessage = null;
                              warningMessage = null;
                            }
                          });
                        },
                      ),
                    ),
                    if (warningMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 8),
                        child: Text(warningMessage!, style: GoogleFonts.baloo2(color: Colors.orange.shade700, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 8),
                        child: Text(errorMessage!, style: GoogleFonts.baloo2(color: Colors.red.shade700, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Chọn bữa ăn:',
                      style: GoogleFonts.baloo2(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: meals.map((m) {
                        final isSelected = selectedMeal == m;
                        IconData mealIcon;
                        if (m == 'Bữa sáng') {
                          mealIcon = Icons.wb_twilight_rounded;
                        } else if (m == 'Bữa trưa') {
                          mealIcon = Icons.wb_sunny_rounded;
                        } else if (m == 'Bữa tối') {
                          mealIcon = Icons.nights_stay_rounded;
                        } else {
                          mealIcon = Icons.coffee_rounded;
                        }
                        
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedMeal = m),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF10B981) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade300,
                                width: 1.5,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                              ] : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(mealIcon, color: isSelected ? Colors.white : Colors.grey.shade500, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  m,
                                  style: GoogleFonts.baloo2(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? Colors.white : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    _buildGradientButton(
                      label: isSaving ? 'Đang lưu...' : 'Xác nhận Lưu',
                      icon: Icons.check_circle_rounded,
                      gradientColors: const [Color(0xFF34D399), Color(0xFF059669)],
                      onPressed: (isSaving || errorMessage != null || amount <= 0) ? null : () async {
                        if (amount <= 0) return;
                        setModalState(() => isSaving = true);
                        try {
                          final creds = await AuthHelper.getCredentials();
                          if (creds == null) throw Exception('Chưa đăng nhập');
                          
                          final provider = Provider.of<NutritionProvider>(context, listen: false);
                          
                          // Lượng calo trả về là tổng calo của món ăn trong ảnh
                          // Tính calo theo tỷ lệ (mặc định 100% món ăn = khối lượng 100%)
                          double ratio = amount / 100.0;
                          
                          String mealTypeEnum = 'BREAKFAST';
                          if (selectedMeal == 'Bữa trưa') mealTypeEnum = 'LUNCH';
                          if (selectedMeal == 'Bữa tối') mealTypeEnum = 'DINNER';
                          if (selectedMeal == 'Bữa nhẹ') mealTypeEnum = 'SNACK';
                          
                          await provider.logFood(
                            token: creds.token,
                            userId: creds.userId,
                            foodId: 0,
                            amountGrams: amount.round(),
                            mealType: mealTypeEnum,
                            foodNameOverride: productName,
                            caloriesOverride: (totalCalories * ratio).round(),
                            proteinOverride: 0,
                            carbsOverride: 0,
                            fatOverride: 0,
                          );
                          
                          if (context.mounted) {
                            Navigator.pop(context); // Đóng bottom sheet
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã lưu món ăn vào nhật ký!'), backgroundColor: Colors.green),
                            );
                            Navigator.pop(context, 'success'); // Đóng luôn màn hình nhận diện
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                          }
                        } finally {
                          if (context.mounted) setModalState(() => isSaving = false);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
