import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../core/theme/app_theme.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double size;
  final bool showCount;

  const RatingStars({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 16,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (context, _) => const Icon(Icons.star, color: AppTheme.starColor),
          itemCount: 5,
          itemSize: size,
          direction: Axis.horizontal,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size * 0.875,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        if (showCount && reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: size * 0.75,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
