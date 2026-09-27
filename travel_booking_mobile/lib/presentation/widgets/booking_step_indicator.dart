import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class BookingStepIndicator extends StatelessWidget {
  static const _defaultLabels = ['旅行者情報', '日程・人数', '入力確認'];

  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const BookingStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
    this.stepLabels = _defaultLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < totalSteps; i++) ...[
          _StepItem(
            index: i,
            label: stepLabels[i],
            isActive: i == currentStep,
            isCompleted: i < currentStep,
          ),
          if (i < totalSteps - 1)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Container(
                  height: 2,
                  color: i < currentStep
                      ? AppTheme.primaryColor
                      : AppTheme.dividerColor,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final int index;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepItem({
    required this.index,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (isActive || isCompleted) {
      color = AppTheme.primaryColor;
    } else {
      color = AppTheme.textHint;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppTheme.primaryColor : Colors.transparent,
            border: isCompleted ? null : Border.all(color: color, width: 2),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
