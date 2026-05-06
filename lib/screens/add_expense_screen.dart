import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../models/expense.dart';
import '../models/lobby.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';

enum AddExpenseSplitMode { equal, custom }

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  final Map<String, TextEditingController> customSplitControllers = {};

  String? selectedLobbyId;
  String? selectedPayerId;

  ExpenseCategory selectedCategory = ExpenseCategory.other;
  AddExpenseSplitMode splitMode = AddExpenseSplitMode.equal;

  bool showMoreOptions = false;

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();

    for (final controller in customSplitControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  String _money(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  double _amount() {
    return double.tryParse(amountController.text.trim()) ?? 0;
  }

  Lobby? _selectedLobby(List<Lobby> lobbies) {
    if (selectedLobbyId == null) return null;

    for (final lobby in lobbies) {
      if (lobby.id == selectedLobbyId) return lobby;
    }

    return null;
  }

  void _syncCustomControllers(List<AppUser> members) {
    for (final member in members) {
      customSplitControllers.putIfAbsent(
        member.id,
        () => TextEditingController(),
      );
    }

    final validIds = members.map((member) => member.id).toSet();

    final removeIds = customSplitControllers.keys.where((id) {
      return !validIds.contains(id);
    }).toList();

    for (final id in removeIds) {
      customSplitControllers[id]?.dispose();
      customSplitControllers.remove(id);
    }
  }

  double _customTotal() {
    double total = 0;

    for (final controller in customSplitControllers.values) {
      total += double.tryParse(controller.text.trim()) ?? 0;
    }

    return total;
  }

  void _prefillEqualCustomAmounts(List<AppUser> members) {
    final amount = _amount();

    if (amount <= 0 || members.isEmpty) return;

    final each = amount / members.length;

    for (final member in members) {
      customSplitControllers[member.id]?.text = each.toStringAsFixed(2);
    }

    setState(() {});
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _saveExpense(AppState appState, List<AppUser> members) {
    final title = titleController.text.trim();
    final amount = _amount();

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
      _message('Please enter a valid amount.');
      return;
    }

    bool success = false;

    if (splitMode == AddExpenseSplitMode.equal) {
      success = appState.addEqualExpense(
        lobbyId: selectedLobbyId!,
        title: title,
        amount: amount,
        paidByUserId: selectedPayerId!,
        category: selectedCategory,
        note: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
      );
    } else {
      final customTotal = _customTotal();

      if ((customTotal - amount).abs() > 0.01) {
        _message(
          'Custom split total must equal ${_money(amount)}. Current total is ${_money(customTotal)}.',
        );
        return;
      }

      final customSplits = members.map((member) {
        final value =
            double.tryParse(
              customSplitControllers[member.id]?.text.trim() ?? '',
            ) ??
            0;

        return CustomSplitInput(userId: member.id, amount: value);
      }).toList();

      success = appState.addCustomExpense(
        lobbyId: selectedLobbyId!,
        title: title,
        amount: amount,
        paidByUserId: selectedPayerId!,
        customSplits: customSplits,
        category: selectedCategory,
        note: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
      );
    }

    if (!success) {
      _message('Could not add expense. Please check the details.');
      return;
    }

    titleController.clear();
    amountController.clear();
    noteController.clear();

    for (final controller in customSplitControllers.values) {
      controller.clear();
    }

    setState(() {
      splitMode = AddExpenseSplitMode.equal;
      selectedCategory = ExpenseCategory.other;
      showMoreOptions = false;
    });

    _message('Expense added successfully.');
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lobbies = appState.currentUserLobbies;

    if (selectedLobbyId == null && lobbies.isNotEmpty) {
      selectedLobbyId = lobbies.first.id;
    }

    final selectedLobby = _selectedLobby(lobbies);

    final members = selectedLobby == null
        ? <AppUser>[]
        : appState.membersByLobby(selectedLobby);

    if (selectedPayerId == null && members.isNotEmpty) {
      selectedPayerId = appState.currentUser.id;
    }

    if (selectedPayerId != null &&
        members.isNotEmpty &&
        !members.any((user) => user.id == selectedPayerId)) {
      selectedPayerId = members.first.id;
    }

    _syncCustomControllers(members);

    final double amount = _amount();
    final double equalSplitAmount = members.isEmpty
        ? 0.0
        : amount / members.length;
    final double customTotal = _customTotal();

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
              _header(),
              const SizedBox(height: 16),
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
                  child: lobbies.isEmpty
                      ? _emptyLobbyState()
                      : ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _amountHero(),
                            const SizedBox(height: 16),

                            _inputCard(
                              controller: titleController,
                              hint: 'What was this for?',
                              icon: Icons.receipt_long_rounded,
                              onChanged: (_) => setState(() {}),
                            ),

                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Expanded(
                                  child: _dropdownCard<String>(
                                    label: 'Lobby',
                                    value: selectedLobbyId,
                                    icon: Icons.groups_rounded,
                                    items: lobbies.map((lobby) {
                                      return DropdownMenuItem<String>(
                                        value: lobby.id,
                                        child: Text(
                                          lobby.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
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
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _dropdownCard<String>(
                                    label: 'Paid by',
                                    value: selectedPayerId,
                                    icon: Icons.person_rounded,
                                    items: members.map((user) {
                                      return DropdownMenuItem<String>(
                                        value: user.id,
                                        child: Text(
                                          user.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() => selectedPayerId = value);
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            _splitModeSelector(members),

                            const SizedBox(height: 14),

                            if (splitMode == AddExpenseSplitMode.equal)
                              _equalSplitPreview(
                                membersCount: members.length,
                                splitAmount: equalSplitAmount,
                              )
                            else
                              _customSplitSection(
                                members: members,
                                amount: amount,
                                customTotal: customTotal,
                              ),

                            const SizedBox(height: 14),

                            _moreOptions(),

                            if (showMoreOptions) ...[
                              const SizedBox(height: 12),
                              _dropdownCard<ExpenseCategory>(
                                label: 'Category',
                                value: selectedCategory,
                                icon: Icons.category_rounded,
                                items: ExpenseCategory.values.map((category) {
                                  return DropdownMenuItem<ExpenseCategory>(
                                    value: category,
                                    child: Text(_categoryName(category)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => selectedCategory = value);
                                },
                              ),
                              const SizedBox(height: 12),
                              _inputCard(
                                controller: noteController,
                                hint: 'Add note optional',
                                icon: Icons.notes_rounded,
                              ),
                            ],

                            const SizedBox(height: 22),

                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () =>
                                    _saveExpense(appState, members),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.orange,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(21),
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
      ),
    );
  }

  Widget _header() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
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
              fontSize: 21,
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountHero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
              hintText: '0.00',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.32),
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputCard({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.orange, size: 21),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _dropdownCard<T>({
    required String label,
    required T? value,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isDense: true,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: items,
                selectedItemBuilder: (_) {
                  return items.map((item) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: AppColors.greyText,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        DefaultTextStyle(
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                          child: item.child,
                        ),
                      ],
                    );
                  }).toList();
                },
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _splitModeSelector(List<AppUser> members) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EBDD),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: _splitModeButton(
              label: 'Equal',
              icon: Icons.call_split_rounded,
              selected: splitMode == AddExpenseSplitMode.equal,
              onTap: () {
                setState(() => splitMode = AddExpenseSplitMode.equal);
              },
            ),
          ),
          Expanded(
            child: _splitModeButton(
              label: 'Custom',
              icon: Icons.tune_rounded,
              selected: splitMode == AddExpenseSplitMode.custom,
              onTap: () {
                setState(() {
                  splitMode = AddExpenseSplitMode.custom;
                  _prefillEqualCustomAmounts(members);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _splitModeButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
        decoration: BoxDecoration(
          color: selected ? AppColors.dark : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : AppColors.greyText,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.greyText,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _equalSplitPreview({
    required int membersCount,
    required double splitAmount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.auto_awesome_rounded, color: AppColors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              membersCount == 0
                  ? 'Choose a lobby to calculate split.'
                  : 'Split equally between $membersCount member${membersCount == 1 ? '' : 's'} • ${_money(splitAmount)} each',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customSplitSection({
    required List<AppUser> members,
    required double amount,
    required double customTotal,
  }) {
    final difference = amount - customTotal;
    final isValid = amount > 0 && difference.abs() <= 0.01;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Custom split',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
              const Spacer(),
              Text(
                isValid
                    ? 'Balanced'
                    : 'Left ${_money(difference < 0 ? 0 : difference)}',
                style: TextStyle(
                  color: isValid ? AppColors.green : AppColors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...members.map((member) {
            final controller = customSplitControllers[member.id]!;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFFFF0D0),
                    child: Text(
                      member.name.isEmpty ? '?' : member.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.orange,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      member.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 96,
                    child: TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixText: '\$ ',
                        filled: true,
                        fillColor: const Color(0xFFFFFAF0),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _moreOptions() {
    return GestureDetector(
      onTap: () {
        setState(() => showMoreOptions = !showMoreOptions);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.settings_rounded,
              color: AppColors.orange,
              size: 20,
            ),
            const SizedBox(width: 10),
            const Text(
              'More options',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
            const Spacer(),
            Icon(
              showMoreOptions
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: AppColors.greyText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyLobbyState() {
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
    final name = category.name;
    return name[0].toUpperCase() + name.substring(1);
  }
}
