import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/activity_log.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  String _date(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  Color _iconColor(ActivityType type) {
    switch (type) {
      case ActivityType.settlementAdded:
        return AppColors.green;
      case ActivityType.expenseDeleted:
      case ActivityType.memberRemoved:
        return AppColors.red;
      default:
        return AppColors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final logs = List<ActivityLog>.from(appState.activityLogs)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Container(
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
            const Padding(
              padding: EdgeInsets.fromLTRB(28, 16, 28, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.history_rounded,
                      color: AppColors.orange,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Activity',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
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
                child: logs.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final lobby = appState.lobbies
                        .where((item) => item.id == log.lobbyId)
                        .firstOrNull;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
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
                              _icon(log.type),
                              color: _iconColor(log.type),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.message,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${lobby?.name ?? 'Unknown lobby'} • ${_date(log.createdAt)}',
                                  style: const TextStyle(
                                    color: AppColors.greyText,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              color: AppColors.orange,
              size: 42,
            ),
            SizedBox(height: 12),
            Text(
              'No activity yet',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Create a lobby or add an expense to see history here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.greyText),
            ),
          ],
        ),
      ),
    );
  }
}