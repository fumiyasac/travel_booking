import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/error/app_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/itinerary_day.dart';
import '../../../data/models/review.dart';
import '../../../data/models/travel_plan.dart';
import '../../../presentation/viewmodels/plan_detail_viewmodel.dart';
import '../../../presentation/widgets/app_error_widget.dart';
import '../../../presentation/widgets/loading_indicator.dart';
import '../../../presentation/widgets/plan_map_view.dart';
import '../../../presentation/widgets/rating_stars.dart';

class PlanDetailScreen extends ConsumerStatefulWidget {
  final String planId;

  const PlanDetailScreen({super.key, required this.planId});

  @override
  ConsumerState<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends ConsumerState<PlanDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(planDetailViewModelProvider(widget.planId).notifier)
          .loadPlanById(widget.planId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(planDetailViewModelProvider(widget.planId));

    if (state.isLoading && state.plan == null) {
      return const Scaffold(body: LoadingIndicator(message: 'プランを読み込んでいます...'));
    }

    if (state.error != null && state.plan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('プラン詳細')),
        body: AppErrorWidget(
          error: state.error!,
          onRetry: state.error is NetworkError
              ? () => ref
                  .read(planDetailViewModelProvider(widget.planId).notifier)
                  .loadPlanById(widget.planId)
              : null,
        ),
      );
    }

    final plan = state.plan;
    if (plan == null) return const Scaffold(body: LoadingIndicator());

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(plan, state),
          SliverToBoxAdapter(child: _buildContent(plan)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(plan, state),
    );
  }

  Widget _buildAppBar(TravelPlan plan, PlanDetailState state) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: plan.images.isNotEmpty
            ? PageView.builder(
                itemCount: plan.images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    plan.images[index].url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                        Container(color: AppTheme.dividerColor),
                  );
                },
              )
            : Container(color: AppTheme.dividerColor),
      ),
      actions: [
        IconButton(
          icon: state.isFavoriteLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Icon(
                  state.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: state.isFavorite ? Colors.red : Colors.white,
                ),
          onPressed: () => ref
              .read(planDetailViewModelProvider(widget.planId).notifier)
              .toggleFavorite(),
        ),
      ],
    );
  }

  Widget _buildContent(TravelPlan plan) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(plan),
          const Divider(height: 32),
          _buildKeyInfo(plan),
          const Divider(height: 32),
          _buildDescription(plan),
          if (plan.highlights.isNotEmpty) ...[
            const Divider(height: 32),
            _buildHighlights(plan),
          ],
          if (plan.itinerary.isNotEmpty) ...[
            const Divider(height: 32),
            _buildItinerary(plan),
          ],
          if (plan.includedItems.isNotEmpty ||
              plan.excludedItems.isNotEmpty) ...[
            const Divider(height: 32),
            _buildIncludedExcluded(plan),
          ],
          if (plan.meetingPoint.isNotEmpty) ...[
            const Divider(height: 32),
            _buildMeetingPoint(plan),
          ],
          if (plan.reviews.isNotEmpty) ...[
            const Divider(height: 32),
            _buildReviews(plan),
          ],
          if (plan.cancellationPolicy.isNotEmpty) ...[
            const Divider(height: 32),
            _buildCancellationPolicy(plan),
          ],
          const Gap(100),
        ],
      ),
    );
  }

  Widget _buildHeader(TravelPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _categoryLabel(plan.category),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            RatingStars(rating: plan.rating, reviewCount: plan.reviewCount),
          ],
        ),
        const Gap(8),
        Text(
          plan.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const Gap(4),
        Row(
          children: [
            const Icon(Icons.location_on,
                size: 16, color: AppTheme.textSecondary),
            const Gap(2),
            Text(
              '${plan.destination}・${plan.country}',
              style:
                  const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
        const Gap(12),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (plan.hasDiscount)
                  Text(
                    '¥${_formatPrice(plan.price.toInt())}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textHint,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  '¥${_formatPrice(plan.effectivePrice.toInt())}〜',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Text(
                  '1名あたり',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '残り${plan.availableSpots}席',
                  style: TextStyle(
                    fontSize: 13,
                    color: plan.availableSpots <= 3
                        ? AppTheme.accentColor
                        : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '最大${plan.maxParticipants}名',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyInfo(TravelPlan plan) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _KeyInfoItem(
            icon: Icons.calendar_today_outlined,
            label: '期間',
            value: '${plan.durationDays}日間'),
        _KeyInfoItem(
            icon: Icons.people_outline,
            label: '最大人数',
            value: '${plan.maxParticipants}名'),
        _KeyInfoItem(
            icon: Icons.signal_cellular_alt,
            label: '難易度',
            value: _difficultyLabel(plan.difficulty)),
        _KeyInfoItem(
            icon: Icons.language, label: 'ガイド言語', value: plan.language),
      ],
    );
  }

  Widget _buildDescription(TravelPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'プラン概要',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary),
        ),
        const Gap(12),
        Text(
          plan.description,
          style: const TextStyle(
              fontSize: 14, color: AppTheme.textSecondary, height: 1.7),
        ),
        if (plan.tags.isNotEmpty) ...[
          const Gap(12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: plan.tags
                .map((tag) => Chip(
                      label: Text(
                        '#$tag',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor:
                          AppTheme.primaryColor.withValues(alpha: 0.12),
                      side: BorderSide(
                          color: AppTheme.primaryColor.withValues(alpha: 0.35)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildHighlights(TravelPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'このプランのハイライト',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary),
        ),
        const Gap(12),
        ...plan.highlights.map((h) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle,
                      color: AppTheme.successColor, size: 18),
                  const Gap(8),
                  Expanded(
                    child: Text(h,
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.textPrimary)),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildItinerary(TravelPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'スケジュール',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary),
        ),
        const Gap(12),
        ...plan.itinerary.map((day) => _ItineraryDayCard(day: day)),
      ],
    );
  }

  Widget _buildIncludedExcluded(TravelPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '料金に含まれるもの',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary),
        ),
        const Gap(12),
        ...plan.includedItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check,
                      color: AppTheme.successColor, size: 16),
                  const Gap(8),
                  Expanded(
                      child: Text(item,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.textPrimary))),
                ],
              ),
            )),
        if (plan.excludedItems.isNotEmpty) ...[
          const Gap(16),
          const Text(
            '料金に含まれないもの',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary),
          ),
          const Gap(8),
          ...plan.excludedItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.close,
                        color: AppTheme.errorColor, size: 16),
                    const Gap(8),
                    Expanded(
                        child: Text(item,
                            style: const TextStyle(
                                fontSize: 13, color: AppTheme.textSecondary))),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildMeetingPoint(TravelPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '集合場所',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary),
        ),
        const Gap(12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.place, color: AppTheme.primaryColor, size: 18),
              const Gap(8),
              Expanded(
                child: Text(
                  plan.meetingPoint,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textPrimary),
                ),
              ),
            ],
          ),
        ),
        const Gap(12),
        PlanMapView(
          latitude: plan.latitude,
          longitude: plan.longitude,
          meetingPoint: plan.meetingPoint,
        ),
      ],
    );
  }

  Widget _buildReviews(TravelPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'クチコミ',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary),
            ),
            const Gap(8),
            Text(
              '(${plan.reviewCount}件)',
              style:
                  const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
        const Gap(12),
        ...plan.reviews.take(3).map((review) => _ReviewCard(review: review)),
      ],
    );
  }

  Widget _buildCancellationPolicy(TravelPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'キャンセルポリシー',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary),
        ),
        const Gap(12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Text(
            plan.cancellationPolicy,
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textPrimary, height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(TravelPlan plan, PlanDetailState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('1名あたり',
                  style:
                      TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              Text(
                '¥${_formatPrice(plan.effectivePrice.toInt())}〜',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const Gap(16),
          Expanded(
            child: ElevatedButton(
              onPressed: plan.availableSpots > 0
                  ? () => context.push('/plan/${plan.id}/booking')
                  : null,
              child: Text(plan.availableSpots > 0 ? '予約する' : '満席'),
            ),
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

  String _categoryLabel(String cat) {
    const labels = {
      'city': '都市観光',
      'cultural': '文化体験',
      'nature': '自然',
      'adventure': 'アドベンチャー',
      'leisure': 'リゾート'
    };
    return labels[cat] ?? cat;
  }

  String _difficultyLabel(String d) {
    const labels = {'easy': 'やさしい', 'moderate': 'ふつう', 'hard': 'ハード'};
    return labels[d] ?? d;
  }
}

class _KeyInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _KeyInfoItem(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const Gap(4),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        const Gap(2),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
      ],
    );
  }
}

class _ItineraryDayCard extends StatefulWidget {
  final ItineraryDay day;

  const _ItineraryDayCard({required this.day});

  @override
  State<_ItineraryDayCard> createState() => _ItineraryDayCardState();
}

class _ItineraryDayCardState extends State<_ItineraryDayCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.day.dayNumber}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.day.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        if (widget.day.accommodation != null)
                          Text('宿泊: ${widget.day.accommodation}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text(widget.day.description,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.5)),
                  if (widget.day.activities.isNotEmpty) ...[
                    const Gap(10),
                    ...widget.day.activities.map((activity) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (activity.startTime != null)
                                SizedBox(
                                  width: 45,
                                  child: Text(activity.startTime!,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.w600)),
                                ),
                              const Icon(Icons.circle,
                                  size: 6, color: AppTheme.primaryColor),
                              const Gap(6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(activity.name,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                    if (activity.location != null)
                                      Text(activity.location!,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  review.reviewerName.isNotEmpty ? review.reviewerName[0] : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const Gap(8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.reviewerName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(
                    DateFormat('yyyy年M月').format(review.travelDate),
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              RatingBarIndicator(
                rating: review.rating,
                itemBuilder: (_, __) =>
                    const Icon(Icons.star, color: AppTheme.starColor),
                itemCount: 5,
                itemSize: 14,
              ),
            ],
          ),
          const Gap(8),
          Text(review.comment,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}
