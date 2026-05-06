import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/balance_box.dart';
import '../widgets/bill_card.dart';
import '../widgets/friend_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

  String _categoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return '🍔';
      case ExpenseCategory.travel:
        return '✈️';
      case ExpenseCategory.rent:
        return '🏠';
      case ExpenseCategory.shopping:
        return '🛍️';
      case ExpenseCategory.bills:
        return '💡';
      case ExpenseCategory.entertainment:
        return '🎬';
      case ExpenseCategory.other:
        return '🧾';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
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
            _header(appState),
            const SizedBox(height: 22),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
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

            const SizedBox(height: 26),

            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 95),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFAF0),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(34),
                  ),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _sectionTitle('Pending Bills', 'View All'),
                    const SizedBox(height: 14),

                    if (recentExpenses.isEmpty)
                      _emptyCard(
                        icon: Icons.receipt_long_rounded,
                        title: 'No expenses yet',
                        message: 'Create a lobby and add your first expense.',
                      )
                    else
                      ...recentExpenses.take(3).map((expense) {
                        final status = appState.expenseStatusText(expense);
                        final isPositive =
                        appState.expenseIsPositiveForCurrentUser(expense);
                        final statusParts = _splitStatus(status);

                        return BillCard(
                          title: expense.title,
                          date: _date(expense.createdAt),
                          amount: _money(expense.amount),
                          status: statusParts.$1,
                          statusAmount: statusParts.$2,
                          isPositive: isPositive,
                          icon: _categoryIcon(expense.category),
                        );
                      }),

                    const SizedBox(height: 18),

                    _sectionTitle('Friends', ''),
                    const SizedBox(height: 12),

                    if (friends.isEmpty)
                      _emptyCard(
                        icon: Icons.people_alt_rounded,
                        title: 'All settled',
                        message: 'No pending friend balances right now.',
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

  Widget _header(AppState appState) {
    final currentUser = appState.currentUser;
    final initial =
    currentUser.name.isNotEmpty ? currentUser.name[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
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
          const Text(
            'SplitMate',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const Spacer(),
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

  Widget _sectionTitle(String title, String action) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        if (action.isNotEmpty)
          Text(
            action,
            style: const TextStyle(
              color: AppColors.orange,
              fontWeight: FontWeight.w700,
              fontSize: 12,
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
                  style: const TextStyle(fontWeight: FontWeight.w800),
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