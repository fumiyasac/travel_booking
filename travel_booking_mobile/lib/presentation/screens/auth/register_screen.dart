import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/app_error_widget.dart';
import '_auth_helpers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await ref
        .read(authStateProvider.notifier)
        .register(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
    if (success && mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('アカウント登録')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const AuthFormHeader(
                icon: Icons.person_add_alt_1,
                title: 'アカウントを作成',
                subtitle: '旅行予約を始めましょう',
              ),
              const SizedBox(height: 40),
              authTextField(
                controller: _nameController,
                label: 'お名前',
                enabled: !authState.isLoading,
              ),
              const SizedBox(height: 16),
              authTextField(
                controller: _emailController,
                label: 'メールアドレス',
                keyboardType: TextInputType.emailAddress,
                enabled: !authState.isLoading,
              ),
              const SizedBox(height: 16),
              authTextField(
                controller: _passwordController,
                label: 'パスワード（6文字以上）',
                obscureText: _obscurePassword,
                enabled: !authState.isLoading,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 24),
              if (authState.error != null) ...[
                AppErrorWidget(error: authState.error!),
                const SizedBox(height: 16),
              ],
              AuthSubmitButton(
                label: '登録する',
                isLoading: authState.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('既にアカウントをお持ちの方はこちら'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
