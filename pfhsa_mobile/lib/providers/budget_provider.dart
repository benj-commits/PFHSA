import 'package:flutter/foundation.dart';
import '../models/budget.dart';
import '../services/api_service.dart';

class BudgetProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _error;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBudgets() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.get('/budgets');
      _budgets = (data as List).map((b) => Budget.fromJson(b)).toList();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createBudget({
    int? categoryId,
    required double amount,
    required String period,
    required DateTime startDate,
  }) async {
    try {
      await _api.post('/budgets', {
        'category_id': categoryId,
        'amount': amount,
        'period': period,
        'start_date': startDate.toIso8601String().split('T').first,
      });
      await loadBudgets();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('ApiException: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBudget(int id) async {
    try {
      await _api.delete('/budgets/$id');
      _budgets.removeWhere((b) => b.budgetId == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}
