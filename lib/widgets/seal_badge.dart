import 'package:flutter/material.dart';

import '../theme.dart';

/// Scalloped teal seal behind topic and question icons.
class SealBadge extends StatelessWidget {
  const SealBadge({super.key, required this.icon, this.size = 48});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const ShapeDecoration(
        color: Color(0xFF3FD9C4),
        shape: StarBorder(
          points: 16,
          innerRadiusRatio: 0.9,
          pointRounding: 0.5,
          valleyRounding: 0.5,
          side: BorderSide(color: AppColors.deepTeal),
        ),
      ),
      child: Icon(icon, size: size / 2, color: AppColors.ink),
    );
  }
}
