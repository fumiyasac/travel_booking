import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/travel_plan.dart';
import '../../../viewmodels/booking_viewmodel.dart';

/// Step 3: 入力内容確認 + 予約確定
class ConfirmationStep extends ConsumerWidget {
  final TravelPlan plan;
  final Future<void> Function() onSubmit;

  const ConfirmationStep({
    super.key,
    required this.plan,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingViewModelProvider);
    final notifier = ref.read(bookingViewModelProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        const Text(
          '入力内容の確認',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const Gap(4),
        const Text(
          '以下の内容で予約します。間違いがある場合は編集してください。',
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        const Gap(16),

        // ─── お客様情報 ─────────────────────────────────────────────────────────
        _ConfirmSection(
          title: 'お客様情報',
          onEdit: () => notifier.goToStep(0),
          rows: [
            _ConfirmRow(label: 'お名前', value: bookingState.customerName),
            _ConfirmRow(label: 'メールアドレス', value: bookingState.customerEmail),
            _ConfirmRow(label: '電話番号', value: bookingState.customerPhone),
          ],
        ),
        const Gap(12),

        // ─── 予約内容 ──────────────────────────────────────────────────────────
        _ConfirmSection(
          title: '予約内容',
          onEdit: () => notifier.goToStep(1),
          rows: [
            _ConfirmRow(
              label: '旅行日',
              value: bookingState.travelDate != null
                  ? DateFormat('yyyy年M月d日').format(bookingState.travelDate!)
                  : '未選択',
            ),
            _ConfirmRow(
              label: '参加人数',
              value: '${bookingState.numberOfPeople}名',
            ),
            if (bookingState.specialRequests.trim().isNotEmpty)
              _ConfirmRow(label: 'ご要望', value: bookingState.specialRequests),
          ],
        ),
        const Gap(12),

        // ─── 料金 ────────────────────────────────────────────────────────────
        _PriceSummary(plan: plan, bookingState: bookingState),
        const Gap(16),

        // ─── エラー表示 ────────────────────────────────────────────────────────
        if (bookingState.error != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  switch (bookingState.error!) {
                    NetworkError() => Icons.wifi_off,
                    GraphQLError() => Icons.error_outline,
                    ValidationError() => Icons.warning_amber_rounded,
                    UnknownError() => Icons.help_outline,
                  },
                  color: AppTheme.errorColor,
                  size: 16,
                ),
                const Gap(6),
                Expanded(
                  child: Text(
                    bookingState.error!.message,
                    style: const TextStyle(
                      color: AppTheme.errorColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // ─── ボタン ────────────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: bookingState.isSubmitting
                      ? null
                      : () => notifier.prevStep(),
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
                  onPressed: bookingState.isSubmitting ? null : onSubmit,
                  child: bookingState.isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('予約を確定する', style: TextStyle(fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConfirmSection extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;
  final List<Widget> rows;

  const _ConfirmSection({
    required this.title,
    required this.onEdit,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('編集', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...rows,
        ],
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;

  const _ConfirmRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '（未入力）' : value,
              style: TextStyle(
                fontSize: 13,
                color: value.isEmpty ? AppTheme.textHint : AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final TravelPlan plan;
  final BookingFormState bookingState;

  const _PriceSummary({required this.plan, required this.bookingState});

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
        color: AppTheme.primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '¥${_fmt(plan.effectivePrice.toInt())} × ${bookingState.numberOfPeople}名',
                style: const TextStyle(fontSize: 13),
              ),
              const Spacer(),
              Text(
                '¥${_fmt(total.toInt())}',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          if (plan.hasDiscount) ...[
            const Gap(4),
            Row(
              children: [
                const Text(
                  '割引適用',
                  style: TextStyle(fontSize: 12, color: AppTheme.accentColor),
                ),
                const Spacer(),
                Text(
                  '-¥${_fmt(((plan.price - plan.effectivePrice) * bookingState.numberOfPeople).toInt())}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 16),
          Row(
            children: [
              const Text(
                'お支払い合計',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const Spacer(),
              Text(
                '¥${_fmt(total.toInt())}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
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
