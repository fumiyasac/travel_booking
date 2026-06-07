// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// ignore: depend_on_referenced_packages
import 'package:widgetbook/widgetbook.dart';
// ignore: depend_on_referenced_packages
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../core/theme/app_theme.dart';
import 'main.directories.g.dart';

void main() {
  runApp(const WidgetbookPreviewApp());
}

@widgetbook.App()
class WidgetbookPreviewApp extends StatelessWidget {
  const WidgetbookPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: AppTheme.lightTheme),
          ],
        ),
        ViewportAddon([
          IosViewports.iPhone13,
          AndroidViewports.samsungGalaxyA50,
        ]),
        TextScaleAddon(min: 0.85, max: 2.0),
        LocalizationAddon(
          locales: [const Locale('ja', 'JP')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ],
    );
  }
}
