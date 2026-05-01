class Transaction {
  final String id;
  final String rentalId;
  final String equipmentName;
  final String renterName;
  final double totalAmount;
  final double appCommission;
  final double netProfit;
  final DateTime transactionDate;
  final DateTime? completedDate;
  final String status; // completed, pending, cancelled
  final String? notes;

  Transaction({
    required this.id,
    required this.rentalId,
    required this.equipmentName,
    required this.renterName,
    required this.totalAmount,
    required this.appCommission,
    required this.netProfit,
    required this.transactionDate,
    this.completedDate,
    required this.status,
    this.notes,
  });

  double get commissionPercentage => (appCommission / totalAmount) * 100;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      rentalId: json['rentalId'],
      equipmentName: json['equipmentName'],
      renterName: json['renterName'],
      totalAmount: json['totalAmount'].toDouble(),
      appCommission: json['appCommission'].toDouble(),
      netProfit: json['netProfit'].toDouble(),
      transactionDate: DateTime.parse(json['transactionDate']),
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      status: json['status'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rentalId': rentalId,
      'equipmentName': equipmentName,
      'renterName': renterName,
      'totalAmount': totalAmount,
      'appCommission': appCommission,
      'netProfit': netProfit,
      'transactionDate': transactionDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }
}
