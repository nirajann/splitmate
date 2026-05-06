import 'package:flutter/material.dart';

import 'app_avatar.dart';

class AvatarStack extends StatelessWidget {
  final List<String> names;
  final double size;
  final int maxVisible;

  const AvatarStack({
    super.key,
    required this.names,
    this.size = 28,
    this.maxVisible = 3,
  });

  @override
  Widget build(BuildContext context) {
    final visible = names.take(maxVisible).toList();
    final remaining = names.length - visible.length;

    return SizedBox(
      width: visible.isEmpty
          ? size
          : (visible.length * (size * 0.68)) + (remaining > 0 ? size : 0),
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int index = 0; index < visible.length; index++)
            Positioned(
              left: index * (size * 0.68),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: AppAvatar(name: visible[index], size: size),
              ),
            ),
          if (remaining > 0)
            Positioned(
              left: visible.length * (size * 0.68),
              child: Container(
                height: size,
                width: size,
                decoration: const BoxDecoration(
                  color: Color(0xFF1D1D1F),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
