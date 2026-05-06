import '../models/app_user.dart';
import '../models/lobby.dart';
import '../models/expense.dart';
import '../models/expense_split.dart';
import '../models/activity_log.dart';

class DummyData {
  static final users = [
    AppUser(
      id: 'u1',
      name: 'Prince Sah',
      email: 'prince@example.com',
      phone: '+61400000001',
    ),
    AppUser(
      id: 'u2',
      name: 'Kashish Sah',
      email: 'kashish@example.com',
      phone: '+61400000002',
    ),
    AppUser(
      id: 'u3',
      name: 'Wade Howard',
      email: 'wade@example.com',
    ),
    AppUser(
      id: 'u4',
      name: 'Guy Warren',
      email: 'guy@example.com',
    ),
  ];

  static final lobbies = [
    Lobby(
      id: 'l1',
      name: 'Sydney Roommates',
      description: 'Rent, groceries, bills and shared home expenses.',
      createdByUserId: 'u1',
      memberIds: ['u1', 'u2', 'u3'],
      inviteCode: 'ROOM123',
      createdAt: DateTime(2026, 5, 1),
    ),
    Lobby(
      id: 'l2',
      name: 'Melbourne Trip',
      description: 'Hotel, food, petrol and travel expenses.',
      createdByUserId: 'u1',
      memberIds: ['u1', 'u2', 'u4'],
      inviteCode: 'TRIP456',
      createdAt: DateTime(2026, 5, 2),
    ),
  ];

  static final expenses = [
    Expense(
      id: 'e1',
      lobbyId: 'l1',
      title: 'Groceries',
      amount: 120.00,
      paidByUserId: 'u1',
      category: ExpenseCategory.food,
      createdAt: DateTime(2026, 5, 2),
      splits: [
        ExpenseSplit(userId: 'u1', amount: 40),
        ExpenseSplit(userId: 'u2', amount: 40),
        ExpenseSplit(userId: 'u3', amount: 40),
      ],
      note: 'Weekly grocery shopping.',
    ),
    Expense(
      id: 'e2',
      lobbyId: 'l1',
      title: 'Electricity Bill',
      amount: 210.00,
      paidByUserId: 'u2',
      category: ExpenseCategory.bills,
      createdAt: DateTime(2026, 5, 3),
      splits: [
        ExpenseSplit(userId: 'u1', amount: 70),
        ExpenseSplit(userId: 'u2', amount: 70),
        ExpenseSplit(userId: 'u3', amount: 70),
      ],
    ),
    Expense(
      id: 'e3',
      lobbyId: 'l2',
      title: 'Hotel Booking',
      amount: 600.00,
      paidByUserId: 'u1',
      category: ExpenseCategory.travel,
      createdAt: DateTime(2026, 5, 3),
      splits: [
        ExpenseSplit(userId: 'u1', amount: 200),
        ExpenseSplit(userId: 'u2', amount: 200),
        ExpenseSplit(userId: 'u4', amount: 200),
      ],
    ),
  ];

  static final activityLogs = [
    ActivityLog(
      id: 'a1',
      lobbyId: 'l1',
      userId: 'u1',
      type: ActivityType.lobbyCreated,
      message: 'Prince created Sydney Roommates lobby.',
      createdAt: DateTime(2026, 5, 1),
    ),
    ActivityLog(
      id: 'a2',
      lobbyId: 'l1',
      userId: 'u1',
      type: ActivityType.expenseAdded,
      message: 'Prince added Groceries expense.',
      createdAt: DateTime(2026, 5, 2),
    ),
    ActivityLog(
      id: 'a3',
      lobbyId: 'l2',
      userId: 'u1',
      type: ActivityType.expenseAdded,
      message: 'Prince added Hotel Booking expense.',
      createdAt: DateTime(2026, 5, 3),
    ),
  ];

  static AppUser get currentUser => users.first;

  static List<Expense> expensesByLobby(String lobbyId) {
    return expenses.where((expense) => expense.lobbyId == lobbyId).toList();
  }

  static List<ActivityLog> logsByLobby(String lobbyId) {
    return activityLogs.where((log) => log.lobbyId == lobbyId).toList();
  }

  static AppUser userById(String userId) {
    return users.firstWhere(
          (user) => user.id == userId,
      orElse: () => users.first,
    );
  }
}