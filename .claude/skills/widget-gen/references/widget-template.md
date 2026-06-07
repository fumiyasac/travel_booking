# ウィジェット ボイラープレート テンプレート

既存の `rating_stars.dart` / `loading_indicator.dart` / `app_error_widget.dart` から
抽出したコーディング規約に基づくテンプレート集。

---

## AppTheme 色定数一覧

ハードコードな `Color(0x...)` は禁止。必ず下記の定数を使うこと。

| 定数名 | 用途の目安 |
|---|---|
| `AppTheme.primaryColor` | メインカラー（ボタン・アイコン・アクセント） |
| `AppTheme.secondaryColor` | サブカラー（補助的な強調） |
| `AppTheme.accentColor` | 警告・注目系（オレンジ） |
| `AppTheme.surfaceColor` | 背景・サーフェス |
| `AppTheme.cardColor` | カード背景（白） |
| `AppTheme.textPrimary` | 本文・見出しテキスト |
| `AppTheme.textSecondary` | サブテキスト・補足情報 |
| `AppTheme.textHint` | プレースホルダー・非活性テキスト |
| `AppTheme.dividerColor` | 区切り線・ボーダー |
| `AppTheme.starColor` | 星アイコン（評価） |
| `AppTheme.errorColor` | エラー・危険表示 |
| `AppTheme.successColor` | 成功・完了表示 |

---

## StatelessWidget テンプレート

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// <責務の説明を1行で書く（例: 価格とバッジを表示する共通ウィジェット）>
class ExampleWidget extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isHighlighted;

  const ExampleWidget({
    super.key,
    required this.label,
    this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isHighlighted
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            color: isHighlighted ? AppTheme.primaryColor : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
```

**規約チェックリスト（StatelessWidget）:**
- [ ] `part of` 宣言なし
- [ ] クラス直上に 1 行コメントあり
- [ ] `const` コンストラクタに `super.key`
- [ ] `required` / 省略可能パラメータの区別が適切
- [ ] `@override` が `build()` に付いている
- [ ] `Color` 直書きなし（`AppTheme` 定数のみ）
- [ ] `@riverpod` / `ConsumerWidget` を使っていない

---

## StatefulWidget テンプレート

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// <責務の説明を1行で書く（例: アニメーション付きの展開・折りたたみウィジェット）>
class ExampleStatefulWidget extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const ExampleStatefulWidget({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  State<ExampleStatefulWidget> createState() => _ExampleStatefulWidgetState();
}

class _ExampleStatefulWidgetState extends State<ExampleStatefulWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  void dispose() {
    // リソースが必要な場合はここで解放（Controller・Timer など）
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 8),
          widget.child,
        ],
      ],
    );
  }
}
```

**規約チェックリスト（StatefulWidget）:**
- [ ] `const` コンストラクタは **Widget クラス側**に付ける（State 側は不要）
- [ ] `State<WidgetName>` の型パラメータを明記する
- [ ] `_State` クラス名はプライベート（先頭 `_`）
- [ ] `initState()` は `super.initState()` を最初に呼ぶ
- [ ] `dispose()` は `super.dispose()` を最後に呼ぶ
- [ ] `widget.xxx` でコンストラクタ引数にアクセスする
- [ ] 状態変更は必ず `setState(() { ... })` で囲む
- [ ] `@override` を `createState` / `initState` / `dispose` / `build` すべてに付ける

---

## ウィジェットテスト テンプレート

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_booking_mobile/presentation/widgets/example_widget.dart';

void main() {
  // ProviderScope は不要（純粋な UI ウィジェットのため）
  Widget buildWidget({
    required String label,
    VoidCallback? onTap,
    bool isHighlighted = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ExampleWidget(
          label: label,
          onTap: onTap,
          isHighlighted: isHighlighted,
        ),
      ),
    );
  }

  // ── 1. 表示確認 ──────────────────────────────────────────
  group('ExampleWidget 表示確認', () {
    testWidgets('ラベルが正しく表示される', (tester) async {
      await tester.pumpWidget(buildWidget(label: 'テストラベル'));

      expect(find.text('テストラベル'), findsOneWidget);
    });

    testWidgets('isHighlighted が false のとき通常スタイルで表示される', (tester) async {
      await tester.pumpWidget(buildWidget(label: 'ラベル'));

      expect(find.byType(ExampleWidget), findsOneWidget);
    });

    testWidgets('isHighlighted が true のとき強調スタイルで表示される', (tester) async {
      await tester.pumpWidget(buildWidget(label: 'ラベル', isHighlighted: true));

      expect(find.byType(ExampleWidget), findsOneWidget);
    });
  });

  // ── 2. コールバック確認 ───────────────────────────────────
  group('ExampleWidget コールバック確認', () {
    testWidgets('onTap が呼ばれる', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildWidget(label: 'タップ', onTap: () => tapped = true),
      );

      await tester.tap(find.byType(ExampleWidget));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  // ── 3. エッジケース ───────────────────────────────────────
  group('ExampleWidget エッジケース', () {
    testWidgets('onTap が null でもクラッシュしない', (tester) async {
      await tester.pumpWidget(buildWidget(label: 'ラベル', onTap: null));

      await tester.tap(find.byType(ExampleWidget));
      await tester.pump();

      expect(find.byType(ExampleWidget), findsOneWidget);
    });

    testWidgets('空文字ラベルでもクラッシュしない', (tester) async {
      await tester.pumpWidget(buildWidget(label: ''));

      expect(find.byType(ExampleWidget), findsOneWidget);
    });
  });
}
```

**テスト規約チェックリスト:**
- [ ] `testWidgets` を使う（`test()` は使わない）
- [ ] `pumpWidget` のラップは `MaterialApp` のみ（`ProviderScope` 不要）
- [ ] `buildWidget` ヘルパーでパラメータの組み合わせを簡潔に書く
- [ ] グループは「表示確認」「コールバック確認」「エッジケース」の 3 つ以上
- [ ] `await tester.pump()` をインタラクション後に呼ぶ
- [ ] アニメーション完了待ちは `await tester.pumpAndSettle()`

---

## よくある実装パターン

### 条件付き子ウィジェット（スプレッド構文）

```dart
Column(
  children: [
    Text(title),
    if (subtitle != null) ...[
      const SizedBox(height: 4),
      Text(subtitle!, style: const TextStyle(color: AppTheme.textSecondary)),
    ],
  ],
)
```

### アイコン付きテキスト行

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(icon, size: 16, color: AppTheme.textSecondary),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
  ],
)
```

### タップ可能コンテナ（`InkWell` + `borderRadius`）

```dart
InkWell(
  onTap: onTap,
  borderRadius: BorderRadius.circular(12),
  child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: AppTheme.dividerColor),
      borderRadius: BorderRadius.circular(12),
    ),
    child: content,
  ),
)
```

### 空状態プレースホルダー

```dart
Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 48, color: AppTheme.textHint),
      const SizedBox(height: 12),
      Text(
        message,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
      ),
    ],
  ),
)
```
