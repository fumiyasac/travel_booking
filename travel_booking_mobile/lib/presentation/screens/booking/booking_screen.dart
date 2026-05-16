import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/travel_plan.dart';
import '../../../presentation/viewmodels/booking_viewmodel.dart';
import '../../../presentation/viewmodels/plan_detail_viewmodel.dart';
import '../../../presentation/widgets/loading_indicator.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String planId;

  const BookingScreen({super.key, required this.planId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _formKey = GlobalKey<FormState>();

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
    final bookingState = ref.watch(bookingViewModelProvider);
    final detailState = ref.watch(planDetailViewModelProvider(widget.planId));
    final plan = detailState.plan;

    if (plan == null) {
      return const Scaffold(body: LoadingIndicator(message: 'プランを読み込んでいます...'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('予約する')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildPlanSummary(plan, bookingState),
            const Gap(24),
            _buildSectionTitle('お客様情報'),
            const Gap(12),
            _buildTextField(
              label: 'お名前（代表者）',
              hint: '山田 太郎',
              icon: Icons.person_outline,
              onChanged: ref.read(bookingViewModelProvider.notifier).updateCustomerName,
              errorText: bookingState.validationErrors['customerName'],
            ),
            const Gap(12),
            _buildTextField(
              label: 'メールアドレス',
              hint: 'example@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              onChanged: ref.read(bookingViewModelProvider.notifier).updateCustomerEmail,
              errorText: bookingState.validationErrors['customerEmail'],
            ),
            const Gap(12),
            _buildTextField(
              label: '電話番号',
              hint: '090-1234-5678',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              onChanged: ref.read(bookingViewModelProvider.notifier).updateCustomerPhone,
              errorText: bookingState.validationErrors['customerPhone'],
            ),
            const Gap(24),
            _buildSectionTitle('予約内容'),
            const Gap(12),
            _buildNumberOfPeopleSelector(bookingState, plan.availableSpots),
            const Gap(12),
            _buildDatePicker(bookingState),
            const Gap(12),
            _buildTextField(
              label: '特別なご要望（任意）',
              hint: 'アレルギー、車椅子対応など',
              icon: Icons.notes_outlined,
              maxLines: 3,
              onChanged: ref.read(bookingViewModelProvider.notifier).updateSpecialRequests,
            ),
            const Gap(24),
            _buildPriceBreakdown(plan, bookingState),
            const Gap(16),
            if (bookingState.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bookingState.error!,
                  style: const TextStyle(color: AppTheme.errorColor, fontSize: 13),
                ),
              ),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: bookingState.isSubmitting
                    ? null
                    : () => _submitBooking(plan.id, plan.availableSpots, plan.title, plan.effectivePrice),
                child: bookingState.isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('予約を確定する', style: TextStyle(fontSize: 16)),
              ),
            ),
            const Gap(32),
          ],
        ),
      ),
    );
  }

  Future<void> _submitBooking(
    String planId,
    int availableSpots,
    String planTitle,
    double pricePerPerson,
  ) async {
    final success = await ref
        .read(bookingViewModelProvider.notifier)
        .submitBooking(planId, availableSpots);

    if (success && mounted) {
      final completedBooking = ref.read(bookingViewModelProvider).completedBooking;
      if (completedBooking != null) {
        context.go(
          '/booking/confirmation/${completedBooking.id}',
          extra: {
            'planTitle': planTitle,
            'totalPrice': completedBooking.totalPrice,
            'travelDate': completedBooking.travelDate,
            'numberOfPeople': completedBooking.numberOfPeople,
          },
        );
      }
    }
  }

  Widget _buildPlanSummary(TravelPlan plan, BookingFormState bookingState) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.travel_explore, color: AppTheme.primaryColor, size: 28),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${plan.destination}・${plan.durationDays}日間',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required void Function(String) onChanged,
    String? errorText,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        errorText: errorText,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
    );
  }

  Widget _buildNumberOfPeopleSelector(BookingFormState state, int maxSpots) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_outline, color: AppTheme.primaryColor),
          const Gap(12),
          const Text('参加人数', style: TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
          if (state.validationErrors['numberOfPeople'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                state.validationErrors['numberOfPeople']!,
                style: const TextStyle(color: AppTheme.errorColor, fontSize: 12),
              ),
            ),
          const Spacer(),
          IconButton(
            onPressed: state.numberOfPeople > 1
                ? () => ref
                    .read(bookingViewModelProvider.notifier)
                    .updateNumberOfPeople(state.numberOfPeople - 1)
                : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: AppTheme.primaryColor,
          ),
          Text(
            '${state.numberOfPeople}名',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          IconButton(
            onPressed: state.numberOfPeople < maxSpots
                ? () => ref
                    .read(bookingViewModelProvider.notifier)
                    .updateNumberOfPeople(state.numberOfPeople + 1)
                : null,
            icon: const Icon(Icons.add_circle_outline),
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BookingFormState state) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 30)),
          firstDate: DateTime.now().add(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          locale: const Locale('ja'),
        );
        if (date != null) {
          ref.read(bookingViewModelProvider.notifier).updateTravelDate(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: state.validationErrors['travelDate'] != null
                ? AppTheme.errorColor
                : AppTheme.dividerColor,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: AppTheme.primaryColor),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('旅行日', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  Text(
                    state.travelDate != null
                        ? DateFormat('yyyy年M月d日').format(state.travelDate!)
                        : '旅行日を選択してください',
                    style: TextStyle(
                      fontSize: 14,
                      color: state.travelDate != null ? AppTheme.textPrimary : AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown(TravelPlan plan, BookingFormState state) {
    final total = state.calculateTotal(plan);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('料金内訳', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const Gap(12),
          Row(
            children: [
              Text('¥${_formatPrice(plan.effectivePrice.toInt())} × ${state.numberOfPeople}名'),
              const Spacer(),
              Text('¥${_formatPrice(total.toInt())}'),
            ],
          ),
          if (plan.hasDiscount) ...[
            const Gap(4),
            Row(
              children: [
                const Text('割引', style: TextStyle(color: AppTheme.accentColor)),
                const Spacer(),
                Text(
                  '-¥${_formatPrice(((plan.price - plan.effectivePrice) * state.numberOfPeople).toInt())}',
                  style: const TextStyle(color: AppTheme.accentColor),
                ),
              ],
            ),
          ],
          const Divider(height: 16),
          Row(
            children: [
              const Text('合計金額', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const Spacer(),
              Text(
                '¥${_formatPrice(total.toInt())}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppTheme.primaryColor,
                ),
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
}
