class ExpenseSplit {
  final String userId;
  final double amount;
  final bool isPaid;

  ExpenseSplit({
    required this.userId,
    required this.amount,
    this.isPaid = false,
  });

  factory ExpenseSplit.fromMap(Map<String, dynamic> map) {
    return ExpenseSplit(
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      isPaid: map['isPaid'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'isPaid': isPaid,
    };
  }
}