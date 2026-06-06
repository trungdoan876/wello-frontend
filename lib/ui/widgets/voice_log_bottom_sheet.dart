import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/data/models/responses/ai_parse_meal_response.dart';
import 'package:wello_frontend/data/repositories/ai_repository.dart';
import 'package:wello_frontend/domain/providers/nutrition_provider.dart';
import 'package:wello_frontend/domain/repositories/food_repository.dart';
import 'package:wello_frontend/data/repositories/food_repository_impl.dart';
import 'package:wello_frontend/data/data_source/food_remote_data_source.dart';
import 'package:wello_frontend/domain/entities/food.dart';

class VoiceLogBottomSheet extends StatefulWidget {
  const VoiceLogBottomSheet({super.key});

  @override
  State<VoiceLogBottomSheet> createState() => _VoiceLogBottomSheetState();
}

enum VoiceLogState {
  initializing,
  listening,
  analyzing,
  confirming,
  error,
  success
}

class _VoiceLogBottomSheetState extends State<VoiceLogBottomSheet>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  final AiRepository _aiRepository = AiRepository();
  final FoodRepository _foodRepository = FoodRepositoryImpl(remoteDataSource: FoodRemoteDataSource());
  
  VoiceLogState _currentState = VoiceLogState.initializing;
  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _soundLevel = 0.0;
  String _errorMessage = "";
  
  AiParseMealResponse? _aiResult;
  final List<bool> _expandedFoods = [];
  bool _isLogging = false;

  final TextEditingController _textFallbackController = TextEditingController();
  bool _showTextFallback = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _speechToText.stop();
    _textFallbackController.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (val) {
          print('SpeechToText onError: $val');
          // If error is permission or no speech, handle gracefully
          setState(() {
            _currentState = VoiceLogState.listening; // allow manual input fallback
          });
        },
        onStatus: (val) {
          print('SpeechToText onStatus: $val');
          if (val == 'done' || val == 'notListening') {
            if (_wordsSpoken.isNotEmpty && _currentState == VoiceLogState.listening) {
              _startAnalysis();
            }
          }
        },
      );
      
      if (mounted) {
        setState(() {
          if (_speechEnabled) {
            _currentState = VoiceLogState.listening;
            _startListening();
          } else {
            // Speech not available, fallback to text input automatically
            _currentState = VoiceLogState.listening;
            _showTextFallback = true;
          }
        });
      }
    } catch (e) {
      print('SpeechToText init exception: $e');
      if (mounted) {
        setState(() {
          _currentState = VoiceLogState.listening;
          _showTextFallback = true;
        });
      }
    }
  }

  void _startListening() async {
    if (!_speechEnabled) return;
    
    setState(() {
      _wordsSpoken = "";
      _soundLevel = 0.0;
      _currentState = VoiceLogState.listening;
    });

    try {
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _wordsSpoken = result.recognizedWords;
          });
        },
        localeId: 'vi_VN',
        listenFor: const Duration(seconds: 20),
        pauseFor: const Duration(seconds: 4),
        onSoundLevelChange: (level) {
          setState(() {
            _soundLevel = level;
          });
        },
      );
    } catch (e) {
      print('SpeechToText listen exception: $e');
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    if (_wordsSpoken.isNotEmpty) {
      _startAnalysis();
    }
  }

  Future<void> _startAnalysis() async {
    final queryText = _showTextFallback 
        ? _textFallbackController.text.trim() 
        : _wordsSpoken.trim();

    if (queryText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập hoặc nói gì đó!')),
      );
      return;
    }

    setState(() {
      _currentState = VoiceLogState.analyzing;
    });

    try {
      final nutritionProvider = context.read<NutritionProvider>();
      final credentials = await AuthHelper.getCredentials();
      if (credentials == null) {
        throw Exception('Chưa đăng nhập. Vui lòng đăng nhập lại.');
      }

      final dateStr = nutritionProvider.selectedDate;

      final result = await _aiRepository.parseMeal(
        text: queryText,
        date: dateStr,
        token: credentials.token,
      );

      if (mounted) {
        setState(() {
          _aiResult = result;
          _expandedFoods.clear();
          _expandedFoods.addAll(List.generate(result.parsedFoods.length, (index) => index == 0)); // Expand the first food by default
          _currentState = VoiceLogState.confirming;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _currentState = VoiceLogState.error;
        });
      }
    }
  }

  Future<void> _confirmLogFoods() async {
    if (_aiResult == null || _aiResult!.parsedFoods.isEmpty) return;

    setState(() {
      _isLogging = true;
    });

    try {
      final nutritionProvider = context.read<NutritionProvider>();
      final credentials = await AuthHelper.getCredentials();
      if (credentials == null) throw Exception('Chưa đăng nhập');

      // Loop through all parsed foods and log them
      for (final food in _aiResult!.parsedFoods) {
        // Map LUNCH/BREAKFAST etc to Vietnamese strings expected by the backend
        String mealTypeVi = 'Bữa nhẹ';
        if (food.mealType == 'BREAKFAST') {
          mealTypeVi = 'Bữa sáng';
        } else if (food.mealType == 'LUNCH') {
          mealTypeVi = 'Bữa trưa';
        } else if (food.mealType == 'DINNER') {
          mealTypeVi = 'Bữa tối';
        } else if (food.mealType == 'SNACK') {
          mealTypeVi = 'Bữa phụ';
        }

        await nutritionProvider.logFood(
          token: credentials.token,
          userId: credentials.userId,
          foodId: food.foodId,
          amountGrams: food.amountGrams,
          mealType: mealTypeVi,
          caloriesOverride: food.foodId == 0 ? food.calories : null,
          foodNameOverride: food.foodId == 0 ? food.foodName : null,
          proteinOverride: food.foodId == 0 ? food.protein : null,
          carbsOverride: food.foodId == 0 ? food.carbs : null,
          fatOverride: food.foodId == 0 ? food.fat : null,
        );
      }

      if (mounted) {
        setState(() {
          _currentState = VoiceLogState.success;
          _isLogging = false;
        });
        
        // Wait a brief moment to show success checkmark before closing
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi lưu thực phẩm: $e';
          _currentState = VoiceLogState.error;
          _isLogging = false;
        });
      }
    }
  }

  void _showMealTypeSelector(int index, ParsedFood food) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Chọn loại bữa ăn',
                  style: GoogleFonts.baloo2(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
              ),
              const Divider(height: 1),
              _buildMealTypeOption(index, food, 'BREAKFAST', 'Bữa sáng'),
              _buildMealTypeOption(index, food, 'LUNCH', 'Bữa trưa'),
              _buildMealTypeOption(index, food, 'DINNER', 'Bữa tối'),
              _buildMealTypeOption(index, food, 'SNACK', 'Bữa phụ'),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealTypeOption(int index, ParsedFood food, String type, String label) {
    final isSelected = food.mealType == type;
    return ListTile(
      leading: Icon(
        _getMealIcon(type),
        color: _getMealColor(type),
      ),
      title: Text(
        label,
        style: GoogleFonts.baloo2(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? _getMealColor(type) : const Color(0xFF2D2D2D),
        ),
      ),
      trailing: isSelected ? Icon(Icons.check_circle, color: _getMealColor(type)) : null,
      onTap: () {
        setState(() {
          food.mealType = type;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showWeightInputDialog(int index, ParsedFood food) {
    final controller = TextEditingController(text: food.amountGrams.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Nhập khối lượng (g)',
            style: GoogleFonts.baloo2(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              suffixText: 'g',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: GoogleFonts.baloo2(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEBCF23),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final input = controller.text.trim();
                final newWeight = int.tryParse(input);
                if (newWeight == null || newWeight <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập khối lượng hợp lệ!')),
                  );
                  return;
                }
                Navigator.pop(context);
                
                setState(() {
                  _currentState = VoiceLogState.analyzing;
                });
                
                try {
                  final credentials = await AuthHelper.getCredentials();
                  if (credentials == null) throw Exception('Chưa đăng nhập');
                  
                  if (food.matchedFromDb) {
                    final previewed = await _foodRepository.previewFood(
                      credentials.token,
                      food.foodId,
                      newWeight,
                    );
                    
                    setState(() {
                      food.amountGrams = newWeight;
                      food.calories = previewed.calories;
                      food.protein = previewed.protein;
                      food.carbs = previewed.carbs;
                      food.fat = previewed.fat;
                      _currentState = VoiceLogState.confirming;
                    });
                  } else {
                    final double ratio = newWeight / food.amountGrams;
                    setState(() {
                      food.amountGrams = newWeight;
                      food.calories = (food.calories * ratio).round();
                      food.protein = food.protein * ratio;
                      food.carbs = food.carbs * ratio;
                      food.fat = food.fat * ratio;
                      _currentState = VoiceLogState.confirming;
                    });
                  }
                } catch (e) {
                  setState(() {
                    _errorMessage = 'Lỗi cập nhật khối lượng: $e';
                    _currentState = VoiceLogState.error;
                  });
                }
              },
              child: Text(
                'Cập nhật',
                style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFoodSearchDialog(int index, ParsedFood food) {
    showDialog(
      context: context,
      builder: (context) {
        return _FoodSearchDialog(
          foodRepository: _foodRepository,
          currentAmountGrams: food.amountGrams,
          onFoodSelected: (selectedFood, previewedFood) {
            setState(() {
              food.foodName = selectedFood.name;
              food.foodId = selectedFood.id;
              food.matchedFromDb = true;
              food.calories = previewedFood.calories;
              food.protein = previewedFood.protein;
              food.carbs = previewedFood.carbs;
              food.fat = previewedFood.fat;
            });
          },
        );
      },
    );
  }

  void _recalculateParentFromIngredients(ParsedFood parent, double originalTotalWeight) {
    if (parent.ingredients.isEmpty) return;

    int newTotalWeight = parent.ingredients.fold(0, (sum, ing) => sum + ing.weightGrams);
    int newTotalCalories = parent.ingredients.fold(0, (sum, ing) => sum + ing.calories);

    if (originalTotalWeight > 0) {
      double ratio = newTotalWeight / originalTotalWeight;
      parent.protein = parent.protein * ratio;
      parent.carbs = parent.carbs * ratio;
      parent.fat = parent.fat * ratio;
    }

    parent.amountGrams = newTotalWeight;
    parent.calories = newTotalCalories;
    parent.foodId = 0;
    parent.matchedFromDb = false;
  }

  void _showIngredientWeightDialog(ParsedFood parent, IngredientInfo ingredient) {
    final controller = TextEditingController(text: ingredient.weightGrams.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Sửa khối lượng nguyên liệu',
            style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, color: const Color(0xFF2D2D2D)),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: GoogleFonts.baloo2(fontSize: 15),
            decoration: InputDecoration(
              labelText: ingredient.name,
              labelStyle: GoogleFonts.baloo2(color: Colors.grey[600]),
              suffixText: 'g',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: GoogleFonts.baloo2(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEBCF23),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final input = controller.text.trim();
                final newWeight = int.tryParse(input);
                if (newWeight == null || newWeight <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập khối lượng hợp lệ!')),
                  );
                  return;
                }
                Navigator.pop(context);

                setState(() {
                  _currentState = VoiceLogState.analyzing;
                });

                try {
                  final credentials = await AuthHelper.getCredentials();
                  if (credentials == null) throw Exception('Chưa đăng nhập');

                  int oldWeight = ingredient.weightGrams;
                  double originalTotalWeight = parent.amountGrams.toDouble();

                  if (ingredient.matchedFromDb) {
                    final previewed = await _foodRepository.previewFood(
                      credentials.token,
                      ingredient.foodId,
                      newWeight,
                    );
                    setState(() {
                      ingredient.weightGrams = newWeight;
                      ingredient.calories = previewed.calories;
                      _recalculateParentFromIngredients(parent, originalTotalWeight);
                      _currentState = VoiceLogState.confirming;
                    });
                  } else {
                    double ratio = newWeight / oldWeight;
                    setState(() {
                      ingredient.weightGrams = newWeight;
                      ingredient.calories = (ingredient.calories * ratio).round();
                      _recalculateParentFromIngredients(parent, originalTotalWeight);
                      _currentState = VoiceLogState.confirming;
                    });
                  }
                } catch (e) {
                  setState(() {
                    _errorMessage = 'Lỗi cập nhật nguyên liệu: $e';
                    _currentState = VoiceLogState.error;
                  });
                }
              },
              child: Text(
                'Cập nhật',
                style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showIngredientSearchDialog(ParsedFood parent, IngredientInfo ingredient) {
    showDialog(
      context: context,
      builder: (context) {
        return _FoodSearchDialog(
          foodRepository: _foodRepository,
          currentAmountGrams: ingredient.weightGrams,
          onFoodSelected: (selectedFood, previewedFood) {
            double originalTotalWeight = parent.amountGrams.toDouble();
            setState(() {
              ingredient.name = selectedFood.name;
              ingredient.foodId = selectedFood.id;
              ingredient.matchedFromDb = true;
              ingredient.calories = previewedFood.calories;
              _recalculateParentFromIngredients(parent, originalTotalWeight);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentState) {
      case VoiceLogState.initializing:
        return _buildInitializing();
      case VoiceLogState.listening:
        return _buildListening();
      case VoiceLogState.analyzing:
        return _buildAnalyzing();
      case VoiceLogState.confirming:
        return _buildConfirming();
      case VoiceLogState.error:
        return _buildError();
      case VoiceLogState.success:
        return _buildSuccess();
    }
  }

  Widget _buildInitializing() {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFFEBCF23)),
            const SizedBox(height: 16),
            Text(
              'Đang khởi động micro...',
              style: GoogleFonts.baloo2(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListening() {
    final bool isRecording = _speechToText.isListening;
    
    return Column(
      children: [
        Text(
          isRecording ? 'Đang lắng nghe...' : 'Sẵn sàng ghi âm',
          style: GoogleFonts.baloo2(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hãy nói những món bạn đã ăn hôm nay.\nVí dụ: "Sáng nay ăn cơm tấm, trưa ăn phở bò"',
          textAlign: TextAlign.center,
          style: GoogleFonts.baloo2(fontSize: 13, color: Colors.grey[500]),
        ),
        const SizedBox(height: 24),
        
        if (_showTextFallback) ...[
          // Manual typing input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _textFallbackController,
              maxLines: 3,
              style: GoogleFonts.baloo2(fontSize: 15),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Nhập món ăn của bạn...',
                hintStyle: GoogleFonts.baloo2(color: Colors.grey[400]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_speechEnabled)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showTextFallback = false;
                    });
                    _startListening();
                  },
                  icon: const Icon(Icons.mic, color: Color(0xFFEBCF23)),
                  label: Text('Dùng giọng nói', style: GoogleFonts.baloo2(color: const Color(0xFF2D2D2D))),
                ),
              ElevatedButton(
                onPressed: _startAnalysis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEBCF23),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                child: Text('Phân tích', style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ],
          ),
        ] else ...[
          // Voice waves
          SizedBox(
            height: 70,
            child: Center(
              child: isRecording
                  ? _buildVoiceWave()
                  : Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.mic_none_rounded, color: Colors.grey[400], size: 28),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Word preview
          if (_wordsSpoken.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBE6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFF1B8)),
              ),
              child: Text(
                _wordsSpoken,
                style: GoogleFonts.baloo2(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFFD4A000),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: isRecording ? _stopListening : _startListening,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF8BD17), Color(0xFFEBCF23)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEBCF23).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    isRecording ? Icons.stop_rounded : Icons.mic,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 32),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showTextFallback = true;
                  });
                },
                child: Text(
                  'Nhập bằng tay',
                  style: GoogleFonts.baloo2(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildVoiceWave() {
    // A simple visual sound level feedback
    double value = (_soundLevel.clamp(-2.0, 10.0) + 2.0) / 12.0; // scale to 0..1
    double heightMultiplier = 10 + (value * 40);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (index) {
        // Different heights for bars to simulate wave
        double factor = [0.4, 0.7, 1.0, 0.8, 0.6, 0.9, 0.3][index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 6,
          height: heightMultiplier * factor,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF8BD17), Color(0xFFEBCF23)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget _buildAnalyzing() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: Color(0xFFEBCF23),
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'AI đang phân tích thực phẩm...',
              style: GoogleFonts.baloo2(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đang tính toán calo và nguyên liệu con',
              style: GoogleFonts.baloo2(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirming() {
    if (_aiResult == null || _aiResult!.parsedFoods.isEmpty) {
      return Column(
        children: [
          const Icon(Icons.info_outline, size: 48, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy món ăn nào',
            style: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() => _currentState = VoiceLogState.listening),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEBCF23)),
            child: Text('Thử lại', style: GoogleFonts.baloo2(color: Colors.black)),
          ),
        ],
      );
    }

    String cleanedMessage = _aiResult!.aiMessage.trim();
    final regex = RegExp(r'^(dạ,\s*|dạ\s+)', caseSensitive: false);
    if (regex.hasMatch(cleanedMessage)) {
      cleanedMessage = cleanedMessage.replaceFirst(regex, '');
      if (cleanedMessage.isNotEmpty) {
        cleanedMessage = cleanedMessage[0].toUpperCase() + cleanedMessage.substring(1);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Xác nhận món ăn',
              style: GoogleFonts.baloo2(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _currentState = VoiceLogState.listening),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.replay, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Ghi lại', style: GoogleFonts.baloo2(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          cleanedMessage,
          style: GoogleFonts.baloo2(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        // Scrollable list of parsed foods
        Container(
          constraints: const BoxConstraints(maxHeight: 320),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: _aiResult!.parsedFoods.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final food = _aiResult!.parsedFoods[idx];
              final isExpanded = _expandedFoods[idx];
              final String mealNameVi = _translateMealType(food.mealType);

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    // Card Header
                    InkWell(
                      onTap: food.ingredients.isEmpty
                          ? null
                          : () {
                              setState(() {
                                _expandedFoods[idx] = !isExpanded;
                              });
                            },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: [
                            // Meal icon/badge
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getMealColor(food.mealType).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getMealIcon(food.mealType),
                                color: _getMealColor(food.mealType),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Food name & meal type
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    food.foodName,
                                    style: GoogleFonts.baloo2(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2D2D2D),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            // Meal type selector chip
                                            GestureDetector(
                                              onTap: () => _showMealTypeSelector(idx, food),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _getMealColor(food.mealType).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(_getMealIcon(food.mealType), size: 10, color: _getMealColor(food.mealType)),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      mealNameVi,
                                                      style: GoogleFonts.baloo2(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: _getMealColor(food.mealType),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Icon(Icons.arrow_drop_down, size: 12, color: _getMealColor(food.mealType)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            
                                            // Weight editor chip
                                            GestureDetector(
                                              onTap: () => _showWeightInputDialog(idx, food),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '${food.amountGrams}g',
                                                      style: GoogleFonts.baloo2(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 2),
                                                    const Icon(Icons.edit, size: 8, color: Colors.grey),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            
                                            // Matched vs AI estimated badge
                                            GestureDetector(
                                              onTap: () => _showFoodSearchDialog(idx, food),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: food.matchedFromDb 
                                                      ? Colors.green[50] 
                                                      : Colors.orange[50],
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: food.matchedFromDb 
                                                        ? Colors.green[200]! 
                                                        : Colors.orange[200]!,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      food.matchedFromDb ? Icons.link_off_rounded : Icons.link_rounded,
                                                      size: 10,
                                                      color: food.matchedFromDb ? Colors.green[700] : Colors.orange[700],
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      food.matchedFromDb ? 'Hệ thống' : 'AI đề xuất',
                                                      style: GoogleFonts.baloo2(
                                                        fontSize: 9,
                                                        fontWeight: FontWeight.bold,
                                                        color: food.matchedFromDb 
                                                            ? Colors.green[700] 
                                                            : Colors.orange[700],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Calories
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${food.calories}',
                                  style: GoogleFonts.baloo2(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xffEBCF23),
                                  ),
                                ),
                                Text(
                                  'kcal',
                                  style: GoogleFonts.baloo2(
                                    fontSize: 11,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                            if (food.ingredients.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Icon(
                                isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                color: Colors.grey,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Expandable ingredients details
                    if (isExpanded && food.ingredients.isNotEmpty) ...[
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Phân rã nguyên liệu con:',
                              style: GoogleFonts.baloo2(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...food.ingredients.map((ing) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                children: [
                                  // Bullet & Name
                                  Expanded(
                                    child: Text(
                                      '• ${ing.name}',
                                      style: GoogleFonts.baloo2(
                                        fontSize: 13,
                                        color: const Color(0xFF2D2D2D),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Interactive Chips & Calories
                                  Wrap(
                                    spacing: 6,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      // Label (AI vs DB)
                                      GestureDetector(
                                        onTap: () => _showIngredientSearchDialog(food, ing),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: ing.matchedFromDb ? Colors.green[50] : Colors.orange[50],
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: ing.matchedFromDb ? Colors.green[200]! : Colors.orange[200]!,
                                            ),
                                          ),
                                          child: Text(
                                            ing.matchedFromDb ? 'Hệ thống' : 'AI',
                                            style: GoogleFonts.baloo2(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: ing.matchedFromDb ? Colors.green[700] : Colors.orange[700],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Weight Editor
                                      GestureDetector(
                                        onTap: () => _showIngredientWeightDialog(food, ing),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${ing.weightGrams}g',
                                                style: GoogleFonts.baloo2(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              const Icon(Icons.edit, size: 8, color: Colors.grey),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Calories
                                      Text(
                                        '${ing.calories} kcal',
                                        style: GoogleFonts.baloo2(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                            const SizedBox(height: 10),
                            // Macros summary row
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildMacroInfo('Tinh bột', '${food.carbs.toStringAsFixed(1)}g'),
                                  _buildMacroInfo('Đạm', '${food.protein.toStringAsFixed(1)}g'),
                                  _buildMacroInfo('Chất béo', '${food.fat.toStringAsFixed(1)}g'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLogging ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Hủy',
                  style: GoogleFonts.baloo2(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLogging ? null : _confirmLogFoods,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEBCF23),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 2,
                ),
                child: _isLogging
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        'Thêm vào nhật kí',
                        style: GoogleFonts.baloo2(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.baloo2(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 54, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Phân tích thất bại',
              style: GoogleFonts.baloo2(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.baloo2(fontSize: 13, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentState = VoiceLogState.listening;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEBCF23),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text('Thử lại', style: GoogleFonts.baloo2(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 64,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ghi nhật ký thành công!',
              style: GoogleFonts.baloo2(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chỉ số dinh dưỡng đã được cập nhật',
              style: GoogleFonts.baloo2(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  String _translateMealType(String type) {
    switch (type) {
      case 'BREAKFAST':
        return 'Bữa sáng';
      case 'LUNCH':
        return 'Bữa trưa';
      case 'DINNER':
        return 'Bữa tối';
      case 'SNACK':
      default:
        return 'Bữa phụ';
    }
  }

  IconData _getMealIcon(String type) {
    switch (type) {
      case 'BREAKFAST':
        return Icons.bakery_dining_rounded;
      case 'LUNCH':
        return Icons.rice_bowl_rounded;
      case 'DINNER':
        return Icons.dinner_dining_rounded;
      case 'SNACK':
      default:
        return Icons.fastfood_rounded;
    }
  }

  Color _getMealColor(String type) {
    switch (type) {
      case 'BREAKFAST':
        return const Color(0xFFFF4DAA);
      case 'LUNCH':
        return const Color(0xFFB76DF1);
      case 'DINNER':
        return const Color(0xFF41C784);
      case 'SNACK':
      default:
        return const Color(0xFF5CA7FF);
    }
  }
}

class _FoodSearchDialog extends StatefulWidget {
  final FoodRepository foodRepository;
  final int currentAmountGrams;
  final Function(Food selectedFood, Food previewedFood) onFoodSelected;

  const _FoodSearchDialog({
    required this.foodRepository,
    required this.currentAmountGrams,
    required this.onFoodSelected,
  });

  @override
  State<_FoodSearchDialog> createState() => _FoodSearchDialogState();
}

class _FoodSearchDialogState extends State<_FoodSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Food> _searchResults = [];
  bool _isSearching = false;
  String _searchError = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = "";
    });

    try {
      final credentials = await AuthHelper.getCredentials();
      if (credentials == null) throw Exception('Chưa đăng nhập');

      final results = await widget.foodRepository.searchFoods(
        credentials.token,
        query,
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchError = e.toString().replaceFirst('Exception: ', '');
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Khớp món hệ thống',
        style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, color: const Color(0xFF2D2D2D)),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 350,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              style: GoogleFonts.baloo2(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Nhập tên món ăn cần tìm...',
                hintStyle: GoogleFonts.baloo2(color: Colors.grey[400]),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFFEBCF23)),
                  onPressed: _performSearch,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFEBCF23)))
                  : _searchError.isNotEmpty
                      ? Center(child: Text(_searchError, style: GoogleFonts.baloo2(color: Colors.red)))
                      : _searchResults.isEmpty
                          ? Center(
                              child: Text(
                                'Nhập từ khóa và bấm tìm kiếm',
                                style: GoogleFonts.baloo2(color: Colors.grey),
                              ),
                            )
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              itemCount: _searchResults.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final dbFood = _searchResults[index];
                                return ListTile(
                                  title: Text(
                                    dbFood.name,
                                    style: GoogleFonts.baloo2(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2D2D2D),
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${dbFood.calories} kcal/100g',
                                    style: GoogleFonts.baloo2(fontSize: 12, color: Colors.grey[500]),
                                  ),
                                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                                  onTap: () async {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => const Center(
                                        child: CircularProgressIndicator(color: Color(0xFFEBCF23)),
                                      ),
                                    );

                                    try {
                                      final credentials = await AuthHelper.getCredentials();
                                      if (credentials == null) throw Exception('Chưa đăng nhập');

                                      final previewed = await widget.foodRepository.previewFood(
                                        credentials.token,
                                        dbFood.id,
                                        widget.currentAmountGrams,
                                      );

                                      if (!mounted) return;
                                      Navigator.pop(context); // Pop loading spinner
                                      widget.onFoodSelected(dbFood, previewed);
                                      Navigator.pop(context); // Close search dialog
                                    } catch (e) {
                                      if (!mounted) return;
                                      Navigator.pop(context); // Pop loading spinner
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Lỗi khi lấy thông tin món ăn: $e')),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Đóng', style: GoogleFonts.baloo2(color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
