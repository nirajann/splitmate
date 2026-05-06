import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/lobby.dart';
import '../theme/app_colors.dart';

class LobbyDetailScreen extends StatefulWidget {
  final Lobby lobby;

  const LobbyDetailScreen({
    super.key,
    required this.lobby,
  });

  @override
  State<LobbyDetailScreen> createState() => _LobbyDetailScreenState();
}

class _LobbyDetailScreenState extends State<LobbyDetailScreen> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final expenses = DummyData.expensesByLobby(widget.lobby.id).where((expense) {
      return expense.title.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    final members = widget.lobby.memberIds
        .map((id) => DummyData.userById(id))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF0),
      appBar: AppBar(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        title: Text(widget.lobby.name),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invite code: ${widget.lobby.inviteCode}')),
              );
            },
            icon: const Icon(Icons.ios_share),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _summaryCard(),
          const SizedBox(height: 18),
          const Text(
            'Members',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 74,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: members.length,
              itemBuilder: (context, index) {
                final user = members[index];
                return Container(
                  width: 94,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.orangeLight,
                        child: Text(user.name[0]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.name.split(' ').first,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            onChanged: (value) => setState(() => searchText = value),
            decoration: InputDecoration(
              hintText: 'Find expenses...',
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
          Row(
            children: [
              const Text(
                'Expenses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                '${expenses.length} items',
                style: const TextStyle(color: AppColors.greyText),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...expenses.map((expense) {
            final payer = DummyData.userById(expense.paidByUserId);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFFFF0D0),
                    child: Icon(Icons.receipt_long),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(expense.title,
                            style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text(
                          'Paid by ${payer.name}',
                          style: const TextStyle(
                            color: AppColors.greyText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${expense.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _summaryCard() {
    final expenses = DummyData.expensesByLobby(widget.lobby.id);
    final total = expenses.fold<double>(0, (sum, item) => sum + item.amount);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.lobby.description,
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 18),
          Row(
            children: [
              _miniStat('Total', '\$${total.toStringAsFixed(2)}'),
              const SizedBox(width: 12),
              _miniStat('Members', '${widget.lobby.memberIds.length}'),
              const SizedBox(width: 12),
              _miniStat('Code', widget.lobby.inviteCode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}