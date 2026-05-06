import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';

import '../models/expense.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  String? selectedLobbyId;
  String? selectedPayerId;
  ExpenseCategory selectedCategory = ExpenseCategory.other;

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _saveExpense(AppState appState) {
    final title = titleController.text.trim();
    final amount = double.tryParse(amountController.text.trim()) ?? 0;

    if (selectedLobbyId == null) {
      _message('Please select a lobby.');
      return;
    }

    if (selectedPayerId == null) {
      _message('Please select who paid.');
      return;
    }

    if (title.isEmpty) {
      _message('Please enter expense title.');
      return;
    }

    if (amount <= 0) {
      _message('Please enter valid amount.');
      return;
    }

    appState.addEqualExpense(
      lobbyId: selectedLobbyId!,
      title: title,
      amount: amount,
      paidByUserId: selectedPayerId!,
      category: selectedCategory,
      note: noteController.text.trim().isEmpty
          ? null
          : noteController.text.trim(),
    );

    titleController.clear();
    amountController.clear();
    noteController.clear();

    _message('Expense added successfully.');

    setState(() {
      selectedCategory = ExpenseCategory.other;
    });
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lobbies = appState.currentUserLobbies;

    final selectedLobby = selectedLobbyId == null
        ? null
        : lobbies.where((lobby) => lobby.id == selectedLobbyId).firstOrNull;

    final List<AppUser> members = selectedLobby == null
        ? <AppUser>[]
        : appState.membersByLobby(selectedLobby);

    if (selectedLobbyId == null && lobbies.isNotEmpty) {
      selectedLobbyId = lobbies.first.id;
    }

    if (selectedPayerId == null && members.isNotEmpty) {
      selectedPayerId = appState.currentUser.id;
    }

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
            _header(),
            const SizedBox(height: 18),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 95),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFAF0),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                ),
                child: lobbies.isEmpty
                    ? _emptyState()
                    : ListView(
                        children: [
                          _label('Select Lobby'),
                          _card(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedLobbyId,
                                isExpanded: true,
                                items: lobbies.map((lobby) {
                                  return DropdownMenuItem(
                                    value: lobby.id,
                                    child: Text(lobby.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedLobbyId = value;
                                    selectedPayerId = null;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _label('Expense Title'),
                          _input(
                            controller: titleController,
                            hint: 'Example: Dinner, Hotel, Electricity',
                            icon: Icons.receipt_long_rounded,
                          ),
                          const SizedBox(height: 16),

                          _label('Amount'),
                          _input(
                            controller: amountController,
                            hint: '0.00',
                            icon: Icons.attach_money_rounded,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          _label('Paid By'),
                          _card(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedPayerId,
                                isExpanded: true,
                                items: members.map<DropdownMenuItem<String>>((
                                  user,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: user.id,
                                    child: Text(user.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => selectedPayerId = value);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _label('Category'),
                          _card(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<ExpenseCategory>(
                                value: selectedCategory,
                                isExpanded: true,
                                items: ExpenseCategory.values.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(_categoryName(category)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => selectedCategory = value);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _label('Note'),
                          TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              prefixIcon: const Icon(
                                Icons.attach_money_rounded,
                                color: AppColors.orange,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          _previewCard(appState),
                          const SizedBox(height: 22),

                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () => _saveExpense(appState),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orange,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Add Expense',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(28, 16, 28, 0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(Icons.add_rounded, color: AppColors.orange, size: 25),
          ),
          SizedBox(width: 10),
          Text(
            'Add Expense',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.orange),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _previewCard(AppState appState) {
    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    final selectedLobby = selectedLobbyId == null
        ? null
        : appState.currentUserLobbies
              .where((lobby) => lobby.id == selectedLobbyId)
              .firstOrNull;

    final memberCount = selectedLobby?.memberIds.length ?? 0;
    final splitAmount = memberCount == 0 ? 0 : amount / memberCount;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          const Icon(Icons.call_split_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              memberCount == 0
                  ? 'Select a lobby to calculate split.'
                  : 'Equal split: each member pays \$${splitAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
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
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_rounded, color: AppColors.orange, size: 42),
            SizedBox(height: 12),
            Text(
              'No lobbies yet',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            SizedBox(height: 6),
            Text(
              'Create a lobby first, then add expenses.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.greyText),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryName(ExpenseCategory category) {
    return category.name[0].toUpperCase() + category.name.substring(1);
  }
}
