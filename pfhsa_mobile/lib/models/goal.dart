class Goal {
  final int goalId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final double progressPercent;

  Goal({
    required this.goalId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    required this.progressPercent,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      goalId: json['goal_id'],
      name: json['name'],
      targetAmount: double.parse(json['target_amount'].toString()),
      currentAmount: double.parse(json['current_amount'].toString()),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      progressPercent: double.parse((json['progress_percent'] ?? 0).toString()),
    );
  }
}
