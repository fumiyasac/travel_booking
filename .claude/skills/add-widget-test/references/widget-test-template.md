# Widget テストテンプレート集

`test/widgets/` の既存4ファイルから抽出した実装パターン。
テンプレートをそのままコピーせず、対象 Widget のソースコードを Read してから調整すること。

---

## テンプレート 1: 基本 Widget テスト

`rating_stars_test.dart` から抽出。`StatelessWidget` / `StatefulWidget` に適用。

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// 対象 Widget のインポート
import 'package:travel_booking_mobile/presentation/widgets/<widget_name>.dart';
// 追加パッケージがある場合はここに追記（例: flutter_rating_bar）

void main() {
  // ── wrap ヘルパー ────────────────────────────────────────────────────
  // props が少なく positional の場合はシンプルに
  Widget wrap(Widget child) =>
      MaterialApp(debugShowCheckedModeBanner: false, home: Scaffold(body: child));

  // ── 表示確認 ─────────────────────────────────────────────────────────
  group('表示確認', () {
    testWidgets('デフォルト props でウィジェットが描画されること', (tester) async {
      await tester.pumpWidget(wrap(const TargetWidget(/* required prop */)));

      expect(find.byType(TargetWidget), findsOneWidget);
    });

    testWidgets('テキスト "xxx" が表示されること', (tester) async {
      await tester.pumpWidget(wrap(const TargetWidget(label: 'xxx')));

      expect(find.text('xxx'), findsOneWidget);
    });

    testWidgets('アイコン Icons.xxx が表示されること', (tester) async {
      await tester.pumpWidget(wrap(const TargetWidget(/* props */)));

      expect(find.byIcon(Icons.xxx), findsOneWidget);
    });
  });

  // ── エッジケース ──────────────────────────────────────────────────────
  group('エッジケース', () {
    testWidgets('optional prop が null のとき対応する UI が非表示になること', (tester) async {
      await tester.pumpWidget(wrap(const TargetWidget(optionalProp: null)));

      expect(find.text('オプションテキスト'), findsNothing);
    });

    testWidgets('flag=false のとき対応する UI が非表示になること', (tester) async {
      await tester.pumpWidget(wrap(const TargetWidget(showSomething: false)));

      expect(find.byIcon(Icons.some_icon), findsNothing);
    });
  });
}
```

### wrap ヘルパーの使い分け

| ケース | パターン |
|---|---|
| props が少ない / positional | `Widget wrap(Widget child) => MaterialApp(...)` |
| props が多い / named パラメータ中心 | `Widget wrap({required AppError error, VoidCallback? onRetry}) => MaterialApp(...)` |
| props が多くデフォルトが欲しい | helper に引数を持たせ、テスト内でオーバーライド |

---

## テンプレート 2: コールバックテスト

`app_error_widget_test.dart` から抽出。`onTap` / `onRetry` / `onChanged` 等。

```dart
// ── コールバック確認 ──────────────────────────────────────────────────
group('コールバック確認', () {
  testWidgets('ボタンタップで onTap コールバックが呼ばれること', (tester) async {
    var called = false;
    await tester.pumpWidget(
      wrap(TargetWidget(onTap: () => called = true)),
    );

    // ElevatedButton.icon は find.text(ラベル) で特定する（Flutter 3.22+ 対応）
    await tester.tap(find.text('ボタンラベル'));
    expect(called, isTrue);
  });

  testWidgets('onTap が null のときボタンが表示されないこと', (tester) async {
    await tester.pumpWidget(wrap(const TargetWidget(onTap: null)));

    expect(find.text('ボタンラベル'), findsNothing);
  });

  testWidgets('onChanged が値を正しく渡すこと', (tester) async {
    String? received;
    await tester.pumpWidget(
      wrap(TargetWidget(onChanged: (v) => received = v)),
    );

    await tester.enterText(find.byType(TextField), '入力値');
    expect(received, '入力値');
  });
});
```

> **⚠️ Flutter 3.22+ での注意点**
> `ElevatedButton.icon()` は `_ElevatedButtonWithIcon`（private サブクラス）を返すため、
> `find.byType(ElevatedButton)` でヒットしない。
> ボタンのラベルテキストで `find.text('ラベル')` か、アイコンで `find.byIcon(Icons.xxx)` を使う。

---

## テンプレート 3: sealed class 分岐テスト

`app_error_widget_test.dart` から抽出。`AppError` 等の sealed class を受け取る Widget に適用。

```dart
import 'package:travel_booking_mobile/core/error/app_error.dart';

