/// Quản lý tập trung các API endpoints
/// Đổi baseUrl ở đây để chuyển server cho toàn bộ ứng dụng
class ApiEndpoints {
  // ============================================
  // BASE URL - Đổi URL này để chuyển server
  // ============================================

  // Server production (memap.id.vn)
  //   static const String baseUrl = 'https://wello.memap.id.vn/api';

  // Local development (REAL DEVICE - dùng adb reverse)
  static const String baseUrl = 'http://127.0.0.1:8086/api';
  // Local development (Android Emulator)
<<<<<<< HEAD
  //static const String baseUrl = 'http://10.0.2.2:8080/api';
  // Local development (REAL DEVICE - điện thoại thật)
   static const String baseUrl = 'http://192.168.88.246:8080/api';
=======
  // static const String baseUrl = 'http://10.0.2.2:8086/api';
  // Local development (REAL DEVICE - dùng IP Wi-Fi)
  // static const String baseUrl = 'http://192.168.11.211:8086/api';
>>>>>>> ec3db14c69c06193e37691a7a190f133e23e14d5

  // ============================================
  // AUTH ENDPOINTS - Xác thực, đăng nhập, đăng ký
  // ============================================
  static String get login => '$baseUrl/login';
  static String get register => '$baseUrl/register';
  static String get verifyOtp => '$baseUrl/verify-otp';
  static String get forgotPassword => '$baseUrl/forgot-password';
  static String get resetPassword => '$baseUrl/reset-password';

  // ============================================
  // PROFILE ENDPOINTS - Hồ sơ người dùng
  // ============================================
  static String profileInfo(int userId) => '$baseUrl/profile/info/$userId';
  static String uploadAvatar(int userId) =>
      '$baseUrl/profile/$userId/avatar/base64';
  static String updateFullname(int userId) =>
      '$baseUrl/profile/$userId/fullname';
  static String updateGender(int userId) => '$baseUrl/profile/$userId/gender';
  static String updateAge(int userId) => '$baseUrl/profile/$userId/age';
  static String updateHeight(int userId) => '$baseUrl/profile/$userId/height';
  static String updateWeight(int userId) => '$baseUrl/profile/$userId/weight';
  static String updateGoal(int userId) => '$baseUrl/profile/$userId/goal';
  static String updateActivityLevel(int userId) =>
      '$baseUrl/profile/$userId/activity-level';
  static String updateFcmToken(int userId, String fcmToken) =>
      '$baseUrl/profile/$userId/fcm-token?fcmToken=$fcmToken';
  static String updateWaterReminderSettings({
    required int userId,
    required bool enabled,
    required int startHour,
    required int endHour,
    required int intervalHours,
    required int intervalMinutes,
  }) =>
      '$baseUrl/profile/$userId/water-reminder-settings?'
      'enabled=$enabled&startHour=$startHour&endHour=$endHour'
      '&intervalHours=$intervalHours&intervalMinutes=$intervalMinutes';

  // ============================================
  // SURVEY ENDPOINTS - Khảo sát
  // ============================================
  static String get surveyQuestions => '$baseUrl/survey/questions';
  static String get surveySubmit => '$baseUrl/survey/submit';
  static String get surveyCalculateBmi => '$baseUrl/survey/calculate-bmi';

  // ============================================
  // FOOD ENDPOINTS - Thực phẩm
  // ============================================
  static String get foodAll => '$baseUrl/food/all';
  static String get foodPreview => '$baseUrl/food/preview';
  static String get foodRequest => '$baseUrl/food/request';
  static String foodSearch(String query) => '$baseUrl/food/search?query=${Uri.encodeComponent(query)}';

  // ============================================
  // FAVORITES ENDPOINTS - Yêu thích
  // ============================================
  static String favoriteById(int favoriteId, int userId) =>
      '$baseUrl/favorites/$favoriteId?userId=$userId';
  static String get favoritesAddFood => '$baseUrl/favorites/add-favorite-food';
  static String get favoritesUpdateFood =>
      '$baseUrl/favorites/update-favorite-food';
  static String favoriteDelete(int favoriteId, int userId) =>
      '$baseUrl/favorites/delete/$favoriteId?userId=$userId';
  static String get favoritesLog => '$baseUrl/favorites/log';
  static String favoritesByUser(int userId) =>
      '$baseUrl/favorites/user/$userId';

