import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryColor),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
