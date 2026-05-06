import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../models/expense.dart';
import '../models/lobby.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';

class LobbyDetailScreen extends StatefulWidget {
  final Lobby lobby;

  const LobbyDetailScreen({super.key, required this.lobby});

  @override
  State<LobbyDetailScreen> createState() => _LobbyDetailScreenState();
}

class _LobbyDetailScreenState extends State<LobbyDetailScreen> {
  String searchText = '';

  Lobby _latestLobby(AppState appState) {
    final index = appState.lobbies.indexWhere(
      (item) => item.id == widget.lobby.id,
    );

    if (index == -1) return widget.lobby;

    return appState.lobbies[index];
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lobby = _latestLobby(appState);

    final allExpenses = appState.expensesByLobby(lobby.id);
    final members = appState.membersByLobby(lobby);
    final summary = appState.lobbySummary(lobby.id);

    final expenses = allExpenses.where((expense) {
      final query = searchText.trim().toLowerCase();

      if (query.isEmpty) return true;

      final payer = appState.userById(expense.paidByUserId);

      return expense.title.toLowerCase().contains(query) ||
          payer.name.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF6846), Color(0xFFFF8A4D), Color(0xFFFFD36B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _topHeader(context, lobby),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF8EA),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(34),
                    ),
                  ),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _summaryCard(
                        lobby: lobby,
                        total: summary.totalSpent,
                        membersCount: members.length,
                        youOwe: summary.youOwe,
                        youAreOwed: summary.youAreOwed,
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle(
                        title: 'Members',
                        trailing: '${members.length} people',
                        actionText: 'Add',
                        onAction: () =>
                            _showAddMemberSheet(context, appState, lobby),
                      ),

                      const SizedBox(height: 12),
                      _membersList(appState, lobby, members),

                      const SizedBox(height: 22),

                      _sectionTitle(
                        title: 'Who owes whom?',
                        trailing: 'Settle here',
                      ),

                      const SizedBox(height: 12),
                      _whoOwesWhom(appState, allExpenses),

                      const SizedBox(height: 22),
                      _searchField(),

                      const SizedBox(height: 20),

                      _sectionTitle(
                        title: 'Expenses',
                        trailing: '${expenses.length} items',
                      ),

                      const SizedBox(height: 12),

                      if (expenses.isEmpty)
                        _emptyState()
                      else
                        ...expenses.map((expense) {
                          return _expenseCard(appState, expense);
                        }),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        elevation: 8,
        onPressed: () => _showAddExpenseSheet(context, appState, lobby),
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _topHeader(BuildContext context, Lobby lobby) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
      child: Row(
        children: [
          _softCircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),

          const SizedBox(width: 12),

          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            child: const Icon(
              Icons.workspaces_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lobby.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.people_alt_rounded,
                      color: Colors.white.withValues(alpha: 0.78),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${lobby.memberIds.length} members',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Container(
                      height: 4,
                      width: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      lobby.inviteCode,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          _softCircleButton(
            icon: Icons.ios_share_rounded,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invite code: ${lobby.inviteCode}')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _softCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.20),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 42,
          width: 42,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }


  Widget _summaryCard({
    required Lobby lobby,
    required double total,
    required int membersCount,
    required double youOwe,
    required double youAreOwed,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _darkStat(
                  label: 'Total',
                  value: '\$${total.toStringAsFixed(2)}',
                  icon: Icons.receipt_long_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _darkStat(
                  label: 'Members',
                  value: '$membersCount',
                  icon: Icons.group_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _darkStat(
                  label: 'Code',
                  value: lobby.inviteCode,
                  icon: Icons.qr_code_2_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _balanceChip(
                  label: 'You owe',
                  value: youOwe,
                  background: const Color(0xFFFFDDE3),
                  foreground: const Color(0xFFD82C4A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _balanceChip(
                  label: 'You are owed',
                  value: youAreOwed,
                  background: const Color(0xFFD8FFD9),
                  foreground: const Color(0xFF009B55),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _darkStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.56),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceChip({
    required String label,
    required double value,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: foreground,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    required String trailing,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1D1D1F),
          ),
        ),
        const Spacer(),
        if (actionText != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText,
              style: const TextStyle(
                color: AppColors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          )
        else
          Text(
            trailing,
            style: const TextStyle(
              color: AppColors.greyText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _membersList(AppState appState, Lobby lobby, List<AppUser> members) {
    final isOwner = appState.currentUser.id == lobby.createdByUserId;

    return SizedBox(
      height: 104,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final user = members[index];
          final isLobbyOwner = user.id == lobby.createdByUserId;

          return Container(
            width: 92,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.orangeLight,
                  child: Text(
                    user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  user.name.split(' ').first,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),

                if (isLobbyOwner)
                  const Text(
                    'Owner',
                    style: TextStyle(
                      color: AppColors.greyText,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else if (isOwner)
                  GestureDetector(
                    onTap: () {
                      appState.removeMemberFromLobby(
                        lobbyId: lobby.id,
                        userId: user.id,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${user.name} removed if no unpaid balance exists.',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Remove',
                      style: TextStyle(
                        color: AppColors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _whoOwesWhom(AppState appState, List<Expense> expenses) {
    final debts = appState.simplifiedDebtsForLobby(widget.lobby.id);

    if (debts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFD8FFD9),
              child: Icon(Icons.check_rounded, color: AppColors.green),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Everything is balanced in this lobby.',
                style: TextStyle(
                  color: AppColors.greyText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: debts.map((debt) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFFFFF0D0),
                child: Text(
                  debt.fromUser.name.isEmpty
                      ? '?'
                      : debt.fromUser.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.orange,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${debt.fromUser.name.split(' ').first} owes ${debt.toUser.name.split(' ').first}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '\$${debt.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _searchField() {
    return TextField(
      onChanged: (value) => setState(() => searchText = value),
      decoration: InputDecoration(
        hintText: 'Find expenses...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _expenseCard(AppState appState, Expense expense) {
    final payer = appState.userById(expense.paidByUserId);
    final status = appState.expenseStatusText(expense);

    final isPositive = appState.expenseIsPositiveForCurrentUser(expense);

    final chipBg = isPositive
        ? const Color(0xFFD8FFD9)
        : status == 'Not involved' || status == 'Settled up'
        ? const Color(0xFFF0EBDD)
        : const Color(0xFFFFDDE3);

    final chipFg = isPositive
        ? const Color(0xFF009B55)
        : status == 'Not involved' || status == 'Settled up'
        ? const Color(0xFF76716A)
        : const Color(0xFFD82C4A);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFFFF0D0),
            child: Icon(_expenseIcon(expense), color: AppColors.orange),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Paid by ${payer.name}',
                  style: const TextStyle(
                    color: AppColors.greyText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: chipFg,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '\$${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 38, color: AppColors.greyText),
          SizedBox(height: 10),
          Text(
            'No expenses found',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          SizedBox(height: 5),
          Text(
            'Add an expense or try another search.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.greyText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  IconData _expenseIcon(Expense expense) {
    switch (expense.category) {
      case ExpenseCategory.food:
        return Icons.fastfood_rounded;
      case ExpenseCategory.travel:
        return Icons.flight_takeoff_rounded;
      case ExpenseCategory.rent:
        return Icons.home_rounded;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_rounded;
      case ExpenseCategory.bills:
        return Icons.receipt_long_rounded;
      case ExpenseCategory.entertainment:
        return Icons.celebration_rounded;
      case ExpenseCategory.hotel:
        return Icons.hotel_rounded;
      case ExpenseCategory.gift:
        return Icons.card_giftcard_rounded;
      case ExpenseCategory.utilities:
        return Icons.lightbulb_rounded;
      case ExpenseCategory.other:
        return Icons.category_rounded;
    }
  }

  void _showAddMemberSheet(
    BuildContext context,
    AppState appState,
    Lobby lobby,
  ) {
    final controller = TextEditingController();

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Member',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Name or email',
                  prefixIcon: const Icon(Icons.person_add_alt_1_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final value = controller.text.trim();

                    if (value.isEmpty) return;

                    appState.addMemberToLobby(
                      lobbyId: lobby.id,
                      nameOrEmail: value,
                    );

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Add Member',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddExpenseSheet(
    BuildContext context,
    AppState appState,
    Lobby lobby,
  ) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    String selectedPayerId = appState.currentUser.id;
    ExpenseCategory selectedCategory = ExpenseCategory.other;

    final members = appState.membersByLobby(lobby);

    if (members.isNotEmpty && !lobby.memberIds.contains(selectedPayerId)) {
      selectedPayerId = members.first.id;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFAF0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final amount = double.tryParse(amountController.text.trim()) ?? 0;
            final splitAmount = lobby.memberIds.isEmpty
                ? 0
                : amount / lobby.memberIds.length;

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
                  const Text(
                    'Add Expense',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                  ),
                  const SizedBox(height: 18),
                  _sheetInput(
                    controller: titleController,
                    hint: 'Expense title',
                    icon: Icons.receipt_long_rounded,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setSheetState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Amount',
                      prefixIcon: const Icon(Icons.attach_money_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedPayerId,
                        isExpanded: true,
                        items: members.map<DropdownMenuItem<String>>((user) {
                          return DropdownMenuItem<String>(
                            value: user.id,
                            child: Text('Paid by ${user.name}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setSheetState(() => selectedPayerId = value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ExpenseCategory>(
                        value: selectedCategory,
                        isExpanded: true,
                        items: ExpenseCategory.values
                            .map<DropdownMenuItem<ExpenseCategory>>((category) {
                              return DropdownMenuItem<ExpenseCategory>(
                                value: category,
                                child: Text(category.name),
                              );
                            })
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setSheetState(() => selectedCategory = value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _sheetInput(
                    controller: noteController,
                    hint: 'Note optional',
                    icon: Icons.notes_rounded,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.dark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Equal split: \$${splitAmount.toStringAsFixed(2)} each',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        final amount =
                            double.tryParse(amountController.text.trim()) ?? 0;

                        if (title.isEmpty || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Enter valid title and amount.'),
                            ),
                          );
                          return;
                        }

                        appState.addEqualExpense(
                          lobbyId: lobby.id,
                          title: title,
                          amount: amount,
                          paidByUserId: selectedPayerId,
                          category: selectedCategory,
                          note: noteController.text.trim().isEmpty
                              ? null
                              : noteController.text.trim(),
                        );

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Save Expense',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
