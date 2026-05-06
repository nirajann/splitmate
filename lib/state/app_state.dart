import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/activity_log.dart';
import '../models/app_user.dart';
import '../models/expense.dart';
import '../models/expense_split.dart';
import '../models/lobby.dart';

/// Represents a user's balance against the current user.
/// Example:
/// - owesYou = true  => friend owes current user
/// - owesYou = false => current user owes friend
class FriendBalance {
  final AppUser user;
  final double amount;
  final bool owesYou;

  const FriendBalance({
    required this.user,
    required this.amount,
    required this.owesYou,
  });
}

/// Summary numbers for a single lobby/group.
class LobbyBalanceSummary {
  final double totalSpent;
  final double youOwe;
  final double youAreOwed;
  final bool isSettled;

  const LobbyBalanceSummary({
    required this.totalSpent,
    required this.youOwe,
    required this.youAreOwed,
    required this.isSettled,
  });
}

/// Used when creating a custom split expense.
/// Example:
/// CustomSplitInput(userId: 'u1', amount: 70)
/// CustomSplitInput(userId: 'u2', amount: 30)
class CustomSplitInput {
  final String userId;
  final double amount;

  const CustomSplitInput({required this.userId, required this.amount});
}

/// Main local state manager for SplitMate.
///
/// For now this uses in-memory dummy data.
/// Later this same structure can be connected to Firebase/Firestore.
class AppState extends ChangeNotifier {
  AppUser currentUser = DummyData.currentUser;

  final List<AppUser> users = List<AppUser>.from(DummyData.users);
  final List<Lobby> lobbies = List<Lobby>.from(DummyData.lobbies);
  final List<Expense> expenses = List<Expense>.from(DummyData.expenses);
  final List<ActivityLog> activityLogs = List<ActivityLog>.from(
    DummyData.activityLogs,
  );

  // ---------------------------------------------------------------------------
  // Basic getters
  // ---------------------------------------------------------------------------

  /// Finds a user by ID.
  /// If user is missing, current user is returned as safe fallback.
  AppUser userById(String userId) {
    return users.firstWhere(
      (user) => user.id == userId,
      orElse: () => currentUser,
    );
  }

  /// All lobbies where the current user is a member.
  List<Lobby> get currentUserLobbies {
    return lobbies
        .where((lobby) => lobby.memberIds.contains(currentUser.id))
        .toList();
  }

  /// Gets expenses for one lobby, newest first.
  List<Expense> expensesByLobby(String lobbyId) {
    final result = expenses
        .where((expense) => expense.lobbyId == lobbyId)
        .toList();

    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return result;
  }

  /// Gets activity logs for one lobby, newest first.
  List<ActivityLog> logsByLobby(String lobbyId) {
    final result = activityLogs.where((log) => log.lobbyId == lobbyId).toList();

    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return result;
  }

  /// Converts lobby member IDs into full AppUser objects.
  List<AppUser> membersByLobby(Lobby lobby) {
    return lobby.memberIds.map(userById).toList();
  }

  /// Recent expenses for home screen.
  List<Expense> get recentExpenses {
    final sorted = List<Expense>.from(expenses);

    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sorted.take(5).toList();
  }

  // ---------------------------------------------------------------------------
  // Balance calculations
  // ---------------------------------------------------------------------------

  /// Total amount current user owes to other people.
  double get totalYouOwe {
    double total = 0;

    for (final expense in expenses) {
      if (expense.paidByUserId == currentUser.id) continue;

      final currentUserSplit = _splitForUser(expense, currentUser.id);

      if (currentUserSplit != null && !currentUserSplit.isPaid) {
        total += currentUserSplit.amount;
      }
    }

    return _roundMoney(total);
  }

  /// Total amount other people owe current user.
  double get totalYouAreOwed {
    double total = 0;

    for (final expense in expenses) {
      if (expense.paidByUserId != currentUser.id) continue;

      for (final split in expense.splits) {
        if (split.userId != currentUser.id && !split.isPaid) {
          total += split.amount;
        }
      }
    }

    return _roundMoney(total);
  }

