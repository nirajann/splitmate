import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/lobby.dart';
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
    final filteredLobbies = DummyData.lobbies.where((lobby) {
      return lobby.name.toLowerCase().contains(searchText.toLowerCase()) ||
          lobby.description.toLowerCase().contains(searchText.toLowerCase());
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
        onPressed: () {
          Navigator.push(
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
                hintText: 'Search lobbies or expenses...',
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
              child: ListView.builder(
                itemCount: filteredLobbies.length,
                itemBuilder: (context, index) {
                  return _lobbyCard(filteredLobbies[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lobbyCard(Lobby lobby) {
    final expenses = DummyData.expensesByLobby(lobby.id);
    final total = expenses.fold<double>(0, (sum, item) => sum + item.amount);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LobbyDetailScreen(lobby: lobby)),
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
                    '${lobby.memberIds.length} members • \$${total.toStringAsFixed(2)} total',
                    style: const TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}