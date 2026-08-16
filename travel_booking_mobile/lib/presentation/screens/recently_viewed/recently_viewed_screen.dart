import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../presentation/viewmodels/recently_viewed_viewmodel.dart';
import '../../../presentation/widgets/app_error_widget.dart';
import '../../../presentation/widgets/loading_indicator.dart';
import '../home/widgets/plan_card.dart';

class RecentlyViewedScreen extends ConsumerStatefulWidget {
  const RecentlyViewedScreen({super.key});

  @override
  ConsumerState<RecentlyViewedScreen> createState() =>
      _RecentlyViewedScreenState();
}

class _RecentlyViewedScreenState extends ConsumerState<RecentlyViewedScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recentlyViewedViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('最近見たプラン (${state.plans.length}件)'),
        actions: [
          if (state.plans.isNotEmpty)
            TextButton(
              onPressed: () => _showClearConfirmation(context),
              child: const Text(
                '履歴をクリア',
                style: TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(RecentlyViewedState state) {
    if (state.isLoading) {
      return const LoadingIndicator(message: '履歴を読み込んでいます...');
    }

    if (state.error != null) {
      return AppErrorWidget(
        error: state.error!,
        onRetry: state.error is NetworkError
            ? () => ref.invalidate(recentlyViewedViewModelProvider)
            : null,
      );
    }

    if (state.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.plans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => PlanCard(plan: state.plans[index]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 80, color: AppTheme.textHint),
          const SizedBox(height: 16),
          const Text(
            '最近見たプランはありません',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'プランを閲覧すると、ここに表示されます',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('プランを探す'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('履歴をクリア'),
        content: const Text('閲覧履歴を全て削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              '削除',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(recentlyViewedViewModelProvider.notifier).clearHistory();
    }
  }
}
