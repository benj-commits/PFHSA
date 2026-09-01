class HealthScore {
  final int score;
  final String rating;
  final String emoji;
  final double savingsRatePercent;
  final Map<String, dynamic> breakdown;
  final List<String> recommendations;
  final double totalIncome;
  final double totalExpenses;

  HealthScore({
    required this.score,
    required this.rating,
    required this.emoji,
    required this.savingsRatePercent,
    required this.breakdown,
    required this.recommendations,
    required this.totalIncome,
    required this.totalExpenses,
  });

  factory HealthScore.fromJson(Map<String, dynamic> json) {
    return HealthScore(
      score: json['score'],
      rating: json['rating'],
      emoji: json['emoji'],
      savingsRatePercent: double.parse(json['savings_rate_percent'].toString()),
      breakdown: Map<String, dynamic>.from(json['breakdown']),
      recommendations: List<String>.from(json['recommendations']),
      totalIncome: double.parse(json['total_income'].toString()),
      totalExpenses: double.parse(json['total_expenses'].toString()),
    );
  }
}
