import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_theme.dart';

class PlanMapView extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String meetingPoint;

  // --dart-define=GOOGLE_MAPS_API_KEY=xxx で渡す。未設定時はフォールバック表示。
  static const _apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  const PlanMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.meetingPoint,
  });

  @override
  Widget build(BuildContext context) {
    // 座標が未設定（0,0）の場合は何も表示しない
    if (latitude == 0 || longitude == 0) return const SizedBox.shrink();

    // API キー未設定時はクラッシュを避けてフォールバック表示
    if (_apiKey.isEmpty) {
      return _Fallback(meetingPoint: meetingPoint);
    }

    final position = LatLng(latitude, longitude);

    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: position, zoom: 14.0),
          markers: {
            Marker(
              markerId: const MarkerId('meeting_point'),
              position: position,
              infoWindow: InfoWindow(title: meetingPoint),
            ),
          },
          myLocationEnabled: false,
          zoomControlsEnabled: true,
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  final String meetingPoint;

  const _Fallback({required this.meetingPoint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, color: AppTheme.textHint, size: 40),
          const SizedBox(height: 8),
          const Text(
            '地図を表示するには Google Maps API キーが必要です',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            meetingPoint,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textHint),
          ),
        ],
      ),
    );
  }
}
