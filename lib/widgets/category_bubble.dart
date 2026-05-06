import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../theme/app_colors.dart';

class CategoryBubble extends StatelessWidget {
  final ExpenseCategory category;
  final double size;

  const CategoryBubble({super.key, required this.category, this.size = 46});

  IconData get _icon {
    switch (category) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0D0),
        borderRadius: BorderRadius.circular(size * 0.36),
      ),
      child: Icon(_icon, color: AppColors.orange, size: size * 0.48),
    );
  }
}
