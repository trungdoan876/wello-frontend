import 'package:flutter/material.dart' hide Badge;
import 'package:wello_frontend/core/utils/auth_helper.dart';
import '../entities/badge.dart';
import '../entities/post.dart';
import '../repositories/competition_repository.dart';

class CompetitionProvider with ChangeNotifier {
  final CompetitionRepository _repository;

  List<Badge> _badges = [];
  List<Map<String, dynamic>> _leaderboardEntries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Badge> get badges => _badges;
  List<Map<String, dynamic>> get leaderboardEntries => _leaderboardEntries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CompetitionProvider(this._repository) {
    fetchBadges();
  }


  Future<void> fetchBadges() async {
    _isLoading = true;
    notifyListeners();

    try {
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token ?? '';
      _badges = await _repository.getBadges(token: token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLeaderboard(String type, String period) async {
    _isLoading = true;
    notifyListeners();

    try {
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token ?? '';
      _leaderboardEntries = await _repository.getLeaderboard(
        token: token,
        type: type,
        period: period,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> equipBadge(String token, int badgeId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repository.equipBadge(token: token, badgeId: badgeId);
      if (success) {
        await fetchBadges(); // Refresh list to get updated status
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> unequipBadge(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repository.unequipBadge(token: token);
      if (success) {
        await fetchBadges();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
