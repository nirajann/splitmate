import 'expense_split.dart';

enum ExpenseCategory {
  food,
  travel,
  rent,
  shopping,
  bills,
  entertainment,
  other,
}

class Expense {
  final String id;
  final String lobbyId;
  final String title;
  final double amount;
  final String paidByUserId;
  final ExpenseCategory category;
  final DateTime createdAt;
  final List<ExpenseSplit> splits;
  final String? note;

  Expense({
    required this.id,
    required this.lobbyId,
    required this.title,
    required this.amount,
    required this.paidByUserId,
    required this.category,
    required this.createdAt,
    required this.splits,
    this.note,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] ?? '',
      lobbyId: map['lobbyId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      paidByUserId: map['paidByUserId'] ?? '',
      category: ExpenseCategory.values.firstWhere(
            (e) => e.name == map['category'],
        orElse: () => ExpenseCategory.other,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      splits: List<ExpenseSplit>.from(
        (map['splits'] ?? []).map((x) => ExpenseSplit.fromMap(x)),
      ),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lobbyId': lobbyId,
      'title': title,
      'amount': amount,
      'paidByUserId': paidByUserId,
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
      'splits': splits.map((x) => x.toMap()).toList(),
      'note': note,
    };
  }
}