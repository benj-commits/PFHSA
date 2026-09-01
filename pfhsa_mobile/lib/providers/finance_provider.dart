import 'package:flutter/foundation.dart';
import '../models/income.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class FinanceProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Income> _incomeList = [];
  List<Expense> _expenseList = [];
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];
  bool _isLoading = false;
  String? _error;

  List<Income> get incomeList => _incomeList;
  List<Expense> get expenseList => _expenseList;
  List<Category> get expenseCategories => _expenseCategories;
  List<Category> get incomeCategories => _incomeCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    try {
      final expenseData = await _api.get('/categories', query: {'type': 'expense'});
      final incomeData = await _api.get('/categories', query: {'type': 'income'});
      _expenseCategories = (expenseData as List).map((c) => Category.fromJson(c)).toList();
      _incomeCategories = (incomeData as List).map((c) => Category.fromJson(c)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> loadIncome() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.get('/income');
      _incomeList = (data as List).map((i) => Income.fromJson(i)).toList();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.get('/expenses');
      _expenseList = (data as List).map((e) => Expense.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addIncome(Income income) async {
    try {
      await _api.post('/income', income.toJson());
      await loadIncome();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('ApiException: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> addExpense(Expense expense) async {
    try {
      await _api.post('/expenses', expense.toJson());
      await loadExpenses();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('ApiException: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteIncome(int id) async {
    try {
      await _api.delete('/income/$id');
      _incomeList.removeWhere((i) => i.incomeId == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      await _api.delete('/expenses/$id');
      _expenseList.removeWhere((e) => e.expenseId == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}
