import 'expense_split.dart';

enum ExpenseCategory {
  food,
  travel,
  rent,
  shopping,
  bills,
  entertainment,
  hotel,
  gift,
  utilities,
  other,
}

enum SplitType { equal, exact, percentage, shares, itemized }

enum ExpenseStatus { active, partiallySettled, settled, cancelled }

class Expense {
  final String id;
  final String lobbyId;
  final String title;
  final double amount;
  final String paidByUserId;
  final ExpenseCategory category;
  final SplitType splitType;
  final ExpenseStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ExpenseSplit> splits;
  final String? note;

  const Expense({
    required this.id,
    required this.lobbyId,
    required this.title,
    required this.amount,
    required this.paidByUserId,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.splits,
    this.splitType = SplitType.equal,
    this.status = ExpenseStatus.active,
    this.note,
  });

  bool get isFullySettled {
    if (splits.isEmpty) return false;

    final unpaidSplits = splits.where((split) {
      if (split.userId == paidByUserId) return false;
      return !split.isPaid;
    }).toList();

    return unpaidSplits.isEmpty;
  }

  bool get isPartiallySettled {
    final payableSplits = splits.where((split) {
      return split.userId != paidByUserId;
    }).toList();

    if (payableSplits.isEmpty) return false;

    final paidCount = payableSplits.where((split) => split.isPaid).length;

    return paidCount > 0 && paidCount < payableSplits.length;
  }

  double get unpaidAmount {
    return splits
        .where((split) {
          if (split.userId == paidByUserId) return false;
          return !split.isPaid;
        })
        .fold<double>(0, (sum, split) => sum + split.amount);
  }

  double get paidAmount {
    return splits
        .where((split) {
          if (split.userId == paidByUserId) return false;
          return split.isPaid;
        })
        .fold<double>(0, (sum, split) => sum + split.amount);
  }

  Expense copyWith({
    String? id,
    String? lobbyId,
    String? title,
    double? amount,
    String? paidByUserId,
    ExpenseCategory? category,
    SplitType? splitType,
    ExpenseStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ExpenseSplit>? splits,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      lobbyId: lobbyId ?? this.lobbyId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      paidByUserId: paidByUserId ?? this.paidByUserId,
      category: category ?? this.category,
      splitType: splitType ?? this.splitType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      splits: splits ?? this.splits,
      note: note ?? this.note,
    );
  }

  Expense updateStatusFromSplits() {
    ExpenseStatus newStatus;

    if (isFullySettled) {
      newStatus = ExpenseStatus.settled;
    } else if (isPartiallySettled) {
      newStatus = ExpenseStatus.partiallySettled;
    } else {
      newStatus = ExpenseStatus.active;
    }

    return copyWith(status: newStatus, updatedAt: DateTime.now());
  }

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
      splitType: SplitType.values.firstWhere(
        (e) => e.name == map['splitType'],
        orElse: () => SplitType.equal,
      ),
      status: ExpenseStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ExpenseStatus.active,
      ),
      createdAt: map['createdAt'] == null
          ? DateTime.now()
          : DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] == null
          ? DateTime.now()
          : DateTime.parse(map['updatedAt']),
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
      'splitType': splitType.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'splits': splits.map((x) => x.toMap()).toList(),
      'note': note,
    };
  }
}
