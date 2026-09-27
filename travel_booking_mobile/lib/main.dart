import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

// --dart-define=GOOGLE_MAPS_API_KEY=xxx で渡されたキー
const _googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initGoogleMaps();
  runApp(const ProviderScope(child: TravelBookingApp()));
}

/// iOS の GMSServices.provideAPIKey() を MethodChannel 経由で呼ぶ。
/// Android はビルド時に build.gradle.kts が DART_DEFINES から読むため不要。
Future<void> _initGoogleMaps() async {
  if (!Platform.isIOS) return;
  if (_googleMapsApiKey.isEmpty) return;
  try {
    await const MethodChannel('travel_booking/google_maps')
        .invokeMethod<void>('initialize', {'apiKey': _googleMapsApiKey});
  } catch (_) {
    // テスト環境など channel が未接続の場合は無視
  }
}
