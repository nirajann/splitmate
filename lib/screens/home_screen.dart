import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../models/expense.dart';
import '../models/expense_split.dart';
import '../models/lobby.dart';
import '../screens/add_expense_screen.dart';
import '../screens/create_lobby_screen.dart';
import '../screens/lobby_detail_screen.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/balance_box.dart';
import '../widgets/friend_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ---------------------------------------------------------------------------
  // Small format helpers
  // ---------------------------------------------------------------------------

  String _money(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  String _date(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  IconData _categoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.fastfood_rounded;
      case ExpenseCategory.travel:
        return Icons.flight_takeoff_rounded;
      case ExpenseCategory.rent:
        return Icons.home_rounded;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_rounded;
      case ExpenseCategory.bills:
        return Icons.receipt_long_rounded;
      case ExpenseCategory.entertainment:
        return Icons.celebration_rounded;
      case ExpenseCategory.hotel:
        return Icons.hotel_rounded;
      case ExpenseCategory.gift:
        return Icons.card_giftcard_rounded;
      case ExpenseCategory.utilities:
        return Icons.lightbulb_rounded;
      case ExpenseCategory.other:
        return Icons.category_rounded;
    }
  }

  Lobby? _lobbyForExpense(AppState appState, Expense expense) {
    for (final lobby in appState.lobbies) {
      if (lobby.id == expense.lobbyId) return lobby;
    }

    return null;
  }

  List<Expense> _pendingExpensesForCurrentUser(AppState appState) {
    return appState.expenses.where((expense) {
      final status = appState.expenseStatusText(expense);
      return status != 'Not involved' && status != 'Settled up';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final lobbies = appState.currentUserLobbies;
    final pendingExpenses = _pendingExpensesForCurrentUser(appState);
    final recentExpenses = appState.recentExpenses;
    final friends = appState.friendBalances();

    return Container(
      key: const ValueKey('home'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.orange, AppColors.orangeLight],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(context, appState),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: BalanceBox(
                      amount: _money(appState.totalYouOwe),
                      label: 'You Owe',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: BalanceBox(
                      amount: _money(appState.totalYouAreOwed),
                      label: 'Owes you',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 95),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFAF0),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                ),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    _quickActions(context),
                    const SizedBox(height: 22),

                    _sectionTitle(
                      title: 'My Lobbies',
                      action: 'Create',
                      onAction: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateLobbyScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    if (lobbies.isEmpty)
                      _emptyCard(
                        icon: Icons.groups_rounded,
                        title: 'No lobbies yet',
                        message: 'Create a lobby to start splitting expenses.',
                      )
                    else
                      _lobbyScroller(context, appState, lobbies),

                    const SizedBox(height: 22),

                    _sectionTitle(title: 'Pending Actions', action: ''),
                    const SizedBox(height: 12),

                    if (pendingExpenses.isEmpty)
                      _emptyCard(
                        icon: Icons.check_circle_rounded,
                        title: 'All settled',
                        message: 'You have no pending payments right now.',
                      )
                    else
                      ...pendingExpenses.take(3).map((expense) {
                        return _pendingActionCard(context, appState, expense);
                      }),

                    const SizedBox(height: 22),

                    _sectionTitle(title: 'Recent Expenses', action: ''),
                    const SizedBox(height: 12),

                    if (recentExpenses.isEmpty)
                      _emptyCard(
                        icon: Icons.receipt_long_rounded,
                        title: 'No expenses yet',
                        message:
                            'Add your first bill, food, rent, or trip expense.',
                      )
                    else
                      ...recentExpenses.take(4).map((expense) {
                        return _expenseCard(context, appState, expense);
                      }),

                    const SizedBox(height: 22),

                    _sectionTitle(title: 'Friends', action: ''),
                    const SizedBox(height: 12),

                    if (friends.isEmpty)
                      _emptyCard(
                        icon: Icons.people_alt_rounded,
                        title: 'No friend balances',
                        message:
                            'Friend balances will appear after shared expenses.',
                      )
                    else
                      ...friends.take(4).map((friend) {
                        return FriendCard(
                          name: friend.user.name,
                          avatar: friend.user.name.isNotEmpty
                              ? friend.user.name[0].toUpperCase()
                              : '?',
                          subtitle: friend.owesYou
                              ? 'Owes you ${_money(friend.amount)}'
                              : 'You owe ${_money(friend.amount)}',
                          positive: friend.owesYou,
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header and quick actions
  // ---------------------------------------------------------------------------

  Widget _header(BuildContext context, AppState appState) {
    final currentUser = appState.currentUser;
    final initial = currentUser.name.isNotEmpty
        ? currentUser.name[0].toUpperCase()
        : 'U';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.pie_chart_rounded,
              color: AppColors.orange,
              size: 23,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'SplitMate',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.orange,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _quickActionButton(
            icon: Icons.add_rounded,
            label: 'Expense',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickActionButton(
            icon: Icons.groups_rounded,
            label: 'Lobby',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateLobbyScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickActionButton(
            icon: Icons.qr_code_2_rounded,
            label: 'Invite',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Invite link will be connected with Firebase later.',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.orange),
            const SizedBox(height: 7),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Lobby section
  // ---------------------------------------------------------------------------

  Widget _lobbyScroller(
    BuildContext context,
    AppState appState,
    List<Lobby> lobbies,
  ) {
    return SizedBox(
      height: 138,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: lobbies.length,
        itemBuilder: (context, index) {
          final lobby = lobbies[index];
          final summary = appState.lobbySummary(lobby.id);

          final balanceText = summary.youOwe > 0
              ? 'You owe ${_money(summary.youOwe)}'
              : summary.youAreOwed > 0
              ? 'Owed ${_money(summary.youAreOwed)}'
              : 'Settled';

          final balanceColor = summary.youOwe > 0
              ? AppColors.red
              : summary.youAreOwed > 0
              ? AppColors.green
              : AppColors.greyText;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LobbyDetailScreen(lobby: lobby),
                ),
              );
            },
            child: Container(
              width: 210,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 17,
                        backgroundColor: Color(0xFFFFF0D0),
                        child: Icon(
                          Icons.groups_rounded,
                          color: AppColors.orange,
                          size: 18,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${lobby.memberIds.length} members',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    lobby.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_money(summary.totalSpent)} total',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    balanceText,
                    style: TextStyle(
                      color: balanceColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Pending and recent expense cards
  // ---------------------------------------------------------------------------

  Widget _pendingActionCard(
    BuildContext context,
    AppState appState,
    Expense expense,
  ) {
    final lobby = _lobbyForExpense(appState, expense);
    final status = appState.expenseStatusText(expense);
    final payer = appState.userById(expense.paidByUserId);

    final isPositive = appState.expenseIsPositiveForCurrentUser(expense);
    final statusParts = _splitStatus(status);

    return GestureDetector(
      onTap: () => _showExpenseDetails(context, appState, expense),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: const Color(0xFFFFF0D0),
              child: Icon(
                _categoryIcon(expense.category),
                color: AppColors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${lobby?.name ?? 'Unknown lobby'} • Paid by ${payer.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.greyText,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? AppColors.greenLight
                          : AppColors.redLight,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Text(
                          statusParts.$1,
                          style: TextStyle(
                            color: isPositive ? AppColors.green : AppColors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          statusParts.$2,
                          style: TextStyle(
                            color: isPositive ? AppColors.green : AppColors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _money(expense.amount),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _expenseCard(
    BuildContext context,
    AppState appState,
    Expense expense,
  ) {
    final lobby = _lobbyForExpense(appState, expense);
    final payer = appState.userById(expense.paidByUserId);
    final status = appState.expenseStatusText(expense);

    final isPositive = appState.expenseIsPositiveForCurrentUser(expense);

    final chipColor = status == 'Settled up' || status == 'Not involved'
        ? AppColors.greyText
        : isPositive
        ? AppColors.green
        : AppColors.red;

    return GestureDetector(
      onTap: () => _showExpenseDetails(context, appState, expense),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: const Color(0xFFFFF0D0),
              child: Icon(
                _categoryIcon(expense.category),
                color: AppColors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${lobby?.name ?? 'Unknown lobby'} • Paid by ${payer.name}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.greyText,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    status,
                    style: TextStyle(
                      color: chipColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _money(expense.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _date(expense.createdAt),
                  style: const TextStyle(
                    color: AppColors.greyText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Expense detail bottom sheet
  // ---------------------------------------------------------------------------

  void _showExpenseDetails(
    BuildContext context,
    AppState appState,
    Expense expense,
  ) {
    final lobby = _lobbyForExpense(appState, expense);
    final payer = appState.userById(expense.paidByUserId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFAF0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            22,
            22,
            MediaQuery.of(context).viewInsets.bottom + 22,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFFFF0D0),
                    child: Icon(
                      _categoryIcon(expense.category),
                      color: AppColors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      expense.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Text(
                    _money(expense.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${lobby?.name ?? 'Unknown lobby'} • Paid by ${payer.name}',
                style: const TextStyle(
                  color: AppColors.greyText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Split details',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 10),
              ...expense.splits.map((split) {
                return _splitRow(context, appState, expense, split);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _splitRow(
    BuildContext context,
    AppState appState,
    Expense expense,
    ExpenseSplit split,
  ) {
    final user = appState.userById(split.userId);
    final isPayer = split.userId == expense.paidByUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFF0D0),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.orange,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _money(split.amount),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              if (isPayer)
                const Text(
                  'Paid',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                )
              else if (split.isPaid)
                const Text(
                  'Settled',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    final success = appState.settleSplit(
                      expenseId: expense.id,
                      userId: split.userId,
                    );

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? '${user.name} marked as settled.'
                              : 'Could not settle this split.',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Settle',
                    style: TextStyle(
                      color: AppColors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared UI helpers
  // ---------------------------------------------------------------------------

  Widget _sectionTitle({
    required String title,
    required String action,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const Spacer(),
        if (action.isNotEmpty)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action,
              style: const TextStyle(
                color: AppColors.orange,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _emptyCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFF0D0),
            child: Icon(icon, color: AppColors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.greyText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (String, String) _splitStatus(String status) {
    if (status.startsWith('You are owed')) {
      return ('You are owed', status.replaceFirst('You are owed ', ''));
    }

    if (status.startsWith('You owe')) {
      return ('You owe', status.replaceFirst('You owe ', ''));
    }

    return (status, '');
  }
}
