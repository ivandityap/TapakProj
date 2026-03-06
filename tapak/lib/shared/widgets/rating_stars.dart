import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;

  const RatingStars({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        IconData icon;
        if (starValue <= rating) {
          icon = Icons.star;
        } else if (starValue - 0.5 <= rating) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_outline;
        }
        return Icon(icon, color: AppColors.secondary, size: size);
      }),
    );
  }
}
