import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lobby.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import 'create_lobby_screen.dart';
import 'lobby_detail_screen.dart';

class LobbiesScreen extends StatefulWidget {
  const LobbiesScreen({super.key});

  @override
  State<LobbiesScreen> createState() => _LobbiesScreenState();
}

class _LobbiesScreenState extends State<LobbiesScreen> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final filteredLobbies = appState.currentUserLobbies.where((lobby) {
      final query = searchText.trim().toLowerCase();

      if (query.isEmpty) return true;

      return lobby.name.toLowerCase().contains(query) ||
          lobby.description.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF0),
      appBar: AppBar(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        title: const Text('Your Lobbies'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateLobbyScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Lobby'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => setState(() => searchText = value),
              decoration: InputDecoration(
                hintText: 'Search lobbies...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Expanded(
              child: filteredLobbies.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                itemCount: filteredLobbies.length,
                itemBuilder: (context, index) {
                  return _lobbyCard(
                    context: context,
                    appState: appState,
                    lobby: filteredLobbies[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lobbyCard({
    required BuildContext context,
    required AppState appState,
    required Lobby lobby,
  }) {
    final summary = appState.lobbySummary(lobby.id);

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
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.orangeLight,
              child: Icon(Icons.groups, color: AppColors.dark),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lobby.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),

                  Text(
                    lobby.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.greyText),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${lobby.memberIds.length} members • \$${summary.totalSpent.toStringAsFixed(2)} total',
                    style: const TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),

                  if (summary.youOwe > 0 || summary.youAreOwed > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      summary.youOwe > 0
                          ? 'You owe \$${summary.youOwe.toStringAsFixed(2)}'
                          : 'You are owed \$${summary.youAreOwed.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: summary.youOwe > 0
                            ? AppColors.red
                            : AppColors.green,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Settled up',
                      style: TextStyle(
                        color: AppColors.greyText,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Icon(Icons.chevron_right),
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
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_rounded,
              color: AppColors.orange,
              size: 42,
            ),
            SizedBox(height: 12),
            Text(
              'No lobbies found',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Create your first lobby to start splitting expenses.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.greyText),
            ),
          ],
        ),
      ),
    );
  }
}