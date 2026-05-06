class ExpenseSplit {
  final String userId;
  final double amount;
  final bool isPaid;
  final DateTime? paidAt;

  const ExpenseSplit({
    required this.userId,
    required this.amount,
    this.isPaid = false,
    this.paidAt,
  });

  ExpenseSplit copyWith({
    String? userId,
    double? amount,
    bool? isPaid,
    DateTime? paidAt,
  }) {
    return ExpenseSplit(
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  factory ExpenseSplit.fromMap(Map<String, dynamic> map) {
    return ExpenseSplit(
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      isPaid: map['isPaid'] ?? false,
      paidAt: map['paidAt'] == null ? null : DateTime.parse(map['paidAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'isPaid': isPaid,
      'paidAt': paidAt?.toIso8601String(),
    };
  }
}