  /// Lobby-level summary.
  LobbyBalanceSummary lobbySummary(String lobbyId) {
    final lobbyExpenses = expensesByLobby(lobbyId);

    double totalSpent = 0;
    double youOwe = 0;
    double youAreOwed = 0;

    for (final expense in lobbyExpenses) {
      totalSpent += expense.amount;

      final currentUserSplit = _splitForUser(expense, currentUser.id);

      final currentUserDidNotPay = expense.paidByUserId != currentUser.id;

      if (currentUserDidNotPay &&
          currentUserSplit != null &&
          !currentUserSplit.isPaid) {
        youOwe += currentUserSplit.amount;
      }

      final currentUserPaid = expense.paidByUserId == currentUser.id;

      if (currentUserPaid) {
        for (final split in expense.splits) {
          if (split.userId != currentUser.id && !split.isPaid) {
            youAreOwed += split.amount;
          }
        }
      }
    }

    final roundedYouOwe = _roundMoney(youOwe);
    final roundedYouAreOwed = _roundMoney(youAreOwed);

    return LobbyBalanceSummary(
      totalSpent: _roundMoney(totalSpent),
      youOwe: roundedYouOwe,
      youAreOwed: roundedYouAreOwed,
      isSettled: roundedYouOwe == 0 && roundedYouAreOwed == 0,
    );
  }

  /// Friend balance list for home screen.
  List<FriendBalance> friendBalances() {
    final Map<String, double> balanceMap = {};

    for (final expense in expenses) {
      final currentUserPaid = expense.paidByUserId == currentUser.id;
      final currentUserSplit = _splitForUser(expense, currentUser.id);

      if (currentUserPaid) {
        for (final split in expense.splits) {
          if (split.userId == currentUser.id || split.isPaid) continue;

          balanceMap[split.userId] =
              (balanceMap[split.userId] ?? 0) + split.amount;
        }
      } else if (currentUserSplit != null && !currentUserSplit.isPaid) {
        final payerId = expense.paidByUserId;

        balanceMap[payerId] =
            (balanceMap[payerId] ?? 0) - currentUserSplit.amount;
      }
    }

    final balances = balanceMap.entries
        .where((entry) => _roundMoney(entry.value) != 0)
        .map(
          (entry) => FriendBalance(
            user: userById(entry.key),
            amount: _roundMoney(entry.value.abs()),
            owesYou: entry.value > 0,
          ),
        )
        .toList();

    balances.sort((a, b) => b.amount.compareTo(a.amount));

    return balances;
  }

  /// Text shown on expense cards.
  String expenseStatusText(Expense expense) {
    final currentUserPaid = expense.paidByUserId == currentUser.id;
    final currentUserSplit = _splitForUser(expense, currentUser.id);

    if (currentUserPaid) {
      double owed = 0;

      for (final split in expense.splits) {
        if (split.userId != currentUser.id && !split.isPaid) {
          owed += split.amount;
        }
      }

      owed = _roundMoney(owed);

      if (owed <= 0) return 'Settled up';

      return 'You are owed \$${owed.toStringAsFixed(2)}';
    }

    if (currentUserSplit != null && !currentUserSplit.isPaid) {
      return 'You owe \$${currentUserSplit.amount.toStringAsFixed(2)}';
    }

    return 'Not involved';
  }

  /// Used by UI to decide red/green chip color.
  bool expenseIsPositiveForCurrentUser(Expense expense) {
    return expense.paidByUserId == currentUser.id;
  }

