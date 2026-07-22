import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/favorite_plan.dart';
import '../../../presentation/viewmodels/favorite_viewmodel.dart';
import '../../../presentation/widgets/loading_indicator.dart';
import '../../../presentation/widgets/rating_stars.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoriteViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('お気に入り (${state.favorites.length}件)'),
        actions: [
          if (state.favorites.isNotEmpty)
            TextButton(
              onPressed: () => _showClearConfirmation(context, ref),
              child:
                  const Text('全て削除', style: TextStyle(color: Colors.white70)),
            ),
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, FavoriteState state) {
    if (state.isLoading) {
      return const LoadingIndicator(message: 'お気に入りを読み込んでいます...');
    }

    if (state.isEmpty) {
      return _buildEmptyState(context);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: state.favorites.length,
      itemBuilder: (context, index) {
        final fav = state.favorites[index];
        return _FavoritePlanCard(
          favPlan: fav,
          onTap: () => context.push('/favorites/plan/${fav.planId}'),
          onRemove: () => ref
              .read(favoriteViewModelProvider.notifier)
              .removeFavorite(fav.planId),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_border, size: 80, color: AppTheme.textHint),
          const Gap(16),
          const Text(
            'お気に入りがありません',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary),
          ),
          const Gap(8),
          const Text(
            'プランの♡ボタンを押してお気に入りに追加できます',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const Gap(24),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('プランを探す'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearConfirmation(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('お気に入りを全て削除'),
        content: const Text('全てのお気に入りプランを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('削除', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(favoriteViewModelProvider.notifier).clearAll();
    }
  }
}

class _FavoritePlanCard extends StatelessWidget {
  final FavoritePlan favPlan;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoritePlanCard({
    required this.favPlan,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: favPlan.primaryImageUrl.isNotEmpty
                      ? Image.network(
                          favPlan.primaryImageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stack) => Container(
                            color: AppTheme.dividerColor,
                            child: const Icon(Icons.image_not_supported,
                                color: AppTheme.textHint, size: 36),
                          ),
                        )
                      : Container(
                          color: AppTheme.dividerColor,
                          child: const Center(
                            child: Icon(Icons.travel_explore,
                                color: AppTheme.textHint, size: 36),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        favPlan.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 11, color: AppTheme.textSecondary),
                          Expanded(
                            child: Text(
                              favPlan.destination,
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Gap(4),
                      RatingStars(
                          rating: favPlan.rating, size: 12, showCount: false),
                      const Gap(4),
                      Text(
                        '¥${_formatPrice(favPlan.effectivePrice.toInt())}〜',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.favorite, color: Colors.red, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}
