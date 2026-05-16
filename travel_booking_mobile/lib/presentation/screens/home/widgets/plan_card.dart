import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/travel_plan.dart';
import '../../../viewmodels/plan_list_viewmodel.dart';
import '../../../widgets/rating_stars.dart';

class PlanCard extends ConsumerWidget {
  final TravelPlan plan;

  const PlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/plan/${plan.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(context, ref),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: plan.primaryImageUrl.isNotEmpty
              ? Image.network(
                  plan.primaryImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stack) => Container(
                    color: AppTheme.dividerColor,
                    child: const Icon(Icons.image_not_supported, color: AppTheme.textHint, size: 48),
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(color: const Color(0xFFE0E0E0));
                  },
                )
              : Container(
                  color: AppTheme.dividerColor,
                  child: const Icon(Icons.travel_explore, color: AppTheme.textHint, size: 48),
                ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: _CategoryChip(category: plan.category),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: _FavoriteButton(plan: plan),
        ),
        if (plan.hasDiscount)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'SALE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  '${plan.destination}・${plan.country}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RatingStars(rating: plan.rating, reviewCount: plan.reviewCount),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoBadge(
                icon: Icons.calendar_today_outlined,
                label: '${plan.durationDays}日間',
              ),
              const SizedBox(width: 8),
              _InfoBadge(
                icon: Icons.signal_cellular_alt,
                label: _difficultyLabel(plan.difficulty),
                color: _difficultyColor(plan.difficulty),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (plan.hasDiscount)
                    Text(
                      '¥${_formatPrice(plan.price.toInt())}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textHint,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    '¥${_formatPrice(plan.effectivePrice.toInt())}〜',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Text(
                    '/人',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  String _difficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 'やさしい';
      case 'moderate':
        return 'ふつう';
      case 'hard':
        return 'ハード';
      default:
        return difficulty;
    }
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return AppTheme.successColor;
      case 'moderate':
        return Colors.orange;
      case 'hard':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _categoryLabel(category),
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _categoryLabel(String cat) {
    const labels = {
      'city': '都市観光',
      'cultural': '文化体験',
      'nature': '自然',
      'adventure': 'アドベンチャー',
      'leisure': 'リゾート',
    };
    return labels[cat] ?? cat;
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoBadge({
    required this.icon,
    required this.label,
    this.color = AppTheme.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}

class _FavoriteButton extends ConsumerWidget {
  final TravelPlan plan;

  const _FavoriteButton({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: ref.watch(favoriteRepositoryProvider).isFavorite(plan.id),
      builder: (context, snapshot) {
        final isFav = snapshot.data ?? false;
        return GestureDetector(
          onTap: () async {
            final repo = ref.read(favoriteRepositoryProvider);
            if (isFav) {
              await repo.removeFavorite(plan.id);
            } else {
              await repo.addFavorite(plan);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : AppTheme.textSecondary,
              size: 20,
            ),
          ),
        );
      },
    );
  }
}
