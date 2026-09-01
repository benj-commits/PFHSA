class Income {
  final int? incomeId;
  final String source;
  final double amount;
  final DateTime date;
  final String? notes;

  Income({this.incomeId, required this.source, required this.amount, required this.date, this.notes});

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      incomeId: json['income_id'],
      source: json['source'],
      amount: double.parse(json['amount'].toString()),
      date: DateTime.parse(json['date']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'source': source,
        'amount': amount,
        'date': date.toIso8601String().split('T').first,
        'notes': notes,
      };
}
