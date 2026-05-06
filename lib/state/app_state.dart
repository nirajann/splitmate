import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/activity_log.dart';
import '../models/app_user.dart';
import '../models/expense.dart';
import '../models/expense_split.dart';
import '../models/lobby.dart';

class FriendBalance {
  final AppUser user;
  final double amount;
  final bool owesYou;

  FriendBalance({
    required this.user,
    required this.amount,
    required this.owesYou,
  });
}

class LobbyBalanceSummary {
  final double totalSpent;
  final double youOwe;
  final double youAreOwed;
  final bool isSettled;

  LobbyBalanceSummary({
    required this.totalSpent,
    required this.youOwe,
    required this.youAreOwed,
    required this.isSettled,
  });
}

class AppState extends ChangeNotifier {
  AppUser currentUser = DummyData.currentUser;

  final List<AppUser> users = List<AppUser>.from(DummyData.users);
  final List<Lobby> lobbies = List<Lobby>.from(DummyData.lobbies);
  final List<Expense> expenses = List<Expense>.from(DummyData.expenses);
  final List<ActivityLog> activityLogs =
  List<ActivityLog>.from(DummyData.activityLogs);

  // -------------------------
  // Basic getters
  // -------------------------

  AppUser userById(String userId) {
    return users.firstWhere(
          (user) => user.id == userId,
      orElse: () => currentUser,
    );
  }

  List<Lobby> get currentUserLobbies {
    return lobbies
        .where((lobby) => lobby.memberIds.contains(currentUser.id))
        .toList();
  }

  List<Expense> expensesByLobby(String lobbyId) {
    return expenses.where((expense) => expense.lobbyId == lobbyId).toList();
  }

  List<ActivityLog> logsByLobby(String lobbyId) {
    return activityLogs.where((log) => log.lobbyId == lobbyId).toList();
  }

  List<AppUser> membersByLobby(Lobby lobby) {
    return lobby.memberIds.map(userById).toList();
  }

  // -------------------------
  // Money calculations
  // -------------------------

  double get totalYouOwe {
    double total = 0;

    for (final expense in expenses) {
      final currentUserSplit = _splitForUser(expense, currentUser.id);

      if (currentUserSplit == null) continue;

      final userDidNotPay = expense.paidByUserId != currentUser.id;

      if (userDidNotPay && !currentUserSplit.isPaid) {
        total += currentUserSplit.amount;
      }
    }

    return total;
  }

  double get totalYouAreOwed {
    double total = 0;

    for (final expense in expenses) {
      final currentUserPaid = expense.paidByUserId == currentUser.id;

      if (!currentUserPaid) continue;

      for (final split in expense.splits) {
        final isOtherUser = split.userId != currentUser.id;

        if (isOtherUser && !split.isPaid) {
          total += split.amount;
        }
      }
    }

    return total;
  }

  LobbyBalanceSummary lobbySummary(String lobbyId) {
    final lobbyExpenses = expensesByLobby(lobbyId);

    double totalSpent = 0;
    double youOwe = 0;
    double youAreOwed = 0;

    for (final expense in lobbyExpenses) {
      totalSpent += expense.amount;

      final currentUserSplit = _splitForUser(expense, currentUser.id);

      if (currentUserSplit != null &&
          expense.paidByUserId != currentUser.id &&
          !currentUserSplit.isPaid) {
        youOwe += currentUserSplit.amount;
      }

      if (expense.paidByUserId == currentUser.id) {
        for (final split in expense.splits) {
          if (split.userId != currentUser.id && !split.isPaid) {
            youAreOwed += split.amount;
          }
        }
      }
    }

    return LobbyBalanceSummary(
      totalSpent: totalSpent,
      youOwe: youOwe,
      youAreOwed: youAreOwed,
      isSettled: youOwe == 0 && youAreOwed == 0,
    );
  }

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
        .where((entry) => entry.value != 0)
        .map(
          (entry) => FriendBalance(
        user: userById(entry.key),
        amount: entry.value.abs(),
        owesYou: entry.value > 0,
      ),
    )
        .toList();

    balances.sort((a, b) => b.amount.compareTo(a.amount));

