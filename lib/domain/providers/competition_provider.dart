import 'package:flutter/material.dart' hide Badge;
import '../entities/challenge.dart';
import '../entities/badge.dart';

class CompetitionProvider with ChangeNotifier {
  List<Challenge> _challenges = [];
  List<Badge> _badges = [];
  bool _isLoading = false;

  List<Challenge> get challenges => _challenges;
  List<Badge> get badges => _badges;
  bool get isLoading => _isLoading;

  CompetitionProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _challenges = [
      Challenge(
        id: '1',
        title: '7 Ngày Ăn Rau Xanh',
        description: 'Thử thách ăn ít nhất 200g rau xanh mỗi ngày để thanh lọc cơ thể.',
        imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=2070&auto=format&fit=crop',
        type: ChallengeType.eatingGreens,
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        targetValue: 1000,
        currentProgress: 450,
        participantCount: 128,
        isJoined: true,
      ),
      Challenge(
        id: '2',
        title: 'Chiến Binh 50k Bước',
        description: 'Hoàn thành 50,000 bước chân trong vòng một tuần.',
        imageUrl: 'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?q=80&w=1974&auto=format&fit=crop',
        type: ChallengeType.steps,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        targetValue: 50000,
        currentProgress: 12500,
        participantCount: 85,
        isJoined: false,
      ),
    ];

    _badges = [
      Badge(
        id: 'b1',
        name: 'Chiến Binh 5km',
        description: 'Đã hoàn thành quãng đường chạy 5km đầu tiên.',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/610/610333.png',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 10)),
        criteria: 'Chạy bộ 5km',
      ),
      Badge(
        id: 'b2',
        name: 'Bậc Thầy Hydration',
        description: 'Duy trì mục tiêu uống nước trong 7 ngày liên tiếp.',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/3105/3105807.png',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
        criteria: 'Uống đủ nước 7 ngày',
      ),
      Badge(
        id: 'b3',
        name: 'Người Ăn Xanh',
        description: 'Hoàn thành thử thách 7 ngày ăn rau.',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/2329/2329895.png',
        isUnlocked: false,
        criteria: 'Hoàn thành thử thách ăn rau',
      ),
      Badge(
        id: 'b4',
        name: 'Sớm Tinh Mơ',
        description: 'Dậy sớm trước 6:00 AM trong 3 ngày liên tiếp.',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/1163/1163661.png',
        isUnlocked: false,
        criteria: 'Dậy sớm 3 ngày',
      ),
    ];
    notifyListeners();
  }

  Future<void> joinChallenge(String challengeId) async {
    _isLoading = true;
    notifyListeners();

    // Giả lập gọi API
    await Future.delayed(const Duration(seconds: 1));
    
    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index != -1) {
      final challenge = _challenges[index];
      _challenges[index] = Challenge(
        id: challenge.id,
        title: challenge.title,
        description: challenge.description,
        imageUrl: challenge.imageUrl,
        type: challenge.type,
        startDate: challenge.startDate,
        endDate: challenge.endDate,
        targetValue: challenge.targetValue,
        currentProgress: challenge.currentProgress,
        participantCount: challenge.participantCount + 1,
        isJoined: true,
      );
    }

    _isLoading = false;
    notifyListeners();
  }
}
