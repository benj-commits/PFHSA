import 'package:flutter/foundation.dart';
import '../models/goal.dart';
import '../services/api_service.dart';

class GoalProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.get('/goals');
      _goals = (data as List).map((g) => Goal.fromJson(g)).toList();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createGoal({
    required String name,
    required double targetAmount,
    double currentAmount = 0,
    DateTime? deadline,
  }) async {
    try {
      await _api.post('/goals', {
        'name': name,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
        if (deadline != null) 'deadline': deadline.toIso8601String().split('T').first,
      });
      await loadGoals();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('ApiException: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> contribute(int goalId, double amount) async {
    try {
      await _api.post('/goals/$goalId/contribute', {'amount': amount});
      await loadGoals();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('ApiException: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGoal(int id) async {
    try {
      await _api.delete('/goals/$id');
      _goals.removeWhere((g) => g.goalId == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}