    return balances;
  }

  List<Expense> get recentExpenses {
    final sorted = List<Expense>.from(expenses);

    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sorted.take(5).toList();
  }

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

      if (owed <= 0) return 'Settled up';

      return 'You are owed \$${owed.toStringAsFixed(2)}';
    }

    if (currentUserSplit != null && !currentUserSplit.isPaid) {
      return 'You owe \$${currentUserSplit.amount.toStringAsFixed(2)}';
    }

    return 'Not involved';
  }

  bool expenseIsPositiveForCurrentUser(Expense expense) {
    return expense.paidByUserId == currentUser.id;
  }

  // -------------------------
  // Create lobby
  // -------------------------

  void createLobby({
    required String name,
    required String description,
    List<String> invitedPeople = const [],
  }) {
    final newLobbyId = 'l${DateTime.now().millisecondsSinceEpoch}';
    final inviteCode = name
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '')
        .padRight(4, 'X')
        .substring(0, 4);

    final newLobby = Lobby(
      id: newLobbyId,
      name: name.trim(),
      description: description.trim().isEmpty
          ? 'Shared expenses with friends.'
          : description.trim(),
      createdByUserId: currentUser.id,
      memberIds: [currentUser.id],
      inviteCode: '$inviteCode${DateTime.now().second}',
      createdAt: DateTime.now(),
    );

    lobbies.insert(0, newLobby);

    activityLogs.insert(
      0,
      ActivityLog(
        id: 'a${DateTime.now().millisecondsSinceEpoch}',
        lobbyId: newLobbyId,
        userId: currentUser.id,
        type: ActivityType.lobbyCreated,
        message: '${currentUser.name} created ${newLobby.name} lobby.',
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  // -------------------------
  // Add equal expense
  // -------------------------

  void addEqualExpense({
    required String lobbyId,
    required String title,
    required double amount,
    required String paidByUserId,
    ExpenseCategory category = ExpenseCategory.other,
    String? note,
  }) {
    final lobby = lobbies.firstWhere((item) => item.id == lobbyId);

    if (lobby.memberIds.isEmpty || amount <= 0) return;

    final splitAmount = amount / lobby.memberIds.length;

    final newExpense = Expense(
      id: 'e${DateTime.now().millisecondsSinceEpoch}',
      lobbyId: lobbyId,
      title: title.trim(),
      amount: amount,
      paidByUserId: paidByUserId,
      category: category,
      createdAt: DateTime.now(),
      splits: lobby.memberIds
          .map(
            (userId) => ExpenseSplit(
          userId: userId,
          amount: splitAmount,
          isPaid: userId == paidByUserId,
        ),
      )
          .toList(),
      note: note,
    );

    expenses.insert(0, newExpense);

    activityLogs.insert(
      0,
      ActivityLog(
        id: 'a${DateTime.now().millisecondsSinceEpoch}',
        lobbyId: lobbyId,
        userId: currentUser.id,
        type: ActivityType.expenseAdded,
        message: '${currentUser.name} added $title expense.',
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  // -------------------------
  // Add member
  // -------------------------

  void addMemberToLobby({
    required String lobbyId,
    required String nameOrEmail,
  }) {
    final trimmed = nameOrEmail.trim();

    if (trimmed.isEmpty) return;

    final newUserId = 'u${DateTime.now().millisecondsSinceEpoch}';

    final newUser = AppUser(
      id: newUserId,
      name: trimmed.contains('@') ? trimmed.split('@').first : trimmed,
      email: trimmed.contains('@')
          ? trimmed
          : '${trimmed.toLowerCase().replaceAll(' ', '')}@splitmate.app',
    );

    users.add(newUser);

    final lobbyIndex = lobbies.indexWhere((lobby) => lobby.id == lobbyId);

    if (lobbyIndex == -1) return;

    final oldLobby = lobbies[lobbyIndex];

    if (oldLobby.memberIds.contains(newUserId)) return;

    lobbies[lobbyIndex] = Lobby(
      id: oldLobby.id,
      name: oldLobby.name,
      description: oldLobby.description,
      createdByUserId: oldLobby.createdByUserId,
      memberIds: [...oldLobby.memberIds, newUserId],
      inviteCode: oldLobby.inviteCode,
      createdAt: oldLobby.createdAt,
    );

    activityLogs.insert(
      0,
      ActivityLog(
        id: 'a${DateTime.now().millisecondsSinceEpoch}',
        lobbyId: lobbyId,
        userId: currentUser.id,
        type: ActivityType.memberAdded,
        message: '${newUser.name} joined ${oldLobby.name}.',
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  // -------------------------
  // Helpers
  // -------------------------

  ExpenseSplit? _splitForUser(Expense expense, String userId) {
    try {
      return expense.splits.firstWhere((split) => split.userId == userId);
    } catch (_) {
      return null;
    }
  }
}