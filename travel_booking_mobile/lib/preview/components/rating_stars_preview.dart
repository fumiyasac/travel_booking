import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../presentation/widgets/rating_stars.dart';

@widgetbook.UseCase(name: '高評価（レビュー数あり）', type: RatingStars)
Widget buildRatingStarsHigh(BuildContext context) {
  return const Center(child: RatingStars(rating: 4.8, reviewCount: 128));
}

@widgetbook.UseCase(name: '中評価（レビュー数なし）', type: RatingStars)
Widget buildRatingStarsMedium(BuildContext context) {
  return const Center(child: RatingStars(rating: 3.5, showCount: false));
}

@widgetbook.UseCase(name: '低評価（大サイズ）', type: RatingStars)
Widget buildRatingStarsLarge(BuildContext context) {
  return const Center(
    child: RatingStars(rating: 1.5, reviewCount: 3, size: 24),
  );
}
