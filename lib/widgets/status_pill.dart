import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum StatusPillTone { positive, negative, neutral, dark }

class StatusPill extends StatelessWidget {
  final String label;
  final String? amount;
  final StatusPillTone tone;
  final EdgeInsetsGeometry padding;

  const StatusPill({
    super.key,
    required this.label,
    this.amount,
    this.tone = StatusPillTone.neutral,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
  });

  Color get _background {
    switch (tone) {
      case StatusPillTone.positive:
        return AppColors.greenLight;
      case StatusPillTone.negative:
        return AppColors.redLight;
      case StatusPillTone.dark:
        return AppColors.dark;
      case StatusPillTone.neutral:
        return const Color(0xFFF0EBDD);
    }
  }

  Color get _foreground {
    switch (tone) {
      case StatusPillTone.positive:
        return AppColors.green;
      case StatusPillTone.negative:
        return AppColors.red;
      case StatusPillTone.dark:
        return Colors.white;
      case StatusPillTone.neutral:
        return AppColors.greyText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _foreground,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          if (amount != null && amount!.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              amount!,
              style: TextStyle(
                color: _foreground,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
