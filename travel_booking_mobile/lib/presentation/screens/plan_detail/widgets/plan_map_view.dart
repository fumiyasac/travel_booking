import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PlanMapView extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String destination;

  const PlanMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.06),
          border: Border.all(color: AppTheme.dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.map_outlined,
              size: 48,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              destination,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '緯度: ${latitude.toStringAsFixed(4)}  経度: ${longitude.toStringAsFixed(4)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlanMapSection extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String destination;
  final String meetingPoint;

  const PlanMapSection({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.destination,
    required this.meetingPoint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '集合場所・地図',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (meetingPoint.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place, color: AppTheme.primaryColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    meetingPoint,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        PlanMapView(
          latitude: latitude,
          longitude: longitude,
          destination: destination,
        ),
      ],
    );
  }
}
