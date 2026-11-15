import 'package:flutter/material.dart';

import '../../../core/error/app_error.dart';
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

/// 認証フォーム向けインラインエラーバナー。
///
/// [AppErrorWidget] はフルページ向け（大アイコン＋タイトル）のため、
/// フォーム内では代わりにこのウィジェットを使う。
/// エラーの種別に関わらずバックエンドから返ってきた日本語メッセージを
/// そのまま赤文字で表示する。
class AuthInlineError extends StatelessWidget {
  final AppError error;

  const AuthInlineError({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final message = switch (error) {
      NetworkError() => '通信エラーが発生しました。接続を確認してください。',
      GraphQLError(:final message) => message,
      ValidationError(:final message) => message,
      UnknownError(:final message) => message,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEF9A9A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 18, color: Color(0xFFC62828)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFC62828),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
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
