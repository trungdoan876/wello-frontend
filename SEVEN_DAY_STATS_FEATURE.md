# 7-Day Statistics Feature - Updated

## Tổng quan

Tính năng "Thống kê 7 ngày" hiển thị thống kê chi tiết và toàn diện cho 7 ngày gần nhất về sức khỏe, dinh dưỡng và hoạt động thể chất.

## Dữ liệu được hiển thị

### 1. Chỉ số chính (3 metrics)
- **Uống đủ nước**: Số ngày nước uống đạt/vượt mục tiêu
- **Tập luyện**: Số ngày có hoạt động thể chất
- **Vượt calo**: Số ngày tiêu thụ calo vượt mục tiêu

Mỗi metric hiển thị:
- Số ngày / tổng ngày
- Tỷ lệ phần trăm (%)
- Thanh tiến trình

### 2. Nước uống (Water Intake)
- Tổng nước uống (ml)
- Trung bình/ngày (ml)
- Cao nhất (ml)
- Thấp nhất (ml)

### 3. Calo (Calories)
- Tổng tiêu thụ (cal)
- Tổng đốt cháy (cal)
- Thâm hụt calo (cal)
- Trung bình tiêu thụ/ngày (cal)
- Trung bình đốt cháy/ngày (cal)

### 4. Thống kê bữa ăn (Meals)
- Tổng bữa ăn (số bữa)
- Trung bình/ngày
- Bữa sáng (lần)
- Bữa trưa (lần)
- Bữa tối (lần)
- Ăn vặt (lần)

### 5. Đạm / Carb / Chất béo (Macronutrients)
**Carb (Tinh bột)**
- Tổng (g)
- Trung bình/ngày (g)

**Đạm**
- Tổng (g)
- Trung bình/ngày (g)

**Chất béo**
- Tổng (g)
- Trung bình/ngày (g)

### 6. Hoạt động thể chất (Workout)
- Ngày tập luyện (ngày)
- Trung bình/tuần (ngày)
- Calo đốt cao nhất (cal)

## Cấu trúc Files

### Entities
- [lib/domain/entities/seven_day_stats.dart](lib/domain/entities/seven_day_stats.dart)
  - `SevenDayStats` class với 30+ thuộc tính
  - Phương thức `fromJson()` để parse API response
  - Getter để tính toán tỷ lệ phần trăm

### Provider
- [lib/domain/providers/seven_day_stats_provider.dart](lib/domain/providers/seven_day_stats_provider.dart)
  - Quản lý state thống kê
  - Method `loadSevenDayStats()` gọi API
  - Getters: stats, isLoading, hasError, errorMessage

### Remote Data Source
- [lib/data/data_source/nutrition_remote_data_source.dart](lib/data/data_source/nutrition_remote_data_source.dart)
  - Method `getSevenDayStats(token, userId)` 
  - Endpoint: `GET /api/stats/seven-days/{userId}`

### Screen
- [lib/ui/profile/seven_day_stats_screen.dart](lib/ui/profile/seven_day_stats_screen.dart)
  - Giao diện hiển thị các thống kê
  - 6 section: Chỉ số chính, Nước, Calo, Bữa ăn, Macro, Hoạt động
  - Loading, error handling, retry button

### Integration
- [lib/ui/profile/profile_screen.dart](lib/ui/profile/profile_screen.dart)
  - Button "Thống kê 7 ngày" (màu indigo #6366F1)
  - Dẫn tới `SevenDayStatsScreen`

## API Endpoint

```
GET /api/stats/seven-days/{userId}
Authorization: Bearer {token}
```

### Response Format
```json
{
  "daysWithSufficientWater": 0-7,
  "daysWithWorkout": 0-7,
  "daysExceedingCalories": 0-7,
  "totalDays": 7,
  "totalWaterMl": 0.0,
  "averageWaterMl": 0.0,
  "maxWaterMl": 0.0,
  "minWaterMl": 0.0,
  "totalCaloriesConsumed": 0.0,
  "totalCaloriesBurned": 0.0,
  "totalCaloriesDeficit": 0.0,
  "averageCaloriesConsumed": 0.0,
  "averageCaloriesBurned": 0.0,
  "averageCaloriesDeficit": 0.0,
  "totalMeals": 0,
  "averageMealsPerDay": 0.0,
  "breakfastCount": 0,
  "lunchCount": 0,
  "dinnerCount": 0,
  "snackCount": 0,
  "workoutDays": 0,
  "averageWorkoutDaysPerWeek": 0.0,
  "maxDailyCaloriesBurned": 0.0,
  "totalCarbs": 0.0,
  "totalProtein": 0.0,
  "totalFat": 0.0,
  "averageCarbsPerDay": 0.0,
  "averageProteinPerDay": 0.0,
  "averageFatPerDay": 0.0,
  "startDate": "YYYY-MM-DD",
  "endDate": "YYYY-MM-DD"
}
```

## Cách sử dụng

### Từ Profile Screen
1. Mở Profile Screen
2. Nhấp vào button "Thống kê 7 ngày" (dòng thứ 2, màu xanh indigo)
3. Xem thống kê chi tiết cho 7 ngày vừa qua

### Lập trình
```dart
// Tạo provider
final provider = SevenDayStatsProvider();

// Tải dữ liệu
await provider.loadSevenDayStats(token, userId);

// Lấy dữ liệu
final stats = provider.stats;
if (stats != null) {
  print('Ngày uống đủ nước: ${stats.daysWithSufficientWater}');
  print('Tỷ lệ: ${stats.waterPercentage.toStringAsFixed(1)}%');
  print('Tổng calo: ${stats.totalCaloriesConsumed}');
  print('Tổng đạm: ${stats.totalProtein}g');
}
```

## Thiết kế UI

### Màu sắc
- **Nước**: Xanh dương (Colors.blue)
- **Tập luyện**: Xanh lá (Colors.green)
- **Vượt calo**: Cam (Colors.orange)
- **Button**: Indigo (#6366F1)
- **Accent**: Vàng (#EBCF23)

### Layout
- Header: Khoảng thời gian (7 ngày)
- Section 1: 3 metric cards (ngang)
- Section 2-6: Chi tiết (dọc), mỗi dòng có label + value

### Responsive
- Sử dụng `context.w()`, `context.h()`, `context.sp()` từ Responsive widget
- Tự động điều chỉnh cho các kích thước màn hình khác nhau

## Error Handling

- **Loading state**: Hiển thị CircularProgressIndicator
- **Error state**: Icon lỗi + thông báo + nút "Thử lại"
- **No data**: Thông báo "Không có dữ liệu"
- **API error**: Hiển thị chi tiết lỗi từ errorMessage

## Tính năng bổ sung trong tương lai

1. **Biểu đồ**: Thêm charts để hiển thị trend
2. **So sánh tuần**: So sánh với tuần trước
3. **Export dữ liệu**: Xuất PDF/image
4. **Alarm/Notification**: Cảnh báo khi không đạt mục tiêu
5. **Custom date range**: Chọn khoảng thời gian tuỳ ý
6. **Week comparison chart**: Biểu đồ so sánh tuần

## Notes

- Dữ liệu được tải từ API khi mở screen
- Cache dữ liệu trong provider để không load lại khi quay lại
- Tất cả giá trị được format với `toStringAsFixed()` để hiển thị đúng số thập phân
- Responsive design hoạt động tốt trên tablet và phone