  // ============================================
  // NUTRITION ENDPOINTS - Dinh dưỡng
  // ============================================
  static String userProfile(int userId) =>
      '$baseUrl/user/profile?userId=$userId';
  static String nutritionHistory(int userId) => '$baseUrl/history/$userId';
  static String userVerify(int userId) => '$baseUrl/user/verify?userId=$userId';
  static String nutritionDailySummary(int userId, String date) =>
      '$baseUrl/nutrition/daily-summary?userId=$userId&date=$date';
  static String nutritionWeekOverview(int userId, String startDate) =>
      '$baseUrl/nutrition/week-overview?userId=$userId&startDate=$startDate';
  static String sevenDayStats(int userId) =>
      '$baseUrl/stats/seven-days/$userId';
  static String get nutritionLogFood => '$baseUrl/nutrition/log-food';
  static String nutritionFoodHistory(int userId, String date) =>
      '$baseUrl/nutrition/history/food?userId=$userId&date=$date';

  // ============================================
  // WATER INTAKE ENDPOINTS - Nước uống
  // ============================================
  static String waterIntakeDaily(int userId, String date) =>
      '$baseUrl/water-intake/daily?userId=$userId&date=$date';
  static String get waterIntakeAdd => '$baseUrl/water-intake/add';
  static String get waterIntakeDelete => '$baseUrl/water-intake/delete';

  // ============================================
  // EXERCISE/WORKOUT ENDPOINTS - Tập luyện
  // ============================================
  static String get workoutExercises => '$baseUrl/workout/exercises';
  static String workoutCalculate(
    int userId,
    int exerciseId,
    int durationMinutes,
  ) =>
      '$baseUrl/workout/calculate?userId=$userId&exerciseId=$exerciseId&durationMinutes=$durationMinutes';
  static String get workoutLog => '$baseUrl/workout/log';
  static String workoutDaily(int userId, String date) =>
      '$baseUrl/workout/daily?userId=$userId&date=$date';
  static String get workoutRequestExercise => '$baseUrl/workout/request';

  // ============================================
  // SLEEP TRACKING ENDPOINTS - Theo dõi giấc ngủ
  // ============================================
  static String get sleepLogBedtime => '$baseUrl/sleep/log-bedtime';
  static String get sleepComplete => '$baseUrl/sleep/complete';
  static String sleepToday(int userId, String date) =>
      '$baseUrl/sleep/today?userId=$userId&date=$date';
  static String sleepUpdate(int sleepId, int userId) =>
      '$baseUrl/sleep/tracker/$sleepId?userId=$userId';
  static String sleepDelete(int sleepId, int userId) =>
      '$baseUrl/sleep/tracker/$sleepId?userId=$userId';

  // ===================== STREAK =====================
  static String streakMonthly(int userId, int year, int month) =>
      '$baseUrl/streaks/monthly?userId=$userId&year=$year&month=$month';

  // ===================== COMMUNITY =====================
  static String get posts => '$baseUrl/posts';
  static String reactPost(int postId, String type) =>
      '$baseUrl/posts/$postId/react?type=$type';

  // ===================== CHAT =====================
  static String get chatConversations => '$baseUrl/chat/conversations';
  static String chatConversationMessages(int conversationId) =>
      '$baseUrl/chat/conversations/$conversationId/messages';
  static String get chatMessages => '$baseUrl/chat/messages';

  // ============================================
  // RUNNING GPS ENDPOINTS - Chạy bộ GPS
  // ============================================
  static String get runningSession => '$baseUrl/running/session';
  static String runningHistory(int userId, {int limit = 10}) =>
      '$baseUrl/running/history?userId=$userId&limit=$limit';
  static String runningWeeklySummary(int userId, String startDate) =>
      '$baseUrl/running/weekly-summary?userId=$userId&startDate=$startDate';

  // ============================================
  // COMPETITION & LEADERBOARD ENDPOINTS
  // ============================================
  static String leaderboard(String type, String period) =>
      '$baseUrl/leaderboard?type=$type&period=$period';

  static String get challenges => '$baseUrl/challenges';
  static String challengeDetail(int id) => '$baseUrl/challenges/$id';
  static String joinChallenge(int id) => '$baseUrl/challenges/$id/join';
  static String submitChallengeProof(int id) =>
      '$baseUrl/challenges/$id/submit-proof';

  static String get badges => '$baseUrl/badges';
  static String userBadges(int userId) => '$baseUrl/badges/user/$userId';

  // ===================== AI ASSISTANT =====================
  static String get aiParseMeal => '$baseUrl/ai/parse-meal';
}

