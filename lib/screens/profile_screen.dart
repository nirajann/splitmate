import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _money(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    final friends = appState.friendBalances();
    final lobbies = appState.currentUserLobbies;

    return Scaffold(
      backgroundColor: AppColors.orange,
      body: Container(
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
              _header(user),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 95),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFAF0),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(34),
                    ),
                  ),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _profileCard(appState, user),
                      const SizedBox(height: 20),

                      _sectionTitle('Account Summary'),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _smallStatCard(
                              title: 'Lobbies',
                              value: '${lobbies.length}',
                              icon: Icons.groups_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _smallStatCard(
                              title: 'Friends',
                              value: '${friends.length}',
                              icon: Icons.people_alt_rounded,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _moneyStatCard(
                              title: 'You owe',
                              value: appState.totalYouOwe,
                              positive: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _moneyStatCard(
                              title: 'Owed to you',
                              value: appState.totalYouAreOwed,
                              positive: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _sectionTitle('Friends'),
                      const SizedBox(height: 12),

                      if (friends.isEmpty)
                        _emptyCard()
                      else
                        ...friends.map((friend) {
                          return _friendTile(
                            context: context,
                            appState: appState,
                            friend: friend,
                          );
                        }),

                      const SizedBox(height: 24),

                      _sectionTitle('Account'),
                      const SizedBox(height: 12),

                      _menuTile(
                        icon: Icons.verified_user_rounded,
                        title: 'Login status',
                        subtitle: 'Logged in locally for demo',
                        onTap: () {},
                      ),
                      _menuTile(
                        icon: Icons.notifications_rounded,
                        title: 'Notifications',
                        subtitle: 'Payment reminders later with Firebase',
                        onTap: () {},
                      ),
                      _menuTile(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        subtitle: 'Authentication flow will be connected later',
                        danger: true,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Logout will be connected with SharedPreferences/AuthService next.',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(AppUser user) {
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person_rounded,
              color: AppColors.orange,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ),
          CircleAvatar(
            radius: 21,
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

  Widget _profileCard(AppState appState, AppUser user) {
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFFFFF0D0),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.orange,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user.email,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Local demo account',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _smallStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _whiteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.orange),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.greyText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _moneyStatCard({
    required String title,
    required double value,
    required bool positive,
  }) {
    final color = positive ? AppColors.green : AppColors.red;
    final bg = positive ? AppColors.greenLight : AppColors.redLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            positive ? Icons.south_west_rounded : Icons.north_east_rounded,
            color: color,
          ),
          const SizedBox(height: 10),
          Text(
            _money(value),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _friendTile({
    required BuildContext context,
    required AppState appState,
    required FriendBalance friend,
  }) {
    final user = friend.user;
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: () => _showFriendProfile(context, appState, friend),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: _whiteCardDecoration(),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor:
              friend.owesYou ? AppColors.greenLight : AppColors.redLight,
              child: Text(
                initial,
                style: TextStyle(
                  color: friend.owesYou ? AppColors.green : AppColors.red,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    friend.owesYou
                        ? 'Owes you ${_money(friend.amount)}'
                        : 'You owe ${_money(friend.amount)}',
                    style: TextStyle(
                      color: friend.owesYou ? AppColors.green : AppColors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  void _showFriendProfile(
      BuildContext context,
      AppState appState,
      FriendBalance friend,
      ) {
    final user = friend.user;
    final relatedExpenses = appState.expenses.where((expense) {
      final hasFriend = expense.splits.any((split) => split.userId == user.id);
      final friendPaid = expense.paidByUserId == user.id;
      final currentUserPaid = expense.paidByUserId == appState.currentUser.id;

      return hasFriend || friendPaid || currentUserPaid;
    }).toList();

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
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFFFFF0D0),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: AppColors.orange,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: friend.owesYou
                      ? AppColors.greenLight
                      : AppColors.redLight,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  friend.owesYou
                      ? '${user.name} owes you ${_money(friend.amount)}'
                      : 'You owe ${user.name} ${_money(friend.amount)}',
                  style: TextStyle(
                    color: friend.owesYou ? AppColors.green : AppColors.red,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Related expenses',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              if (relatedExpenses.isEmpty)
                const Text(
                  'No related expenses yet.',
                  style: TextStyle(color: AppColors.greyText),
                )
              else
                ...relatedExpenses.take(6).map((expense) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFFFF0D0),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: AppColors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            expense.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          _money(expense.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: _whiteCardDecoration(),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
              danger ? AppColors.redLight : const Color(0xFFFFF0D0),
              child: Icon(
                icon,
                color: danger ? AppColors.red : AppColors.orange,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: danger ? AppColors.red : Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.greyText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _whiteCardDecoration(),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFFFFF0D0),
            child: Icon(Icons.people_alt_rounded, color: AppColors.orange),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Friends will appear after you share expenses with members.',
              style: TextStyle(
                color: AppColors.greyText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _whiteCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.045),
          blurRadius: 14,
          offset: const Offset(0, 7),
        ),
      ],
    );
  }
}