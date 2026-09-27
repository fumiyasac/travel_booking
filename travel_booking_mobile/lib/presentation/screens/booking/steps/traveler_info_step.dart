import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../viewmodels/booking_viewmodel.dart';

/// Step 1: 旅行者情報（お名前・メールアドレス・電話番号）
class TravelerInfoStep extends ConsumerWidget {
  const TravelerInfoStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errors = ref.watch(
      bookingViewModelProvider.select((s) => s.validationErrors),
    );
    final notifier = ref.read(bookingViewModelProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        const _SectionTitle(title: 'お客様情報'),
        const Gap(12),
        _BookingTextField(
          label: 'お名前（代表者）',
          hint: '山田 太郎',
          icon: Icons.person_outline,
          onChanged: notifier.updateCustomerName,
          errorText: errors['customerName'],
        ),
        const Gap(12),
        _BookingTextField(
          label: 'メールアドレス',
          hint: 'example@email.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          onChanged: notifier.updateCustomerEmail,
          errorText: errors['customerEmail'],
        ),
        const Gap(12),
        _BookingTextField(
          label: '電話番号',
          hint: '090-1234-5678',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          onChanged: notifier.updateCustomerPhone,
          errorText: errors['customerPhone'],
        ),
        const Gap(8),
        const Text(
          '※電話番号は数字・ハイフン・括弧・スペースで10〜15桁入力してください',
          style: TextStyle(fontSize: 11, color: AppTheme.textHint),
        ),
        const Gap(32),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () => notifier.nextStep(),
            child: const Text('次へ: 日程・人数を選択', style: TextStyle(fontSize: 15)),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

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

class _BookingTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final void Function(String) onChanged;
  final String? errorText;

  const _BookingTextField({
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        errorText: errorText,
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }
}
