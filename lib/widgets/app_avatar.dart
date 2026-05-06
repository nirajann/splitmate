import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  final String name;
  final double size;
  final IconData? icon;

  const AppAvatar({super.key, required this.name, this.size = 38, this.icon});

  Color _colorFromName(String value) {
    final colors = [
      const Color(0xFFFFE1E8),
      const Color(0xFFFFF0C7),
      const Color(0xFFD8FFD9),
      const Color(0xFFE1DCFF),
      const Color(0xFFDFF4FF),
      const Color(0xFFFFE6CC),
    ];

    if (value.isEmpty) return colors.first;

    final index =
        value.codeUnits.fold<int>(0, (sum, code) => sum + code) % colors.length;

    return colors[index];
  }

  String _initial(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final background = _colorFromName(name);

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Center(
        child: icon == null
            ? Text(
                _initial(name),
                style: TextStyle(
                  color: AppColors.orange,
                  fontWeight: FontWeight.w900,
                  fontSize: size * 0.38,
                ),
              )
            : Icon(icon, color: AppColors.orange, size: size * 0.48),
      ),
    );
  }
}
