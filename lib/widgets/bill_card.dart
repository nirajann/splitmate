import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BillCard extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final String status;
  final String statusAmount;
  final bool isPositive;
  final IconData icon;
  final VoidCallback? onTap;

  const BillCard({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
    required this.statusAmount,
    required this.isPositive,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusBg = isPositive ? AppColors.greenLight : AppColors.redLight;
    final statusColor = isPositive ? AppColors.green : AppColors.red;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.055),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0D0),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: AppColors.orange,
                      size: 23,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.greyText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  amount,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (statusAmount.isNotEmpty)
                    Text(
                      statusAmount,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}