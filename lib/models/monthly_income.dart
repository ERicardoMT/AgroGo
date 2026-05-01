class MonthlyIncome {
  final double totalIncome;
  final double pendingPayments;
  final double completedPayments;
  final int rentalsCompleted;
  final DateTime periodStart;
  final DateTime periodEnd;

  MonthlyIncome({
    required this.totalIncome,
    required this.pendingPayments,
    required this.completedPayments,
    required this.rentalsCompleted,
    required this.periodStart,
    required this.periodEnd,
  });

  factory MonthlyIncome.fromJson(Map<String, dynamic> json) {
    return MonthlyIncome(
      totalIncome: (json['totalIncome'] as num).toDouble(),
      pendingPayments: (json['pendingPayments'] as num).toDouble(),
      completedPayments: (json['completedPayments'] as num).toDouble(),
      rentalsCompleted: json['rentalsCompleted'] as int,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'totalIncome': totalIncome,
        'pendingPayments': pendingPayments,
        'completedPayments': completedPayments,
        'rentalsCompleted': rentalsCompleted,
        'periodStart': periodStart.toIso8601String(),
        'periodEnd': periodEnd.toIso8601String(),
      };
}
