import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wello_frontend/core/utils/user_session.dart';
import 'package:wello_frontend/data/repositories/profile_repository.dart';
import 'package:wello_frontend/domain/providers/profile_provider.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/ui/widgets/quick_actions_overlay.dart';
import 'widgets/water_tracking_card.dart';
import 'package:wello_frontend/ui/summary/widgets/bmi_card.dart';

class ProfileScreen extends StatefulWidget {
  final Function(bool)? onQuickActionsChanged;

  const ProfileScreen({super.key, this.onQuickActionsChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int goal = 1950;
  int current = 500; // ml đã uống
  bool notif = false;
  String lastTime = "16:30";
  bool _showQuickActions = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  int? _userId;

  @override
  void initState() {
    super.initState();
    // Load user ID from SharedPreferences
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final userId = await UserSession.getUserId();
    setState(() {
      _userId = userId ?? 1; // Default to 1 if not found
    });
  }

  void _setQuickActionsVisible(bool show) {
    setState(() => _showQuickActions = show);
    widget.onQuickActionsChanged?.call(show);
  }

  void _handleQuickAction(String key) {
    _setQuickActionsVisible(false);
    // TODO: điều hướng theo key
  }

  void _increase() {
    setState(() {
      current = (current + 200).clamp(0, goal);
    });
  }

  void _decrease() {
    setState(() {
      current = (current - 200).clamp(0, goal);
    });
  }

  void _toggleNotif() {
    setState(() => notif = !notif);
  }

  Future<void> _showImageSourceDialog() async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.h(0.02),
              horizontal: context.w(0.04),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chọn ảnh đại diện',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(7),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4C494C),
                  ),
                ),
                SizedBox(height: context.h(0.02)),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFFEBCF23),
                    size: 30,
                  ),
                  title: Text(
                    'Chụp ảnh',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Color(0xFFEBCF23),
                    size: 30,
                  ),
                  title: Text(
                    'Chọn từ thư viện',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                SizedBox(height: context.h(0.01)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        setState(() {
          _profileImage = imageFile;
        });

        // Upload avatar after picking
        if (_userId != null && mounted) {
          _uploadAvatar(imageFile);
        }
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadAvatar(File imageFile) async {
    try {
      // Use repository directly instead of provider to avoid context issues
      final repository = ProfileRepository();

      final success = await repository.uploadAvatar(
        userId: _userId!,
        imageFile: imageFile,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật ảnh đại diện thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          // Reload profile to get updated avatar URL
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải ảnh lên: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: context.sp(6),
          color: const Color.fromARGB(255, 141, 140, 140),
        ),
        SizedBox(width: context.w(0.012)),
        Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(5),
            fontWeight: FontWeight.w800,
            color: const Color.fromARGB(255, 133, 132, 132),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(BuildContext context) {
    return Container(
      width: 1,
      height: context.h(0.035),
      color: const Color(0xFFE0E0E0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    final double navHeight = _showQuickActions ? 0 : context.h(0.05);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7DA),
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, profileProvider, _) {
            // Load profile data on first build (only if userId is loaded)
            if (_userId != null &&
                !profileProvider.hasData &&
                !profileProvider.isLoading &&
                profileProvider.errorMessage == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                profileProvider.loadProfile(_userId!);
              });
            }

            // Show loading state while waiting for userId or API
            if (_userId == null || profileProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFFEBCF23),
                ),
              );
            }

            // Show error state
            if (profileProvider.hasError && !profileProvider.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: context.h(0.02)),
                    Text(
                      'Có lỗi xảy ra',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(6),
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: context.h(0.02)),
                    ElevatedButton(
                      onPressed: () => profileProvider.retry(_userId!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEBCF23),
                      ),
                      child: Text(
                        'Thử lại',
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(5),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final profileData = profileProvider.profileData;

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(0.04)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: context.h(0.02)),

                        Text(
                          'Hồ sơ cá nhân',
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(8),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFEBCF23),
                          ),
                        ),

                        SizedBox(height: context.h(0.02)),

                        // Profile avatar with camera icon
                        GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: Stack(
                            children: [
                              Container(
                                width: context.w(0.2),
                                height: context.w(0.2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                    width: 2,
                                  ),
                                  image: _profileImage != null
                                      ? DecorationImage(
                                          image: FileImage(_profileImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : (profileData?.avatarUrl != null
                                            ? DecorationImage(
                                                image:
                                                    profileData!.avatarUrl!
                                                        .startsWith(
                                                          'data:image',
                                                        )
                                                    ? MemoryImage(
                                                        base64Decode(
                                                          profileData.avatarUrl!
                                                              .split(',')
                                                              .last,
                                                        ),
                                                      )
                                                    : NetworkImage(
                                                            profileData
                                                                .avatarUrl!,
                                                          )
                                                          as ImageProvider,
                                                fit: BoxFit.cover,
                                              )
                                            : null),
                                ),
                                child:
                                    _profileImage == null &&
                                        profileData?.avatarUrl == null
                                    ? Icon(
                                        Icons.person,
                                        size: context.w(0.12),
                                        color: const Color(0xFFBDBDBD),
                                      )
                                    : null,
                              ),

                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: EdgeInsets.all(context.w(0.015)),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEBCF23),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: context.w(0.04),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: context.h(0.01)),
                        // Profile name
                        if (profileData != null)
                          Text(
                            profileData.fullname,
                            style: GoogleFonts.baloo2(
                              fontSize: context.sp(7),
                              fontWeight: FontWeight.w800,
                              color: const Color.fromARGB(255, 98, 97, 98),
                            ),
                          ),

                        SizedBox(height: context.h(0.015)),
                        // Stats row (Age, Height, Weight) in one card with thin dividers
                        if (profileData != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.w(0.04),
                              vertical: context.h(0.02),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color.fromARGB(255, 187, 187, 187),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatItem(
                                  context,
                                  Icons.calendar_month_outlined,
                                  '${profileData.age} tuổi',
                                ),
                                _buildStatDivider(context),
                                _buildStatItem(
                                  context,
                                  Icons.emoji_people,
                                  '${profileData.height} cm',
                                ),
                                _buildStatDivider(context),
                                _buildStatItem(
                                  context,
                                  Icons.monitor_weight_outlined,
                                  '${profileData.weight.toStringAsFixed(0)} kg',
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: context.h(0.02)),

                        // Physical profile button
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Navigate to physical profile
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFE066),
                            padding: EdgeInsets.symmetric(
                              horizontal: context.w(0.25),
                              vertical: context.h(0.015),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Hồ sơ thể chất',
                            style: GoogleFonts.baloo2(
                              fontSize: context.sp(6),
                              fontWeight: FontWeight.w600,
                              color: const Color.fromARGB(255, 93, 90, 93),
                            ),
                          ),
                        ),

                        SizedBox(height: context.h(0.03)),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Chỉ số cơ thể',
                            style: GoogleFonts.baloo2(
                              fontSize: context.sp(7),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4C494C),
                            ),
                          ),
                        ),

                        SizedBox(height: context.h(0.015)),
                        //const BMICard(),

                        //const BMICard(),
                        SizedBox(height: context.h(0.03)),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Bạn nên uống bao nhiêu nước',
                            style: GoogleFonts.baloo2(
                              fontSize: context.sp(6),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4C494C),
                            ),
                          ),
                        ),

                        SizedBox(height: context.h(0.015)),

                        WaterTrackingCard(
                          amount: current,
                          goal: goal,
                          lastTime: lastTime,
                          isNotificationOn: notif,
                          onIncrease: _increase,
                          onDecrease: _decrease,
                          onToggleNotification: _toggleNotif,
                        ),
                        SizedBox(height: navHeight + context.h(0.05)),
                      ],
                    ),
                  ),
                ),
                // Lớp phủ mờ khi mở quick actions
                if (_showQuickActions)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _setQuickActionsVisible(false),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: 0.45,
                        child: Container(color: Colors.black),
                      ),
                    ),
                  ),
                // Panel quick actions + nút dấu cộng
                Positioned(
                  right: context.w(0.05),
                  bottom: _showQuickActions
                      ? context.h(0.015)
                      : navHeight + context.h(0.01),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AnimatedSlide(
                        offset: _showQuickActions
                            ? const Offset(0, 0)
                            : const Offset(0, 0.2),
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _showQuickActions ? 1 : 0,
                          child: QuickActionsPanel(
                            onAction: _handleQuickAction,
                          ),
                        ),
                      ),
                      SizedBox(height: context.h(0.012)),
                      PlusBubble(
                        onTap: () =>
                            _setQuickActionsVisible(!_showQuickActions),
                        open: _showQuickActions,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
