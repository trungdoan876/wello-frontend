import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/domain/providers/nutrition_provider.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import '../../../data/models/responses/survey_response_model.dart';

class WaterCard extends StatelessWidget {
  final SurveyResponseModel survey;
  const WaterCard({super.key, required this.survey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(0.06)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.w(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          // LEFT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${survey.waterIntakeMl ?? ((survey.tdee * 0.92).round())} ml",
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(8),
                    color: Colors.red,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "Lượng nước bạn cần uống",
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffA3A1A1),
                  ),
                ),
                SizedBox(height: context.h(0.03)),
                 // full-width thin divider between BMI and metrics
                  Container(
                    width: double.infinity,
                    height: 1.5,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                SizedBox(height: context.h(0.015)),
                Row(
                  children: [
                    Icon(Icons.access_time, size: context.sp(6), color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      "Lần cuối cùng",
                     style: GoogleFonts.baloo2(
                      fontSize: context.sp(5),
                      color: const Color(0xffA3A1A1),
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.h(0.02)),
                GestureDetector(
                  onTap: () {
                    // Show water reminder settings bottom sheet
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => _WaterReminderSheet(),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active, color: const Color(0xffEBCF23), size: context.sp(6)),
                      SizedBox(width: 4),
                      Text(
                        "Bật tính năng thông báo",
                        style: GoogleFonts.baloo2(
                          color: const Color(0xffEBCF23),
                          fontSize: context.sp(4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          // RIGHT IMAGE
          SizedBox(
            width: context.w(0.25),
            child: Image.asset(
              "assets/images/water.png",
              fit: BoxFit.contain,
            ),
          )
        ],
      ),
    );
  }
}

class _WaterReminderSheet extends StatefulWidget {
  const _WaterReminderSheet({super.key});

  @override
  State<_WaterReminderSheet> createState() => _WaterReminderSheetState();
}

class _WaterReminderSheetState extends State<_WaterReminderSheet> {
  bool _enabled = true;
  int _startHour = 8;
  int _endHour = 22;
  int _intervalHours = 0;
  int _intervalMinutes = 30;

  String get _intervalLabel {
    if (_intervalHours > 0 && _intervalMinutes > 0) {
      return 'Cách mỗi $_intervalHours giờ $_intervalMinutes phút';
    } else if (_intervalHours > 0) {
      return 'Cách mỗi $_intervalHours giờ';
    } else if (_intervalMinutes > 0) {
      return 'Cách mỗi $_intervalMinutes phút';
    }
    return 'Chưa đặt khoảng cách';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nhắc nhở uống nước',
                style: GoogleFonts.baloo2(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEBCF23),
                ),
              ),
              Switch(
                value: _enabled,
                onChanged: (val) => setState(() => _enabled = val),
                activeColor: const Color(0xFFEBCF23),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Ứng dụng sẽ gửi thông báo nhắc bạn uống nước đúng giờ.',
            style: GoogleFonts.baloo2(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 25),
          _buildSettingRow(
            'Bắt đầu nhắc (giờ)',
            'Từ $_startHour:00 sáng',
            _startHour,
            24,
            (val) => setState(() => _startHour = val),
          ),
          const SizedBox(height: 15),
          _buildSettingRow(
            'Kết thúc nhắc (giờ)',
            'Đến $_endHour:00 tối',
            _endHour,
            24,
            (val) => setState(() => _endHour = val),
          ),
          const SizedBox(height: 15),
          _buildSettingRow(
            'Khoảng cách (giờ)',
            '$_intervalHours giờ',
            _intervalHours,
            5,
            (val) => setState(() => _intervalHours = val),
          ),
          const SizedBox(height: 15),
          _buildSettingRow(
            'Khoảng cách (phút)',
            '$_intervalMinutes phút',
            _intervalMinutes,
            59,
            (val) => setState(() => _intervalMinutes = val),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEBCF23).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEBCF23).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  color: const Color(0xFFEBCF23),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _intervalLabel,
                  style: GoogleFonts.baloo2(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final provider = context.read<NutritionProvider>();
                final credentials = await AuthHelper.getCredentials();
                if (credentials != null) {
                  try {
                    await provider.updateWaterReminderSettings(
                      userId: credentials.userId,
                      enabled: _enabled,
                      startHour: _startHour,
                      endHour: _endHour,
                      intervalHours: _intervalHours,
                      intervalMinutes: _intervalMinutes,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã lưu cài đặt nhắc nhở!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lỗi: Không thể lưu cài đặt')),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEBCF23),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Lưu cài đặt',
                style: GoogleFonts.baloo2(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String title, String subtitle, int value, int max, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.baloo2(fontSize: 14, color: Colors.grey.shade500),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subtitle,
              style: GoogleFonts.baloo2(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: value > 0 ? () => onChanged(value - 1) : null,
                ),
                Text(
                  '$value',
                  style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: value < max ? () => onChanged(value + 1) : null,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