void main() {
  // named パラメータが多い場合は wrap に持たせる
  Widget wrap({required AppError error, VoidCallback? onRetry}) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: TargetWidget(error: error, onRetry: onRetry),
        ),
      );

  // ── NetworkError ──────────────────────────────────────────────────
  group('NetworkError', () {
    testWidgets('wifi_off アイコンと固定タイトルが表示されること', (tester) async {
      await tester.pumpWidget(wrap(error: const NetworkError()));

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('ネットワークエラー'), findsOneWidget);
    });

    testWidgets('デフォルト message が表示されること', (tester) async {
      await tester.pumpWidget(wrap(error: const NetworkError()));

      expect(find.text('通信エラーが発生しました'), findsOneWidget);
    });

    testWidgets('onRetry あり → "再試行" が表示されタップで呼ばれること', (tester) async {
      var called = false;
      await tester.pumpWidget(
        wrap(error: const NetworkError(), onRetry: () => called = true),
      );

      expect(find.text('再試行'), findsOneWidget);
      await tester.tap(find.text('再試行'));
      expect(called, isTrue);
    });
  });

  // ── GraphQLError ──────────────────────────────────────────────────
  group('GraphQLError', () {
    testWidgets('error_outline アイコンと固定タイトルが表示されること', (tester) async {
      await tester.pumpWidget(wrap(error: const GraphQLError('サーバーエラー')));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('サーバーエラー'), findsOneWidget);
    });

    testWidgets('onRetry が null のとき "再試行" が表示されないこと', (tester) async {
      await tester.pumpWidget(wrap(error: const GraphQLError('エラー')));

      expect(find.text('再試行'), findsNothing);
    });
  });

  // ── ValidationError ───────────────────────────────────────────────
  group('ValidationError', () {
    testWidgets('warning_amber_rounded アイコンと固定タイトルが表示されること', (tester) async {
      await tester.pumpWidget(
        wrap(error: const ValidationError('入力値エラー', field: 'email')),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text('入力エラー'), findsOneWidget);
    });

    testWidgets('指定した message が表示されること', (tester) async {
      await tester.pumpWidget(wrap(error: const ValidationError('メールが不正です')));

      expect(find.text('メールが不正です'), findsOneWidget);
    });
  });

  // ── UnknownError ──────────────────────────────────────────────────
  group('UnknownError', () {
    testWidgets('help_outline アイコンとデフォルト message が表示されること', (tester) async {
      await tester.pumpWidget(wrap(error: const UnknownError()));

      expect(find.byIcon(Icons.help_outline), findsOneWidget);
      expect(find.text('予期しないエラーが発生しました'), findsOneWidget);
    });
  });
}
```

### AppError サブクラスと対応するデフォルト値

| クラス | デフォルト message | 引数 |
|---|---|---|
| `NetworkError()` | `'通信エラーが発生しました'` | `[message]`（省略可） |
| `GraphQLError(message)` | なし（必須） | `message`, `{code?}` |
| `ValidationError(message)` | なし（必須） | `message`, `{field?}` |
| `UnknownError()` | `'予期しないエラーが発生しました'` | `[message]`（省略可） |

---

## テンプレート 4: ガード処理テスト

`plan_map_view_test.dart` から抽出。`null` / `0` / 空文字でガードして空 Widget を返すパターン。

```dart
void main() {
  // テスト全体で共通の定数は main() 冒頭に置く
  const validValue = 'テスト値';
  const guardValue = 0;   // または null / '' など

  Widget wrap(Widget child) =>
      MaterialApp(debugShowCheckedModeBanner: false, home: Scaffold(body: child));

  // ── ガード処理 ────────────────────────────────────────────────────
  group('ガード処理', () {
    testWidgets('guardValue のとき何も描画されないこと', (tester) async {
      await tester.pumpWidget(wrap(
        const TargetWidget(value: guardValue, label: validValue),
      ));

      // SizedBox.shrink() が返るため関連 Widget は存在しない
      expect(find.text(validValue), findsNothing);
      expect(find.byIcon(Icons.some_icon), findsNothing);
    });

    testWidgets('別の guardValue パターンでも何も描画されないこと', (tester) async {
      await tester.pumpWidget(wrap(
        const TargetWidget(value: anotherGuardValue, label: validValue),
      ));

      expect(find.text(validValue), findsNothing);
    });
  });

  // ── 正常表示 ──────────────────────────────────────────────────────
  group('正常表示', () {
    testWidgets('有効な値のとき UI が表示されること', (tester) async {
      await tester.pumpWidget(wrap(
        const TargetWidget(value: validValue, label: validValue),
      ));

      expect(find.text(validValue), findsOneWidget);
      expect(find.byIcon(Icons.some_icon), findsOneWidget);
    });

    testWidgets('異なる label の値が正しく表示されること', (tester) async {
      const anotherLabel = '別のラベル';
      await tester.pumpWidget(wrap(
        const TargetWidget(value: validValue, label: anotherLabel),
      ));

      expect(find.text(anotherLabel), findsOneWidget);
      expect(find.text(validValue), findsNothing);  // 最初の値は表示されない
    });
  });
}
```

---

## Finder クイックリファレンス

| 目的 | Finder |
|---|---|
| テキスト検索 | `find.text('文字列')` |
| アイコン検索 | `find.byIcon(Icons.xxx)` |
| 型検索（runtimeType 一致） | `find.byType(WidgetType)` |
| ウィジェット条件検索 | `find.byWidgetPredicate((w) => w is WidgetType)` |
| 子孫検索 | `find.descendant(of: parent, matching: child)` |
| 1個存在 | `findsOneWidget` |
| 0個存在 | `findsNothing` |
| N個存在 | `findsNWidgets(n)` |

## よくある落とし穴

| 症状 | 原因 | 対処 |
|---|---|---|
| `find.byType(ElevatedButton)` で 0件 | Flutter 3.22+ で `ElevatedButton.icon()` が `_ElevatedButtonWithIcon` を返す | `find.text('ラベル')` に変える |
| Text ウィジェットが予期せず見つかる | `debugShowCheckedModeBanner: true`（デフォルト）が干渉 | `MaterialApp(debugShowCheckedModeBanner: false, ...)` を指定する |
| `pumpWidget` 後に表示されない | アニメーション・非同期の未完了 | `await tester.pumpAndSettle()` を追加する |
| `ConsumerWidget` のテストでエラー | ProviderScope が必要 | このスキルの対象外。手動で `ProviderScope` + mock を設定する |
