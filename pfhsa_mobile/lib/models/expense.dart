class Expense {
  final int? expenseId;
  final int? categoryId;
  final String? categoryName;
  final double amount;
  final String? description;
  final DateTime date;

  Expense({
    this.expenseId,
    this.categoryId,
    this.categoryName,
    required this.amount,
    this.description,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseId: json['expense_id'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      amount: double.parse(json['amount'].toString()),
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'amount': amount,
        'description': description,
        'date': date.toIso8601String().split('T').first,
      };
}
