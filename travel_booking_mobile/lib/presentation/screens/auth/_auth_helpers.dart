import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// 認証フォームで共通利用するテキストフィールド。
Widget authTextField({
  required TextEditingController controller,
  required String label,
  TextInputType keyboardType = TextInputType.text,
  bool enabled = true,
  bool obscureText = false,
  Widget? suffixIcon,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    enabled: enabled,
    decoration: InputDecoration(labelText: label, suffixIcon: suffixIcon),
  );
}

/// 認証画面共通のヘッダ（アイコン＋タイトル＋サブタイトル）。
class AuthFormHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AuthFormHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 72, color: AppTheme.primaryColor),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

/// 認証画面共通の送信ボタン（ローディング中は Indicator に切り替わる）。
class AuthSubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(label),
    );
  }
}
