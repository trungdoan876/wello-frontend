import 'package:flutter/material.dart' hide Badge;
import 'package:wello_frontend/core/utils/auth_helper.dart';
import '../entities/challenge.dart';
import '../entities/badge.dart';
import '../entities/post.dart';
import '../repositories/competition_repository.dart';

class CompetitionProvider with ChangeNotifier {
  final CompetitionRepository _repository;

  List<Challenge> _challenges = [];
  List<Badge> _badges = [];
  List<Map<String, dynamic>> _leaderboardEntries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Challenge> get challenges => _challenges;
  List<Badge> get badges => _badges;
  List<Map<String, dynamic>> get leaderboardEntries => _leaderboardEntries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CompetitionProvider(this._repository) {
    fetchChallenges();
    fetchBadges();
  }

  Future<void> fetchChallenges() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token ?? '';
      _challenges = await _repository.getChallenges(token: token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  Future<void> joinChallenge(int challengeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token ?? '';
      await _repository.joinChallenge(token: token, challengeId: challengeId);
      await fetchChallenges(); // Refresh data
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Post?> submitProof(int challengeId, String content, String? imageUrl) async {
    _isLoading = true;
    notifyListeners();

    try {
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token ?? '';
      final post = await _repository.submitProof(
        token: token,
        challengeId: challengeId,
        content: content,
        imageUrl: imageUrl,
      );
      await fetchChallenges(); // Refresh to update progress
      return post;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
