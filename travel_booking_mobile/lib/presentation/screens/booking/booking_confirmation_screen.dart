import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final String bookingId;
  final String planTitle;
  final double totalPrice;
  final DateTime? travelDate;
  final int numberOfPeople;

  const BookingConfirmationScreen({
    super.key,
    required this.bookingId,
    required this.planTitle,
    required this.totalPrice,
    this.travelDate,
    required this.numberOfPeople,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: AppTheme.successColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
                const Gap(24),
                const Text(
                  '予約が完了しました！',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Gap(8),
                const Text(
                  '確認メールをお送りしました',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                const Gap(32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '予約詳細',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const Gap(12),
                      _DetailRow(label: '予約ID', value: bookingId.substring(0, 8).toUpperCase()),
                      _DetailRow(label: 'プラン名', value: planTitle),
                      if (travelDate != null)
                        _DetailRow(
                          label: '旅行日',
                          value: DateFormat('yyyy年M月d日').format(travelDate!),
                        ),
                      _DetailRow(label: '参加人数', value: '$numberOfPeople名'),
                      _DetailRow(
                        label: '合計金額',
                        value: '¥${_formatPrice(totalPrice.toInt())}',
                        valueStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('トップページへ'),
                  ),
                ),
                const Gap(12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/favorites'),
                    child: const Text('お気に入りを見る'),
                  ),
                ),
              ],
            ),
          ),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _DetailRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
