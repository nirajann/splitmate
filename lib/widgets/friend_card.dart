import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FriendCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String avatar;
  final bool positive;

  const FriendCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.avatar,
    this.positive = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = positive ? AppColors.green : AppColors.red;
    final bg = positive ? AppColors.greenLight : AppColors.redLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: bg,
            child: Text(
              avatar,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.greyText,
          ),
        ],
      ),
    );
  }
}