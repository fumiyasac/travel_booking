import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/travel_plan.dart';
import '../../../viewmodels/booking_viewmodel.dart';

/// Step 2: 旅行日・参加人数・特別なご要望 + リアルタイム料金内訳
class DateGuestsStep extends ConsumerWidget {
  final TravelPlan plan;

  const DateGuestsStep({super.key, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingViewModelProvider);
    final notifier = ref.read(bookingViewModelProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        const _SectionTitle('予約内容'),
        const Gap(12),
        _NumberOfPeopleSelector(
          numberOfPeople: bookingState.numberOfPeople,
          maxSpots: plan.availableSpots,
          errorText: bookingState.validationErrors['numberOfPeople'],
          onDecrement: () =>
              notifier.updateNumberOfPeople(bookingState.numberOfPeople - 1),
          onIncrement: () =>
              notifier.updateNumberOfPeople(bookingState.numberOfPeople + 1),
        ),
        const Gap(12),
        _DatePickerTile(
          selectedDate: bookingState.travelDate,
          errorText: bookingState.validationErrors['travelDate'],
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now().add(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              locale: const Locale('ja'),
            );
            if (date != null) notifier.updateTravelDate(date);
          },
        ),
        const Gap(12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: '特別なご要望（任意）',
            hintText: 'アレルギー、車椅子対応など',
            prefixIcon: Icon(
              Icons.notes_outlined,
              color: AppTheme.primaryColor,
            ),
          ),
          maxLines: 3,
          onChanged: notifier.updateSpecialRequests,
        ),
        const Gap(24),
        _PriceBreakdown(plan: plan, bookingState: bookingState),
        const Gap(32),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => notifier.prevStep(),
                  child: const Text('戻る', style: TextStyle(fontSize: 15)),
                ),
              ),
            ),
            const Gap(12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => notifier.nextStep(),
                  child: const Text(
                    '次へ: 内容を確認',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class _NumberOfPeopleSelector extends StatelessWidget {
  final int numberOfPeople;
  final int maxSpots;
  final String? errorText;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _NumberOfPeopleSelector({
    required this.numberOfPeople,
    required this.maxSpots,
    this.errorText,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: errorText != null
                  ? AppTheme.errorColor
                  : AppTheme.dividerColor,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.people_outline, color: AppTheme.primaryColor),
              const Gap(12),
              const Text(
                '参加人数',
                style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              IconButton(
                onPressed: numberOfPeople > 1 ? onDecrement : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppTheme.primaryColor,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  '$numberOfPeople名',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: numberOfPeople < maxSpots ? onIncrement : null,
                icon: const Icon(Icons.add_circle_outline),
                color: AppTheme.primaryColor,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              errorText!,
              style: const TextStyle(color: AppTheme.errorColor, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final DateTime? selectedDate;
  final String? errorText;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.selectedDate,
    this.errorText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: errorText != null
                    ? AppTheme.errorColor
                    : AppTheme.dividerColor,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: AppTheme.primaryColor,
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '旅行日',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        selectedDate != null
                            ? DateFormat('yyyy年M月d日').format(selectedDate!)
                            : '旅行日を選択してください',
                        style: TextStyle(
                          fontSize: 14,
                          color: selectedDate != null
                              ? AppTheme.textPrimary
                              : AppTheme.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.textHint),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              errorText!,
              style: const TextStyle(color: AppTheme.errorColor, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  final TravelPlan plan;
  final BookingFormState bookingState;

  const _PriceBreakdown({required this.plan, required this.bookingState});

  String _fmt(int price) => price.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );

  @override
  Widget build(BuildContext context) {
    final total = bookingState.calculateTotal(plan);
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
          const Text(
            '料金内訳',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const Gap(12),
          Row(
            children: [
              Text(
                '¥${_fmt(plan.effectivePrice.toInt())} × ${bookingState.numberOfPeople}名',
              ),
              const Spacer(),
              Text('¥${_fmt(total.toInt())}'),
            ],
          ),
          if (plan.hasDiscount) ...[
            const Gap(4),
            Row(
              children: [
                const Text('割引', style: TextStyle(color: AppTheme.accentColor)),
                const Spacer(),
                Text(
                  '-¥${_fmt(((plan.price - plan.effectivePrice) * bookingState.numberOfPeople).toInt())}',
                  style: const TextStyle(color: AppTheme.accentColor),
                ),
              ],
            ),
          ],
          const Divider(height: 16),
          Row(
            children: [
              const Text(
                '合計金額',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const Spacer(),
              Text(
                '¥${_fmt(total.toInt())}',
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
}
