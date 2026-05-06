import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/activity_log.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_avatar.dart';
import '../widgets/status_pill.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

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

  String _time(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
        ? 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  IconData _icon(ActivityType type) {
    switch (type) {
      case ActivityType.lobbyCreated:
        return Icons.groups_rounded;
      case ActivityType.memberAdded:
        return Icons.person_add_alt_1_rounded;
      case ActivityType.memberRemoved:
        return Icons.person_remove_alt_1_rounded;
      case ActivityType.expenseAdded:
        return Icons.receipt_long_rounded;
      case ActivityType.expenseEdited:
        return Icons.edit_rounded;
      case ActivityType.expenseDeleted:
        return Icons.delete_rounded;
      case ActivityType.settlementAdded:
        return Icons.check_circle_rounded;
    }
  }

  StatusPillTone _tone(ActivityType type) {
    switch (type) {
      case ActivityType.settlementAdded:
        return StatusPillTone.positive;
      case ActivityType.expenseDeleted:
      case ActivityType.memberRemoved:
        return StatusPillTone.negative;
      case ActivityType.lobbyCreated:
      case ActivityType.memberAdded:
      case ActivityType.expenseAdded:
      case ActivityType.expenseEdited:
        return StatusPillTone.neutral;
    }
  }

  String _label(ActivityType type) {
    switch (type) {
      case ActivityType.lobbyCreated:
        return 'Group';
      case ActivityType.memberAdded:
        return 'Member';
      case ActivityType.memberRemoved:
        return 'Removed';
      case ActivityType.expenseAdded:
        return 'Expense';
      case ActivityType.expenseEdited:
        return 'Edited';
      case ActivityType.expenseDeleted:
        return 'Deleted';
      case ActivityType.settlementAdded:
        return 'Settled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final logs = List<ActivityLog>.from(appState.activityLogs)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final settlements = logs
        .where((log) => log.type == ActivityType.settlementAdded)
        .length;

    final expenses = logs
        .where((log) => log.type == ActivityType.expenseAdded)
        .length;

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
              _header(appState),
              const SizedBox(height: 16),

              _summaryCard(
                total: logs.length,
                expenses: expenses,
                settlements: settlements,
              ),

              const SizedBox(height: 18),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 95),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFAF0),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(34),
                    ),
                  ),
                  child: logs.isEmpty
                      ? _emptyState()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];

                            return _activityTile(
                              appState: appState,
                              log: log,
                              isLast: index == logs.length - 1,
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

  Widget _header(AppState appState) {
    final user = appState.currentUser;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.history_rounded,
              color: AppColors.orange,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 21,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Latest group and payment updates',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          AppAvatar(name: user.name, size: 38),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required int total,
    required int expenses,
    required int settlements,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.13),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _summaryItem(
                icon: Icons.auto_awesome_rounded,
                value: '$total',
                label: 'Updates',
              ),
            ),
            _divider(),
            Expanded(
              child: _summaryItem(
                icon: Icons.receipt_long_rounded,
                value: '$expenses',
                label: 'Expenses',
              ),
            ),
            _divider(),
            Expanded(
              child: _summaryItem(
                icon: Icons.check_circle_rounded,
                value: '$settlements',
                label: 'Settled',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.58),
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 38,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }

  Widget _activityTile({
    required AppState appState,
    required ActivityLog log,
    required bool isLast,
  }) {
    final lobby = appState.lobbyById(log.lobbyId);
    final tone = _tone(log.type);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0D0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_icon(log.type), color: AppColors.orange, size: 21),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE4D3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(15),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusPill(
                        label: _label(log.type),
                        tone: tone,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _time(log.createdAt),
                        style: const TextStyle(
                          color: AppColors.greyText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    log.message,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${lobby?.name ?? 'Unknown group'} • ${_date(log.createdAt)}',
                    style: const TextStyle(
                      color: AppColors.greyText,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
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
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFFFF0D0),
              child: Icon(
                Icons.history_rounded,
                color: AppColors.orange,
                size: 32,
              ),
            ),
            SizedBox(height: 14),
            Text(
              'No activity yet',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            SizedBox(height: 7),
            Text(
              'Create a group or add an expense to see updates here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.greyText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
