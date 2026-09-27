import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/travel_plan.dart';
import '../../../presentation/viewmodels/booking_viewmodel.dart';
import '../../../presentation/viewmodels/plan_detail_viewmodel.dart';
import '../../../presentation/widgets/booking_step_indicator.dart';
import '../../../presentation/widgets/loading_indicator.dart';
import 'steps/confirmation_step.dart';
import 'steps/date_guests_step.dart';
import 'steps/traveler_info_step.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String planId;

  const BookingScreen({super.key, required this.planId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingViewModelProvider.notifier).reset();
      final detailState = ref.read(planDetailViewModelProvider(widget.planId));
      if (detailState.plan == null) {
        ref
            .read(planDetailViewModelProvider(widget.planId).notifier)
            .loadPlanById(widget.planId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(
      bookingViewModelProvider.select((s) => s.currentStep),
    );
    final detailState = ref.watch(planDetailViewModelProvider(widget.planId));
    final plan = detailState.plan;

    if (plan == null) {
      return const Scaffold(body: LoadingIndicator(message: 'プランを読み込んでいます...'));
    }

    return PopScope(
      // Step 0 では OS の戻るで画面を閉じる。Step 1/2 では前ステップへ戻る。
      canPop: currentStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          ref.read(bookingViewModelProvider.notifier).prevStep();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('予約する'),
          leading: currentStep > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () =>
                      ref.read(bookingViewModelProvider.notifier).prevStep(),
                )
              : null,
        ),
        body: Column(
          children: [
            _PlanSummaryBar(plan: plan),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: BookingStepIndicator(currentStep: currentStep),
            ),
            Expanded(
              child: IndexedStack(
                index: currentStep,
                children: [
                  const TravelerInfoStep(),
                  DateGuestsStep(plan: plan),
                  ConfirmationStep(plan: plan, onSubmit: _submitBooking),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitBooking() async {
    final plan = ref.read(planDetailViewModelProvider(widget.planId)).plan;
    if (plan == null) return;

    final success = await ref
        .read(bookingViewModelProvider.notifier)
        .submitBooking(plan.id, plan.availableSpots);

    if (success && mounted) {
      final completedBooking = ref
          .read(bookingViewModelProvider)
          .completedBooking;
      if (completedBooking != null) {
        context.go(
          '/booking/confirmation/${completedBooking.id}',
          extra: {
            'planTitle': plan.title,
            'totalPrice': completedBooking.totalPrice,
            'travelDate': completedBooking.travelDate,
            'numberOfPeople': completedBooking.numberOfPeople,
          },
        );
      }
    }
  }
}

class _PlanSummaryBar extends StatelessWidget {
  final TravelPlan plan;

  const _PlanSummaryBar({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFEAF4F8),
        border: Border(bottom: BorderSide(color: Color(0xFFD0E6EF))),
      ),
      child: Row(
        children: [
          const Icon(Icons.travel_explore, color: Color(0xFF1A6B8A), size: 22),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${plan.destination}・${plan.durationDays}日間',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7A8D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
