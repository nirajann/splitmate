import 'package:flutter/material.dart';
import 'package:splitmate/screens/profile_screen.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'lobbies_screen.dart';
import 'add_expense_screen.dart';
import 'activity_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selectedIndex = 0;

  final pages = const [
    HomeScreen(),
    ActivityScreen(),
    AddExpenseScreen(),
    LobbiesScreen(),
    ProfileScreen(),
  ];

  void changeTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: pages[selectedIndex],
      ),
      bottomNavigationBar: _floatingBottomNav(),
    );
  }

  Widget _floatingBottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(42, 0, 42, 20),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.26),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navIcon(Icons.home_rounded, 0),
            _navIcon(Icons.swap_horiz_rounded, 1),
            _centerAddButton(),
            _navIcon(Icons.groups_rounded, 3),
            _navIcon(Icons.person_rounded, 4),
          ],
        ),
      ),
    );
  }

  Widget _centerAddButton() {
    final active = selectedIndex == 2;

    return GestureDetector(
      onTap: () => changeTab(2),
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: AppColors.orange,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 4,
          ),
        ),
        child: Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: active ? 31 : 28,
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    final active = selectedIndex == index;

    return IconButton(
      onPressed: () => changeTab(index),
      icon: Icon(
        icon,
        size: 23,
        color: active ? AppColors.orangeLight : Colors.white70,
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(title),
      color: const Color(0xFFFFFAF0),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}