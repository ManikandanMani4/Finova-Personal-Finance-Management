import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/savings/models/savings_goal.dart';
/// Saves goals on this device. For multi-device/user sync, replace this with an API.
class SavingsGoalService {
  static const String _storageKey = 'finova_savings_goals_v1';

  Future<List<SavingsGoal>> getGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => SavingsGoal.fromJson(
        Map<String, dynamic>.from(item as Map),
      ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<SavingsGoal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(goals.map((goal) => goal.toJson()).toList()),
    );
  }

  Future<void> addGoal(SavingsGoal goal) async {
    final goals = await getGoals();
    goals.insert(0, goal);
    await _saveAll(goals);
  }

  Future<void> updateGoal(SavingsGoal updated) async {
    final goals = await getGoals();
    final index = goals.indexWhere((goal) => goal.id == updated.id);
    if (index == -1) return;
    goals[index] = updated;
    await _saveAll(goals);
  }

  Future<void> deleteGoal(String id) async {
    final goals = await getGoals();
    goals.removeWhere((goal) => goal.id == id);
    await _saveAll(goals);
  }
}
