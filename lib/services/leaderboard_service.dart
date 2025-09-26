// lib/services/leaderboard_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LeaderboardService {
  static const _key = 'leaderboard';

  Future<void> saveScore(String username, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final leaderboard = await getLeaderboard();

    // Add the new score
    leaderboard.add({'username': username, 'score': score});

    // Sort by score in descending order
    leaderboard.sort((a, b) => b['score'].compareTo(a['score']));

    // Keep only the top 10 or so
    final topScores = leaderboard.take(10).toList();

    await prefs.setString(_key, jsonEncode(topScores));
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final String? leaderboardString = prefs.getString(_key);

    if (leaderboardString == null) {
      return [];
    }

    return List<Map<String, dynamic>>.from(jsonDecode(leaderboardString));
  }
}