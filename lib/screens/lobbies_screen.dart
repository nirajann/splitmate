import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lobby.dart';
import '../screens/create_lobby_screen.dart';
import '../screens/lobby_detail_screen.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_avatar.dart';
import '../widgets/status_pill.dart';

class LobbiesScreen extends StatelessWidget {
  const LobbiesScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lobbies = appState.currentUserLobbies;
    final currentUser = appState.currentUser;

    return Scaffold(
      backgroundColor: AppColors.orange,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.orange,
              AppColors.orangeLight,
              Color(0xFFFFC65A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Groups',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(height: 4),
                        ],
                      ),
                    ),
                    AppAvatar(name: currentUser.name, size: 38),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                child: Row(
                  children: [
                    Text(
                      'You are in ${lobbies.length} groups.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateLobbyScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: AppColors.orange,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Create',
                              style: TextStyle(
                                color: AppColors.orange,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 95),
                  child: lobbies.isEmpty
                      ? _emptyState(context)
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: lobbies.length,
                          itemBuilder: (context, index) {
                            return _groupCard(
                              context: context,
                              appState: appState,
                              lobby: lobbies[index],
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _groupCard({
    required BuildContext context,
    required AppState appState,
    required Lobby lobby,
  }) {
    final summary = appState.lobbySummary(lobby.id);
    final debts = appState.simplifiedDebtsForLobby(lobby.id);

    final statusTone = summary.youOwe > 0
        ? StatusPillTone.negative
        : summary.youAreOwed > 0
        ? StatusPillTone.positive
        : StatusPillTone.neutral;

    final statusLabel = summary.youOwe > 0
        ? 'You owe'
        : summary.youAreOwed > 0
        ? 'You are owed'
        : 'Settled up';

    final statusAmount = summary.youOwe > 0
        ? _money(summary.youOwe)
        : summary.youAreOwed > 0
        ? _money(summary.youAreOwed)
        : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LobbyDetailScreen(lobby: lobby)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EEFF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.workspaces_rounded,
                    color: AppColors.orange,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lobby.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _date(lobby.createdAt),
                        style: const TextStyle(
                          color: AppColors.greyText,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  _money(summary.totalSpent),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            if (debts.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFF1EBE0)),
              const SizedBox(height: 10),

              ...debts.take(2).map((debt) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      AppAvatar(name: debt.fromUser.name, size: 26),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${debt.fromUser.name.split(' ').first} owes you ${_money(debt.amount)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.greyText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: StatusPill(
                label: statusLabel,
                amount: statusAmount,
                tone: statusTone,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.groups_rounded, color: AppColors.orange, size: 42),
            const SizedBox(height: 12),
            const Text(
              'No groups yet',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create a lobby and start splitting expenses with friends.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.greyText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateLobbyScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Create Group',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