  /// Returns all unpaid splits for a specific expense.
  List<ExpenseSplit> unpaidSplitsForExpense(String expenseId) {
    final expense = expenses.firstWhere((item) => item.id == expenseId);

    return expense.splits.where((split) {
      final isPayer = split.userId == expense.paidByUserId;
      return !isPayer && !split.isPaid;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Lobby features
  // ---------------------------------------------------------------------------

  /// Creates a lobby.
  ///
  /// Important:
  /// invitedPeople are handled by CreateLobbyScreen after lobby creation,
  /// because we need the new lobby ID first.
  void createLobby({
    required String name,
    required String description,
    List<String> invitedPeople = const [],
  }) {
    final cleanName = name.trim();

    if (cleanName.isEmpty) return;

    final now = DateTime.now();
    final newLobbyId = 'l${now.microsecondsSinceEpoch}';

    final invitePrefix = cleanName
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '')
        .padRight(4, 'X')
        .substring(0, 4);

    final newLobby = Lobby(
      id: newLobbyId,
      name: cleanName,
      description: description.trim().isEmpty
          ? 'Shared expenses with friends.'
          : description.trim(),
      createdByUserId: currentUser.id,
      memberIds: [currentUser.id],
      inviteCode: '$invitePrefix${now.second}',
      createdAt: now,
    );

    lobbies.insert(0, newLobby);

    _addActivity(
      lobbyId: newLobbyId,
      type: ActivityType.lobbyCreated,
      message: '${currentUser.name} created ${newLobby.name} lobby.',
      createdAt: now,
    );

    notifyListeners();
  }

  /// Adds a new or existing user to a lobby.
  ///
  /// If name/email already exists in users, that user is reused.
  /// Otherwise, a temporary local user is created.
  bool addMemberToLobby({
    required String lobbyId,
    required String nameOrEmail,
  }) {
    final trimmed = nameOrEmail.trim();

    if (trimmed.isEmpty) return false;

    final lobbyIndex = lobbies.indexWhere((lobby) => lobby.id == lobbyId);

    if (lobbyIndex == -1) return false;

    final oldLobby = lobbies[lobbyIndex];
    final normalizedInput = trimmed.toLowerCase();

    AppUser? existingUser;

    for (final user in users) {
      final sameEmail = user.email.toLowerCase() == normalizedInput;
      final sameName = user.name.toLowerCase() == normalizedInput;

      if (sameEmail || sameName) {
        existingUser = user;
        break;
      }
    }

    final AppUser userToAdd;

    if (existingUser != null) {
      userToAdd = existingUser;
    } else {
      final newUserId = 'u${DateTime.now().microsecondsSinceEpoch}';

      userToAdd = AppUser(
        id: newUserId,
        name: trimmed.contains('@') ? trimmed.split('@').first : trimmed,
        email: trimmed.contains('@')
            ? trimmed
            : '${trimmed.toLowerCase().replaceAll(' ', '')}@splitmate.app',
      );

      users.add(userToAdd);
    }

    if (oldLobby.memberIds.contains(userToAdd.id)) return false;

    lobbies[lobbyIndex] = oldLobby.copyWith(
      memberIds: [...oldLobby.memberIds, userToAdd.id],
    );

    _addActivity(
      lobbyId: lobbyId,
      type: ActivityType.memberAdded,
      message: '${userToAdd.name} joined ${oldLobby.name}.',
    );

    notifyListeners();

    return true;
  }

  /// Removes a member from lobby.
  ///
  /// Safety rules:
  /// - Owner cannot be removed.
  /// - Member cannot be removed while they still owe unpaid money.
  bool removeMemberFromLobby({
    required String lobbyId,
    required String userId,
  }) {
    final lobbyIndex = lobbies.indexWhere((lobby) => lobby.id == lobbyId);

    if (lobbyIndex == -1) return false;

    final lobby = lobbies[lobbyIndex];

    if (userId == lobby.createdByUserId) return false;

    final hasUnpaidSplits = expenses.any((expense) {
      if (expense.lobbyId != lobbyId) return false;

      return expense.splits.any((split) {
        return split.userId == userId && !split.isPaid && split.amount > 0;
      });
    });

    if (hasUnpaidSplits) return false;

    final removedUser = userById(userId);

    lobbies[lobbyIndex] = lobby.copyWith(
      memberIds: lobby.memberIds.where((id) => id != userId).toList(),
    );

    _addActivity(
      lobbyId: lobbyId,
      type: ActivityType.memberRemoved,
      message: '${removedUser.name} was removed from ${lobby.name}.',
    );

    notifyListeners();

    return true;
  }

  // ---------------------------------------------------------------------------
  // Expense features
  // ---------------------------------------------------------------------------

  /// Adds an equal split expense.
  ///
  /// Example:
  /// $100 with 4 members = $25 each.
  /// Payer's own split is marked paid automatically.
  bool addEqualExpense({
    required String lobbyId,
    required String title,
    required double amount,
    required String paidByUserId,
    ExpenseCategory category = ExpenseCategory.other,
    String? note,
  }) {
    final lobby = _lobbyById(lobbyId);

    if (lobby == null) return false;
    if (lobby.memberIds.isEmpty || amount <= 0 || title.trim().isEmpty) {
      return false;
    }

    if (!lobby.memberIds.contains(paidByUserId)) return false;

    final now = DateTime.now();
    final splitAmount = _roundMoney(amount / lobby.memberIds.length);

    final splits = lobby.memberIds.map((userId) {
      return ExpenseSplit(
        userId: userId,
        amount: splitAmount,
        isPaid: userId == paidByUserId,
        paidAt: userId == paidByUserId ? now : null,
      );
    }).toList();

    _insertExpense(
      lobbyId: lobbyId,
      title: title,
      amount: amount,
      paidByUserId: paidByUserId,
      category: category,
      splitType: SplitType.equal,
      splits: splits,
      note: note,
      createdAt: now,
    );

    return true;
  }

  /// Adds a custom split expense.
  ///
  /// The total of custom split amounts must equal the expense amount.
  /// Example:
  /// amount = 100
  /// customSplits = [u1: 70, u2: 30]
  bool addCustomExpense({
    required String lobbyId,
    required String title,
    required double amount,
    required String paidByUserId,
    required List<CustomSplitInput> customSplits,
    ExpenseCategory category = ExpenseCategory.other,
    String? note,
  }) {
    final lobby = _lobbyById(lobbyId);

    if (lobby == null) return false;
    if (title.trim().isEmpty || amount <= 0 || customSplits.isEmpty) {
      return false;
    }

    if (!lobby.memberIds.contains(paidByUserId)) return false;

    final validSplits = customSplits.where((split) {
      final isMember = lobby.memberIds.contains(split.userId);
      final validAmount = split.amount >= 0;

      return isMember && validAmount;
    }).toList();

    if (validSplits.isEmpty) return false;

    final customTotal = validSplits.fold<double>(
      0,
      (sum, split) => sum + split.amount,
    );

    if (!_moneyEquals(customTotal, amount)) {
      return false;
    }

    final now = DateTime.now();

    final splits = validSplits.map((split) {
      return ExpenseSplit(
        userId: split.userId,
        amount: _roundMoney(split.amount),
        isPaid: split.userId == paidByUserId,
        paidAt: split.userId == paidByUserId ? now : null,
      );
    }).toList();

    _insertExpense(
      lobbyId: lobbyId,
      title: title,
      amount: amount,
      paidByUserId: paidByUserId,
      category: category,
      splitType: SplitType.exact,
      splits: splits,
      note: note,
      createdAt: now,
    );

    return true;
  }

  /// Marks one user's split as paid.
  ///
  /// This does not delete the original expense.
  /// It keeps the history and updates the balance.
  bool settleSplit({required String expenseId, required String userId}) {
    final expenseIndex = expenses.indexWhere(
      (expense) => expense.id == expenseId,
    );

    if (expenseIndex == -1) return false;

    final expense = expenses[expenseIndex];

    if (userId == expense.paidByUserId) return false;

    final targetSplit = _splitForUser(expense, userId);

    if (targetSplit == null || targetSplit.isPaid) return false;

    final now = DateTime.now();

    final updatedSplits = expense.splits.map((split) {
      if (split.userId == userId) {
        return split.copyWith(isPaid: true, paidAt: now);
      }

      return split;
    }).toList();

    final updatedExpense = expense
        .copyWith(splits: updatedSplits, updatedAt: now)
        .updateStatusFromSplits();

    expenses[expenseIndex] = updatedExpense;

    final paidUser = userById(userId);
    final payer = userById(expense.paidByUserId);

    _addActivity(
      lobbyId: expense.lobbyId,
      type: ActivityType.settlementAdded,
      message: '${paidUser.name} settled ${expense.title} with ${payer.name}.',
      createdAt: now,
    );

    notifyListeners();

    return true;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Lobby? _lobbyById(String lobbyId) {
    try {
      return lobbies.firstWhere((lobby) => lobby.id == lobbyId);
    } catch (_) {
      return null;
    }
  }

  ExpenseSplit? _splitForUser(Expense expense, String userId) {
    try {
      return expense.splits.firstWhere((split) => split.userId == userId);
    } catch (_) {
      return null;
    }
  }

  void _insertExpense({
    required String lobbyId,
    required String title,
    required double amount,
    required String paidByUserId,
    required ExpenseCategory category,
    required SplitType splitType,
    required List<ExpenseSplit> splits,
    required DateTime createdAt,
    String? note,
  }) {
    final cleanTitle = title.trim();

    final newExpense = Expense(
      id: 'e${createdAt.microsecondsSinceEpoch}',
      lobbyId: lobbyId,
      title: cleanTitle,
      amount: _roundMoney(amount),
      paidByUserId: paidByUserId,
      category: category,
      splitType: splitType,
      status: ExpenseStatus.active,
      createdAt: createdAt,
      updatedAt: createdAt,
      splits: splits,
      note: note,
    ).updateStatusFromSplits();

    expenses.insert(0, newExpense);

    _addActivity(
      lobbyId: lobbyId,
      type: ActivityType.expenseAdded,
      message:
          '${currentUser.name} added $cleanTitle expense of \$${amount.toStringAsFixed(2)}.',
      createdAt: createdAt,
    );

    notifyListeners();
  }

  void _addActivity({
    required String lobbyId,
    required ActivityType type,
    required String message,
    DateTime? createdAt,
  }) {
    final now = createdAt ?? DateTime.now();

    activityLogs.insert(
      0,
      ActivityLog(
        id: 'a${now.microsecondsSinceEpoch}',
        lobbyId: lobbyId,
        userId: currentUser.id,
        type: type,
        message: message,
        createdAt: now,
      ),
    );
  }

  double _roundMoney(double value) {
    return (value * 100).roundToDouble() / 100;
  }

  bool _moneyEquals(double a, double b) {
    return _roundMoney(a) == _roundMoney(b);
  }
}
