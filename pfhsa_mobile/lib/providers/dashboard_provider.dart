import 'package:flutter/foundation.dart';
import '../models/health_score.dart';
import '../services/api_service.dart';

class CategorySpend {
  final int? categoryId;
  final String categoryName;
  final double total;
  CategorySpend({this.categoryId, required this.categoryName, required this.total});

  factory CategorySpend.fromJson(Map<String, dynamic> json) {
    return CategorySpend(
      categoryId: json['category_id'],
      categoryName: json['category_name'] ?? 'Uncategorized',
      total: double.parse(json['total'].toString()),
    );
  }
}

class DashboardProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  double totalIncome = 0;
  double totalExpenses = 0;
  double savings = 0;
  double savingsRatePercent = 0;
  List<CategorySpend> categoryBreakdown = [];
  HealthScore? healthScore;
  bool isLoading = false;
  String? error;

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();
    try {
      final summary = await _api.get('/dashboard/summary');
      totalIncome = double.parse(summary['total_income'].toString());
      totalExpenses = double.parse(summary['total_expenses'].toString());
      savings = double.parse(summary['savings'].toString());
      savingsRatePercent = double.parse(summary['savings_rate_percent'].toString());

      final breakdown = await _api.get('/dashboard/category-breakdown');
      categoryBreakdown = (breakdown as List).map((c) => CategorySpend.fromJson(c)).toList();

      final score = await _api.get('/dashboard/health-score');
      healthScore = HealthScore.fromJson(score);
    } catch (e) {
      error = e.toString().replaceFirst('ApiException: ', '');
    }
    isLoading = false;
    notifyListeners();
  }
}
