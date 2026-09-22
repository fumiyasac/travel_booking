# テスト修復エラーパターン集

`test-fix` スキルが参照するプロジェクト固有のエラーカテゴリと修正手順。
エラーメッセージからカテゴリを判定し、対応セクションの手順に従う。

---

## カテゴリ A: コード生成未実行（.g.dart / build_runner）

### 識別パターン

```
The getter 'planListViewModelProvider' isn't defined for the type '...'
Target of URI hasn't been generated: 'xxx_viewmodel.g.dart'
Error: 'xxxProvider' isn't defined
```

### 原因

`@riverpod` アノテーション付きクラスを変更後に `build_runner` を実行していない。
`*.g.dart` が古い状態か、ファイル自体が存在しない。

### 修正手順

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking
dart run melos run build_runner
```

### 確認

```bash
# .g.dart が更新されたか確認
git diff --name-only | grep '\.g\.dart'
# または ls で存在確認
ls travel_booking_mobile/lib/presentation/viewmodels/*.g.dart
```

### このプロジェクトで発生しやすい箇所

| ファイル | 生成先 |
|---|---|
| `*_viewmodel.dart`（`@riverpod` Notifier） | `*_viewmodel.g.dart` |
| `preview/main.dart`（`@widgetbook.App`） | `preview/main.directories.g.dart` |

---

## カテゴリ B: Flutter 3.22+ Finder 問題

### 識別パターン

```
Expected: exactly one matching node in the widget tree
Actual: _WidgetAppBarState:<...>
No widget with type ElevatedButton found
```

テストコード中に `find.byType(ElevatedButton)` が使われている場合。

### 原因

Flutter 3.22 以降、`ElevatedButton.icon()` は `_ElevatedButtonWithIcon`（private サブクラス）を返す。
`find.byType` は `runtimeType ==` による完全一致のため、スーパークラス `ElevatedButton` でヒットしない。

### 修正手順

1. 失敗しているテストファイルを Read する
2. `find.byType(ElevatedButton)` を探す
3. 対応する Widget ソースを Read してボタンのラベルテキストを確認する
4. `find.text('ラベル')` または `find.byIcon(Icons.xxx)` に置換する

```dart
// NG（Flutter 3.22+）
expect(find.byType(ElevatedButton), findsOneWidget);
await tester.tap(find.byType(ElevatedButton));

// OK
expect(find.text('再試行'), findsOneWidget);
await tester.tap(find.text('再試行'));
```

### このプロジェクトで発生しやすい箇所

| Widget | ボタンラベル |
|---|---|
| `AppErrorWidget` | `'再試行'`（`ElevatedButton.icon` + `Icons.refresh`） |
| `BookingScreen` の送信ボタン | `'予約を確定する'` |
| `FavoriteScreen` の空状態ボタン | `'プランを探す'` |

---

## カテゴリ C: Mock ファイル未生成（.mocks.dart）

### 識別パターン

```
Target of URI doesn't exist: 'plan_list_viewmodel_test.mocks.dart'
Error: Could not resolve the package 'travel_booking_mobile'
class MockTravelPlanRepository is not defined
```

### 原因

`@GenerateMocks([TravelPlanRepository])` アノテーションを追加後に
`build_runner` を実行していないため、`.mocks.dart` ファイルが存在しない。

### 修正手順

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking
dart run melos run build_runner
```

生成されるファイル: `test/viewmodels/<test_name>_test.mocks.dart`

### 確認

```bash
ls travel_booking_mobile/test/viewmodels/*.mocks.dart
```

### このプロジェクトの Mock 生成対象

```dart
// 各テストファイルの先頭に記述
@GenerateMocks([TravelPlanRepository])   // plan 系テスト
@GenerateMocks([FavoriteRepository])     // favorite 系テスト
```

> **注意**: `.mocks.dart` ファイルは手動編集禁止。
> Mock の振る舞いを変えたい場合は `when(...).thenAnswer(...)` をテスト側で定義する。

---

## カテゴリ D: assert 違反（AssertionError）

### 識別パターン

```
Failed assertion: line XX pos XX: 'rating >= 0.0': is not true.
AssertionError: 'xxx >= 0': is not true.
```

### 原因とプロジェクト固有の例

#### D-1: `flutter_rating_bar` の負の値ガード

`RatingBarIndicator` は `assert(rating >= 0.0)` を持つ。
テストデータに `-1.0` などの負の値を渡すとクラッシュする。

**修正**: `rating_stars.dart` の `RatingBarIndicator` に `clamp` を追加する

```dart
// NG
RatingBarIndicator(
  rating: rating,
  ...
)

// OK
RatingBarIndicator(
  rating: rating.clamp(0.0, 5.0),
  ...
)
```

#### D-2: `itemSize` に 0 以下を渡す

`RatingBarIndicator` は `itemSize > 0` を要求する。

```dart
// OK: size は正の値のみ受け付ける
RatingBarIndicator(
  itemSize: size.clamp(1.0, double.infinity),
  ...
)
```

### テスト側での対応（修正不要なケース）

assert 違反が「正しく失敗すること」を検証するテストの場合は、
`tester.takeException()` で例外を捕捉する：

```dart
testWidgets('不正な値でエラーになること', (tester) async {
  await tester.pumpWidget(wrap(const SomeWidget(value: -1)));
  expect(tester.takeException(), isA<AssertionError>());
});
```

---

## カテゴリ E: TypeScript / Jest エラー（Backend）

### 識別パターン

```
error TS2345: Argument of type 'X' is not assignable to parameter of type 'Y'
FAIL src/__tests__/xxx.test.ts
Cannot find module '@/graphql/resolvers' from 'src/__tests__/xxx.test.ts'
```

### E-1: 型エラー（TypeScript コンパイルエラー）

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_backend
npx tsc --noEmit
```

Docker が起動中の場合：

```bash
docker compose exec backend npx tsc --noEmit
```

よくある原因と修正：

| エラー | 原因 | 修正 |
|---|---|---|
| `Property 'xxx' does not exist on type 'Context'` | `Context` 型に新フィールドを追加したが `index.ts` を更新していない | `src/index.ts` の `Context` インターフェースを更新 |
| `Object is possibly 'null'` | Prisma クエリ結果の null チェック漏れ | `if (!result) throw new GraphQLError(...)` を追加 |
| `Type 'string' is not assignable to type 'Date'` | 日付フィールドを string でそのまま返している | `.toISOString()` で変換 |

### E-2: Jest テスト失敗

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_backend
npm test -- --verbose 2>&1 | head -60
```

よくある原因と修正：

| エラー | 原因 | 修正 |
|---|---|---|
| `Cannot find module` | import パスが間違っている | パスを `src/` からの相対パスに修正 |
| `PrismaClient is not defined` | テスト環境でのモック未設定 | `jest.mock('@prisma/client')` を追加 |
| `Network request failed` | テスト環境で実DBへの接続を試みている | `.env.test` を作成して `DATABASE_URL` をインメモリ DB に変更 |

### E-3: Docker が起動していない場合の対処

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_backend
docker compose ps
```

起動していない場合は `/backend-up` スキルを案内する。

---

## カテゴリ不明: 未知のエラー

上記5カテゴリに該当しない場合、以下を表示してユーザーに手動対応を依頼する：

```
⚠️ 未知のエラーが検出されました

エラーメッセージ:
  （エラー全文）

ファイル:
  （テストファイルパス:行番号）

推奨アクション:
  1. エラーメッセージで検索して原因を特定してください
  2. /bug-trace <エラーメッセージ> で詳細な原因特定を依頼できます
```

---

## 修復チェックリスト

修復完了後に以下を確認する：

- [ ] `dart run melos run test` で全テストグリーン
- [ ] `dart run melos run analyze` でエラーなし（Warning は許容）
- [ ] `.g.dart` / `.mocks.dart` が git でトラッキングされている（手動編集されていない）
- [ ] Backend: `npx tsc --noEmit` でエラーなし（`--all` の場合）
