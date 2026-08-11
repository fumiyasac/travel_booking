import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/booking.dart';
import '../../viewmodels/booking_history_viewmodel.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/loading_indicator.dart';

// TODO: 認証導入後にログイン中ユーザーのメールアドレスを動的取得に変更
const _kCustomerEmail = 'test@example.com';

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(bookingHistoryViewModelProvider.notifier)
          .loadBookings(_kCustomerEmail);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingHistoryViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('予約履歴')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(BookingHistoryState state) {
    if (state.isLoading) {
      return const LoadingIndicator(message: '予約履歴を読み込み中...');
    }

    if (state.error != null) {
      return AppErrorWidget(
        message: state.error!.message,
        onRetry: () => ref
            .read(bookingHistoryViewModelProvider.notifier)
            .loadBookings(_kCustomerEmail),
      );
    }

    if (state.bookings.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(bookingHistoryViewModelProvider.notifier)
          .loadBookings(_kCustomerEmail),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.bookings.length,
        itemBuilder: (context, index) =>
            _BookingCard(booking: state.bookings[index]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.textHint),
          SizedBox(height: 16),
          Text(
            '予約履歴がありません',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'プランを予約するとここに表示されます',
            style: TextStyle(color: AppTheme.textHint, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy年MM月dd日', 'ja');

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/plan/${booking.planId}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.planTitle ?? 'プラン名不明',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: booking.status),
                ],
              ),
              if (booking.planTitle != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      booking.planTitle ?? '',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: '旅行日',
                value: dateFormat.format(booking.travelDate),
              ),
              const SizedBox(height: 6),
              _InfoRow(
                icon: Icons.people_outline,
                label: '人数',
                value: '${booking.numberOfPeople}名',
              ),
              const SizedBox(height: 6),
              _InfoRow(
                icon: Icons.payments_outlined,
                label: '合計金額',
                value:
                    '¥${NumberFormat('#,###').format(booking.totalPrice.toInt())}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 6),
        Text(
          '$label：',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color get _color {
    return switch (status) {
      'CONFIRMED' => AppTheme.successColor,
      'PENDING' => AppTheme.accentColor,
      _ => AppTheme.textHint,
    };
  }

  String get _label {
    return switch (status) {
      'CONFIRMED' => '確定',
      'PENDING' => '確認中',
      'CANCELLED' => 'キャンセル済',
      _ => status,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
