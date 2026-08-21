import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/database/app_database.dart';
import '../../../core/error/app_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../presentation/viewmodels/plan_list_viewmodel.dart';
import '../../../presentation/widgets/app_error_widget.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/plan_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(planListViewModelProvider.notifier).loadPlans();
      FilterStorage().loadFilter().then((lastFilter) {
        if (lastFilter != null && mounted) {
          ref.read(planListViewModelProvider.notifier).updateFilter(lastFilter);
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxExtent = _scrollController.position.maxScrollExtent;
    final threshold = math.max(maxExtent * 0.2, 100.0);
    if (maxExtent - _scrollController.position.pixels < threshold) {
      ref.read(planListViewModelProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(planListViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: '目的地・プラン名で検索...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                ),
                onSubmitted: (value) {
                  ref
                      .read(planListViewModelProvider.notifier)
                      .updateKeyword(value);
                },
              )
            : const Text('旅行プラン'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  ref
                      .read(planListViewModelProvider.notifier)
                      .updateKeyword('');
                }
              });
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.tune),
                if (state.filter.hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              FilterBottomSheet.show(
                context,
                state.filter,
                (newFilter) {
                  ref
                      .read(planListViewModelProvider.notifier)
                      .updateFilter(newFilter);
                  FilterStorage().saveFilter(newFilter);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: '最近見たプラン',
            onPressed: () => context.push('/recently-viewed'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: () => ref
            .read(planListViewModelProvider.notifier)
            .loadPlans(refresh: true),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(PlanListState state) {
    if (state.isLoading && state.plans.isEmpty) {
      return _buildShimmerList();
    }

    if (state.error != null && state.plans.isEmpty) {
      return AppErrorWidget(
        error: state.error!,
        onRetry: state.error is NetworkError
            ? () => ref.read(planListViewModelProvider.notifier).loadPlans()
            : null,
      );
    }

    if (state.plans.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        if (state.filter.hasActiveFilters) _buildFilterSummary(state),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: state.plans.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.plans.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child:
                        CircularProgressIndicator(color: AppTheme.primaryColor),
                  ),
                );
              }
              return PlanCard(plan: state.plans[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSummary(PlanListState state) {
    return Container(
      color: AppTheme.primaryColor.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '${state.totalCount}件のプランが見つかりました',
            style: const TextStyle(fontSize: 13, color: AppTheme.primaryColor),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () =>
                ref.read(planListViewModelProvider.notifier).resetFilter(),
            child: const Text(
              'フィルターをクリア',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            height: 280,
            child: Container(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.travel_explore, size: 72, color: AppTheme.textHint),
          const SizedBox(height: 16),
          const Text(
            'プランが見つかりませんでした',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            '検索条件を変更してお試しください',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () =>
                ref.read(planListViewModelProvider.notifier).resetFilter(),
            child: const Text('フィルターをリセット'),
          ),
        ],
      ),
    );
  }
}
