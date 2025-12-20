import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wello_frontend/core/utils/user_session.dart';
import 'package:wello_frontend/data/repositories/profile_repository.dart';
import 'package:wello_frontend/domain/providers/profile_provider.dart';
import 'package:wello_frontend/domain/providers/survey_provider.dart';
import 'package:wello_frontend/data/models/requests/survey_request_model.dart';
import 'package:wello_frontend/data/models/responses/survey_response_model.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/ui/widgets/quick_actions_overlay.dart';
import 'package:wello_frontend/domain/providers/nutrition_provider.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:intl/intl.dart';
import 'package:wello_frontend/core/navigation/route_observer.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/auth/initial_page.dart';
import 'widgets/water_tracking_card.dart';
import 'package:wello_frontend/ui/summary/widgets/bmi_card.dart';
import 'widgets/physical_profile_page.dart';

class ProfileScreen extends StatefulWidget {
  final Function(bool)? onQuickActionsChanged;

  const ProfileScreen({super.key, this.onQuickActionsChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  bool _showQuickActions = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  int? _userId;
  bool _surveyRequested = false;
  bool _nutritionDataLoaded = false;
  bool _routeSubscribed = false;

  @override
  void initState() {
    super.initState();
    // Load user ID from SharedPreferences
    _loadUserId();
    // Load profile data when entering screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadProfileData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (!_routeSubscribed && route is PageRoute) {
      appRouteObserver.subscribe(this, route);
      _routeSubscribed = true;
    }
  }

  @override
  void dispose() {
    if (_routeSubscribed) {
      final route = ModalRoute.of(context);
      if (route is PageRoute) {
        appRouteObserver.unsubscribe(this);
      }
    }
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final userId = await UserSession.getUserId();
    if (!mounted) return;
    setState(() {
      _userId = userId ?? 1; // Default to 1 if not found
    });
  }

  Future<void> _loadProfileData() async {
    if (_userId == null || !mounted) return;

    try {
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      await profileProvider.loadProfile(_userId!);
    } catch (e) {
      print('[ProfileScreen] Error loading profile: $e');
    }
  }

  Future<void> _reloadOnReturn() async {
    if (!mounted || _userId == null) return;
    try {
      debugPrint('[ProfileScreen] didPopNext → Reloading data');
      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.loadProfile(_userId!);

      // Recompute BMI survey using latest profile
      final p = profileProvider.profileData;
      if (p != null) {
        final surveyProvider = context.read<SurveyProvider>();
        final req = SurveyRequestModel(
          userId: p.userId,
          fullname: p.fullname,
          gender: p.gender,
          age: p.age,
          height: p.height,
          weight: p.weight.toInt(),
          goal: p.goal,
          activityLevel: p.activityLevel,
        );
        await surveyProvider.submitSurvey(req);
      }

      // Reload today's water summary
      final credentials = await AuthHelper.getCredentials();
      if (credentials != null) {
        final nutritionProvider = context.read<NutritionProvider>();
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        await nutritionProvider.loadDailySummary(
          credentials.token,
          credentials.userIdString,
          today,
        );
      }
    } catch (e) {
      // ignore errors silently for back refresh
    }
  }

  void _setQuickActionsVisible(bool show) {
    setState(() => _showQuickActions = show);
    widget.onQuickActionsChanged?.call(show);
  }

  void _handleQuickAction(String key) {
    _setQuickActionsVisible(false);
    // TODO: điều hướng theo key
  }

  Future<void> _increase() async {
    final credentials = await AuthHelper.getCredentials();
    if (credentials != null && mounted) {
      final nutritionProvider = Provider.of<NutritionProvider>(
        context,
        listen: false,
      );
      try {
        await nutritionProvider.addWaterGlass(
          credentials.token,
          credentials.userIdString,
          glassSize: 250,
        );
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.water_drop, color: Colors.white),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('Đã thêm 250ml nước! 💧')),
                  ],
                ),
                backgroundColor: const Color(0xff61C8F5),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: Không thể thêm nước'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _decrease() async {
    // Backend không hỗ trợ giảm nước, chỉ hiển thị thông báo
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể giảm lượng nước đã uống')),
      );
    }
  }

  void _toggleNotif() {
    // TODO: Implement notification toggle
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(0.06),
              vertical: context.h(0.03),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    size: 48,
                    color: Color(0xFFE53935),
                  ),
                ),
                SizedBox(height: context.h(0.025)),
                Text(
                  'Đăng xuất',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(7.5),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4C494C),
                  ),
                ),
                SizedBox(height: context.h(0.015)),
                Text(
                  'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(5.5),
                    color: const Color(0xFF6B6B6B),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: context.h(0.03)),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: context.h(0.018),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: Color(0xFFE0E0E0),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Hủy',
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(6),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B6B6B),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.w(0.03)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          padding: EdgeInsets.symmetric(
                            vertical: context.h(0.018),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Đăng xuất',
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(6),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;

    try {
      await AuthHelper.logout();
      await UserSession.clearSession();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const InitialPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng xuất thất bại: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void didPopNext() {
    // Called when navigating back to this screen
    _reloadOnReturn();
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

      if (mounted && success) {
        final snack = SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              const Expanded(child: Text('Cập nhật ảnh đại diện thành công!')),
            ],
          ),
          backgroundColor: const Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Đóng',
            textColor: const Color(0xFF064E3B),
            onPressed: () {},
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snack);
        // Reload profile to get updated avatar URL
        setState(() {});
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
    return _buildProfileContent();
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
                if (!mounted) return;
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

            // Trigger BMI survey API when profile is available (once)
            if (profileData != null && !_surveyRequested) {
              _surveyRequested = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                final surveyProvider = Provider.of<SurveyProvider>(
                  context,
                  listen: false,
                );
                final req = SurveyRequestModel(
                  userId: profileData.userId,
                  fullname: profileData.fullname,
                  gender: profileData.gender,
                  age: profileData.age,
                  height: profileData.height,
                  weight: profileData.weight.toInt(),
                  goal: profileData.goal,
                  activityLevel: profileData.activityLevel,
                );
                surveyProvider.submitSurvey(req);
              });
            }

            // Load nutrition data (water) when profile is available (once)
            if (profileData != null && !_nutritionDataLoaded) {
              _nutritionDataLoaded = true;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!mounted) return;
                final credentials = await AuthHelper.getCredentials();
                if (credentials != null && mounted) {
                  final nutritionProvider = Provider.of<NutritionProvider>(
                    context,
                    listen: false,
                  );
                  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                  await nutritionProvider.loadDailySummary(
                    credentials.token,
                    credentials.userIdString,
                    today,
                  );
                }
              });
            }

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
                            fontSize: context.sp(8.5),
                            fontWeight: FontWeight.w900,
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
                            if (profileData != null) {
                              final profileProvider =
                                  Provider.of<ProfileProvider>(
                                    context,
                                    listen: false,
                                  );
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (_) => PhysicalProfilePage(
                                        profile: profileData,
                                        onUpdateFullname:
                                            (userId, fullname) async {
                                              return await profileProvider
                                                  .updateFullname(
                                                    userId: userId,
                                                    fullname: fullname,
                                                  );
                                            },
                                        onUpdateGender: (userId, gender) async {
                                          return await profileProvider
                                              .updateGender(
                                                userId: userId,
                                                gender: gender,
                                              );
                                        },
                                        onUpdateAge: (userId, age) async {
                                          return await profileProvider
                                              .updateAge(
                                                userId: userId,
                                                age: age,
                                              );
                                        },
                                        onUpdateHeight: (userId, height) async {
                                          return await profileProvider
                                              .updateHeight(
                                                userId: userId,
                                                height: height,
                                              );
                                        },
                                        onUpdateWeight: (userId, weight) async {
                                          return await profileProvider
                                              .updateWeight(
                                                userId: userId,
                                                weight: weight,
                                              );
                                        },
                                        onUpdateGoal: (userId, goal) async {
                                          return await profileProvider
                                              .updateGoal(
                                                userId: userId,
                                                goal: goal,
                                              );
                                        },
                                        onUpdateActivityLevel:
                                            (userId, activityLevel) async {
                                              return await profileProvider
                                                  .updateActivityLevel(
                                                    userId: userId,
                                                    activityLevel:
                                                        activityLevel,
                                                  );
                                            },
                                        onRefreshProfile: () async {
                                          await profileProvider.loadProfile(
                                            _userId!,
                                          );
                                          return profileProvider.profileData;
                                        },
                                      ),
                                    ),
                                  )
                                  .then((_) {
                                    if (mounted) {
                                      _reloadOnReturn();
                                    }
                                  });
                            }
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
                        Consumer<SurveyProvider>(
                          builder: (context, surveyProvider, _) {
                            if (surveyProvider.isLoading &&
                                !surveyProvider.hasResult) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: context.h(0.02),
                                  ),
                                  child: CircularProgressIndicator(
                                    color: const Color(0xFFEBCF23),
                                  ),
                                ),
                              );
                            }
                            if (surveyProvider.hasError &&
                                !surveyProvider.hasResult) {
                              return Column(
                                children: [
                                  Text(
                                    surveyProvider.errorMessage ??
                                        'Không tải được BMI',
                                    style: GoogleFonts.baloo2(
                                      color: Colors.red,
                                      fontSize: context.sp(5),
                                    ),
                                  ),
                                  SizedBox(height: context.h(0.01)),
                                  ElevatedButton(
                                    onPressed: () {
                                      final p = profileProvider.profileData!;
                                      final req = SurveyRequestModel(
                                        userId: p.userId,
                                        fullname: p.fullname,
                                        gender: p.gender,
                                        age: p.age,
                                        height: p.height,
                                        weight: p.weight.toInt(),
                                        goal: p.goal,
                                        activityLevel: p.activityLevel,
                                      );
                                      surveyProvider.submitSurvey(req);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEBCF23),
                                    ),
                                    child: Text(
                                      'Thử lại',
                                      style: GoogleFonts.baloo2(
                                        color: Colors.white,
                                        fontSize: context.sp(5),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            if (surveyProvider.surveyResult != null) {
                              final r = surveyProvider.surveyResult!;
                              final p = profileProvider.profileData;
                              final merged = SurveyResponseModel(
                                bmi: r.bmi,
                                bmiStatus: r.bmiStatus,
                                bmr: r.bmr,
                                tdee: r.tdee,
                                dailyCalories: r.dailyCalories,
                                proteinGram: r.proteinGram,
                                carbsGram: r.carbsGram,
                                fatGram: r.fatGram,
                                waterIntakeMl: r.waterIntakeMl,
                                height: p?.height.toDouble() ?? r.height,
                                weight: p?.weight ?? r.weight,
                              );
                              return BMICard(survey: merged);
                            }
                            return const SizedBox.shrink();
                          },
                        ),

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

                        Consumer<NutritionProvider>(
                          builder: (context, nutritionProvider, _) {
                            final waterIntake =
                                nutritionProvider.dailySummary?.waterIntake;
                            final consumed = waterIntake?.consumed ?? 0;
                            final target = waterIntake?.target ?? 2000;

                            return WaterTrackingCard(
                              amount: consumed,
                              goal: target,
                              lastTime: '',
                              isNotificationOn: false,
                              onIncrease: _increase,
                              onDecrease: _decrease,
                              onToggleNotification: _toggleNotif,
                            );
                          },
                        ),
                        SizedBox(height: context.h(0.03)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.w(0.08),
                          ),
                          child: AnimatedStartButton(
                            text: 'Đăng xuất',
                            onPressed: _logout,
                          ),
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
                          child: IgnorePointer(
                            ignoring: !_showQuickActions,
                            child: QuickActionsPanel(
                              onAction: _handleQuickAction,
                            ),
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
