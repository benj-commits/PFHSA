class Budget {
  final int budgetId;
  final int? categoryId;
  final String? categoryName;
  final double amount;
  final String period;
  final DateTime startDate;
  final double spent;
  final double remaining;
  final double percentUsed;
  final String status;

  Budget({
    required this.budgetId,
    this.categoryId,
    this.categoryName,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.spent,
    required this.remaining,
    required this.percentUsed,
    required this.status,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      budgetId: json['budget_id'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      amount: double.parse(json['amount'].toString()),
      period: json['period'],
      startDate: DateTime.parse(json['start_date']),
      spent: double.parse(json['spent'].toString()),
      remaining: double.parse(json['remaining'].toString()),
      percentUsed: double.parse(json['percent_used'].toString()),
      status: json['status'],
    );
  }
}
