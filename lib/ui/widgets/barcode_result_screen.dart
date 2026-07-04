import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/providers/nutrition_provider.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/data/repositories/chat_repository.dart';
import 'package:quickalert/quickalert.dart';

class BarcodeResultScreen extends StatefulWidget {
  final String barcode;

  const BarcodeResultScreen({super.key, required this.barcode});

  @override
  State<BarcodeResultScreen> createState() => _BarcodeResultScreenState();
}

class _BarcodeResultScreenState extends State<BarcodeResultScreen> {
  bool _isLoading = true;
  bool _isNotFound = false;
  String _errorMessage = '';

  String _productName = '';
  String? _imageUrl;
  double _calories = 0;
  double _protein = 0;
  double _carbs = 0;
  double _fat = 0;
  
  String _productType = ''; // 'food' or 'drink'
  bool _isAIEstimated = false;

  @override
  void initState() {
    super.initState();
    _fetchProductInfo();
  }

  Future<void> _fetchProductInfo() async {
    try {
      final response = await http.get(Uri.parse('https://world.openfoodfacts.org/api/v0/product/${widget.barcode}.json'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1) {
          final product = data['product'];
          final nutriments = product['nutriments'] ?? {};
          
          debugPrint('Nutriments for ${widget.barcode}: $nutriments');
          
          double parseDouble(dynamic value) {
            if (value == null) return 0.0;
            if (value is int) return value.toDouble();
            if (value is double) return value;
            if (value is String) return double.tryParse(value) ?? 0.0;
            return 0.0;
          }

          String getBestProductName(Map<String, dynamic> p) {
            if (p['product_name'] != null && p['product_name'].toString().trim().isNotEmpty) return p['product_name'];
            if (p['product_name_en'] != null && p['product_name_en'].toString().trim().isNotEmpty) return p['product_name_en'];
            if (p['product_name_ja'] != null && p['product_name_ja'].toString().trim().isNotEmpty) return p['product_name_ja'];
            if (p['brands'] != null && p['brands'].toString().trim().isNotEmpty) return p['brands'];
            for (String key in p.keys) {
              if (key.startsWith('product_name_') && p[key] != null && p[key].toString().trim().isNotEmpty) {
                return p[key].toString();
              }
            }
            return 'Sản phẩm không tên';
          }

          setState(() {
            _productName = getBestProductName(product);
            _imageUrl = product['image_url'];
          });
          
          // Always use AI to estimate nutrition, just like the voice assistant
          await _fetchDataFromAI(_productName);
        } else {
          setState(() {
            _isNotFound = true;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Lỗi kết nối Server');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể lấy thông tin sản phẩm: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDataFromAI(String name) async {
    try {
      final creds = await AuthHelper.getCredentials();
      if (creds == null) throw Exception('No token');
      
      final prompt = 'Cho biết thông tin dinh dưỡng trên 100g hoặc 100ml của món "$name". Trả về ĐÚNG 1 chuỗi JSON (không chứa bất kỳ chữ nào khác, không chứa giải thích). Cấu trúc JSON bắt buộc như sau: {"calories": 0.0, "protein": 0.0, "carbs": 0.0, "fat": 0.0, "type": "food"}. Lưu ý: trường "type" chỉ được điền chữ "food" (nếu là thức ăn) hoặc "drink" (nếu là nước uống).';
      
      final chatRepo = ChatRepository();
      final res = await chatRepo.sendMessageToChatbot(message: prompt, token: creds.token);
      
      if (res['statusCode'] == 200) {
        final text = res['data']['reply'] ?? res['data']['bot_response'] ?? res['data']['text'] ?? '';
        debugPrint('AI Response: $text');
        
        final RegExp jsonRegExp = RegExp(r'\{[\s\S]*\}');
        final match = jsonRegExp.firstMatch(text);
        
        if (match != null) {
          final jsonString = match.group(0)!;
          debugPrint('Parsed JSON string: $jsonString');
          final jsonData = jsonDecode(jsonString);
          setState(() {
             _calories = double.tryParse(jsonData['calories'].toString()) ?? 0;
             _protein = double.tryParse(jsonData['protein'].toString()) ?? 0;
             _carbs = double.tryParse(jsonData['carbs'].toString()) ?? 0;
             _fat = double.tryParse(jsonData['fat'].toString()) ?? 0;
             _productType = jsonData['type']?.toString().toLowerCase() ?? 'food';
             _isAIEstimated = true;
          });
        } else {
          debugPrint('No JSON matched in AI response');
        }
      }
    } catch (e) {
      debugPrint('AI Fetch error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _askAI() {
    if (_isNotFound) {
      Navigator.pop(context, "Tôi vừa quét mã vạch ${widget.barcode} nhưng không tìm thấy thông tin. Bạn có biết mã này thuộc sản phẩm gì không?");
    } else {
      String typeStr = _productType == 'drink' ? 'thức uống' : 'món ăn';
      Navigator.pop(context, "Tôi đang định dùng $typeStr có tên là: $_productName (Khoảng ${_calories.toStringAsFixed(0)} kcal / 100g). Dựa vào hồ sơ sức khỏe và mục tiêu hiện tại của tôi, món này có phù hợp không? Nếu có thì tôi nên ăn/uống bao nhiêu là vừa? Nếu không thì bạn có thể gợi ý giải pháp thay thế lành mạnh hơn không?");
    }
  }

  void _showLogFoodDialog() {
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
                      _productName,
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
                          labelText: 'Khối lượng (gram)',
                          labelStyle: GoogleFonts.baloo2(color: Colors.grey.shade500),
                        ),
                        style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.bold),
                        onChanged: (val) {
                          amount = double.tryParse(val) ?? 0;
                          setModalState(() {
                            if (amount > 2500) {
                              errorMessage = '⚠️ Lượng nhập quá lớn (hơn 2.5kg), không thể lưu!';
                              warningMessage = null;
                            } else if (amount > 1000) {
                              errorMessage = null;
                              warningMessage = 'Cảnh báo: Bạn đang nạp một lượng lớn (hơn 1kg).';
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
                            foodNameOverride: _productName,
                            caloriesOverride: (_calories * ratio).round(),
                            proteinOverride: _protein * ratio,
                            carbsOverride: _carbs * ratio,
                            fatOverride: _fat * ratio,
                          );
                          
                          if (context.mounted) {
                            Navigator.pop(context); // Close bottom sheet
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã lưu món ăn vào nhật ký!'), backgroundColor: Colors.green),
                            );
                            Navigator.pop(context, 'success'); // Close Result Screen
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

  void _showLogWaterDialog() {
    final TextEditingController amountController = TextEditingController(text: '250');
    double amount = 250;
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
                      'Lưu Lượng Nước',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.baloo2(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2D2D2D)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _productName,
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
                          icon: const Icon(Icons.water_drop_rounded, color: Color(0xFF3B82F6)),
                          labelText: 'Thể tích (ml)',
                          labelStyle: GoogleFonts.baloo2(color: Colors.grey.shade500),
                        ),
                        style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.bold),
                        onChanged: (val) {
                          amount = double.tryParse(val) ?? 0;
                          setModalState(() {
                            if (amount > 2500) {
                              errorMessage = '⚠️ Thể tích nhập quá lớn (hơn 2.5 lít), không thể lưu!';
                              warningMessage = null;
                            } else if (amount > 1000) {
                              errorMessage = null;
                              warningMessage = 'Cảnh báo: Lượng nước uống 1 lần đang khá nhiều (hơn 1 lít).';
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
                    const SizedBox(height: 32),
                    _buildGradientButton(
                      label: isSaving ? 'Đang lưu...' : 'Xác nhận Lưu',
                      icon: Icons.check_circle_rounded,
                      gradientColors: const [Color(0xFF60A5FA), Color(0xFF2563EB)],
                      onPressed: (isSaving || errorMessage != null || amount <= 0) ? null : () async {
                        if (amount <= 0) return;
                        setModalState(() => isSaving = true);
                        try {
                          final creds = await AuthHelper.getCredentials();
                          if (creds == null) throw Exception('Chưa đăng nhập');
                          
                          final provider = Provider.of<NutritionProvider>(context, listen: false);
                          await provider.addWaterGlass(
                            creds.token,
                            creds.userId.toString(),
                            glassSize: amount.round(),
                          );
                          
                          if (context.mounted) {
                            Navigator.pop(context); // Close bottom sheet
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã cộng thêm nước vào chỉ tiêu!'), backgroundColor: Colors.blue),
                            );
                            Navigator.pop(context, 'success'); // Close Result Screen
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

  Widget _buildNutrimentBox(String title, String value, Color color, IconData iconData) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.baloo2(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.baloo2(fontSize: 18, color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Off-white modern background
      appBar: AppBar(
        title: Text('Chi tiết sản phẩm', style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2D2D2D),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFB72B)))
        : _errorMessage.isNotEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                ),
              )
            : _isNotFound
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Không tìm thấy dữ liệu',
                            style: GoogleFonts.baloo2(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sản phẩm có mã vạch ${widget.barcode} chưa được đăng ký trong hệ thống quốc tế.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.baloo2(fontSize: 16, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _askAI,
                            icon: const Icon(Icons.chat_bubble_rounded),
                            label: const Text('Nhờ AI tư vấn chung'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB72B),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 100), // Clear the transparent AppBar
                        if (_imageUrl != null)
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Hào quang (glowing orb)
                                Container(
                                  height: 200,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFB72B).withOpacity(0.25),
                                        blurRadius: 100,
                                        spreadRadius: 30,
                                      ),
                                    ],
                                  ),
                                ),
                                // Khung ảnh sản phẩm
                                Container(
                                  height: 220,
                                  margin: const EdgeInsets.symmetric(horizontal: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(32),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 24,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: Image.network(
                                      _imageUrl!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 40),
                        
                        // Phần thông tin dạng Bottom Sheet
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Handle bar
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
                                  _productName,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.baloo2(
                                    fontSize: 28, 
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF2D2D2D),
                                    height: 1.2,
                                  ),
                                ),
                                if (_isAIEstimated)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFB72B).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: const Color(0xFFFFB72B).withOpacity(0.4)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.auto_awesome, color: Color(0xFFE59C00), size: 18),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              'Dữ liệu được ước tính bởi Wello AI',
                                              style: GoogleFonts.baloo2(fontSize: 13, color: const Color(0xFFD4921C), fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 40),
                                Text(
                                  'Thành phần dinh dưỡng',
                                  style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF2D2D2D)),
                                ),
                                Text(
                                  'Dựa trên 100g / 100ml',
                                  style: GoogleFonts.baloo2(fontSize: 14, color: Colors.grey.shade500),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(child: _buildNutrimentBox('Calo', '${_calories.toStringAsFixed(1)} kcal', const Color(0xFFFF7A00), Icons.local_fire_department_rounded)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildNutrimentBox('Protein', '${_protein.toStringAsFixed(1)} g', const Color(0xFFFB7185), Icons.fitness_center_rounded)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(child: _buildNutrimentBox('Carbs', '${_carbs.toStringAsFixed(1)} g', const Color(0xFF10B981), Icons.grass_rounded)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildNutrimentBox('Fat', '${_fat.toStringAsFixed(1)} g', const Color(0xFF8B5CF6), Icons.water_drop_rounded)),
                                  ],
                                ),
                                const SizedBox(height: 48),
                                if (_productType == 'food' || _productType.isEmpty)
                                  _buildGradientButton(
                                    label: 'Lưu vào Nhật ký Món ăn',
                                    icon: Icons.restaurant_rounded,
                                    gradientColors: const [Color(0xFF34D399), Color(0xFF059669)],
                                    onPressed: _showLogFoodDialog,
                                  ),
                                if (_productType == 'drink')
                                  _buildGradientButton(
                                    label: 'Lưu vào Lượng nước',
                                    icon: Icons.water_drop_rounded,
                                    gradientColors: const [Color(0xFF60A5FA), Color(0xFF2563EB)],
                                    onPressed: _showLogWaterDialog,
                                  ),
                                const SizedBox(height: 16),
                                _buildGradientButton(
                                  label: 'Nhờ Wello AI tư vấn',
                                  icon: Icons.auto_awesome,
                                  gradientColors: const [Color(0xFFFFD166), Color(0xFFFFB72B)],
                                  onPressed: _askAI,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
    );
  }
}
