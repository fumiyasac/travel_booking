# impact-analysis チェックリスト

`impact-analysis` スキルが参照する grep コマンドパターン、カテゴリ分類、レポートテンプレート、よくある影響パターンをまとめたファイル。

---

## 1. 依存追跡の grep コマンドパターン

### Flutter（Dart）の場合

```bash
# ファイルパス指定: そのファイルを import しているファイルを検索
grep -rl "import.*<パッケージ名>/<パス>" \
  travel_booking_mobile/lib/ \
  travel_booking_mobile/test/ \
  2>/dev/null | head -20

# クラス名指定: クラス名を使用しているファイルを検索
grep -rl "<クラス名>" \
  travel_booking_mobile/lib/ \
  travel_booking_mobile/test/ \
  2>/dev/null | grep -E '\.dart$' | head -20
```

**パッケージ名の変換例**:

| ファイルパス | import パス（grep 用） |
|---|---|
| `lib/core/config/graphql_config.dart` | `travel_booking_mobile/lib/core/config/graphql_config` |
| `lib/data/models/travel_plan.dart` | `travel_booking_mobile/lib/data/models/travel_plan` |
| `lib/data/repositories/favorite_repository.dart` | `travel_booking_mobile/lib/data/repositories/favorite_repository` |

### TypeScript（バックエンド）の場合

```bash
# ファイルパスで検索（相対 import）
grep -rl "from.*['\"].*<パス>['\"]" \
  travel_booking_backend/src/ \
  travel_booking_backend/__tests__/ \
  2>/dev/null | head -20

# クラス名・関数名で検索
grep -rl "<名前>" \
  travel_booking_backend/src/ \
  travel_booking_backend/__tests__/ \
  2>/dev/null | grep -E '\.ts$' | head -20
```

### 再帰的な依存追跡（最大2階層）

```bash
# 1階層目の依存ファイルを取得
DIRECT=$(grep -rl "import.*<対象>" travel_booking_mobile/lib/ 2>/dev/null)

# 2階層目: 1階層目のファイルを import しているファイルを検索
for f in $DIRECT; do
  BASENAME=$(basename "$f" .dart)
  grep -rl "import.*$BASENAME" travel_booking_mobile/lib/ 2>/dev/null
done | sort -u | head -20
```

---

## 2. カテゴリ分類のディレクトリマッピング

| ディレクトリ | カテゴリ |
|---|---|
| `lib/presentation/screens/` | Screen |
| `lib/presentation/viewmodels/` | ViewModel |
| `lib/presentation/widgets/` | Widget |
| `lib/data/repositories/` | Repository |
| `lib/data/datasources/` | DataSource |
| `lib/core/` | Core |
| `lib/preview/` | Preview |
| `test/viewmodels/` | ViewModel テスト |
| `test/widgets/` | Widget テスト |
| `src/__tests__/` | Resolver テスト |

---

## 3. レポートテンプレート（Step 6 の出力例）

```
影響分析レポート: GraphQLHttpClient
━━━━━━━━━━━━━━━━━━━━━━━━
対象: travel_booking_mobile/lib/core/config/graphql_config.dart

【依存ファイル】 4件
  直接依存（import している）:
    - lib/data/datasources/remote/travel_plan_remote_datasource.dart (DataSource)
    - lib/presentation/viewmodels/plan_list_viewmodel.dart (ViewModel)
    ...
  間接依存（依存ファイルをさらに import）:
    - lib/presentation/screens/home/home_screen.dart (Screen)
    - lib/presentation/screens/plan_detail/plan_detail_screen.dart (Screen)
    ...

【影響テスト】 3件
  mock 更新が必要:
    - test/viewmodels/plan_list_viewmodel_test.dart
      — 理由: MockTravelPlanRepository 経由で GraphQLHttpClient を参照
    ...
  影響なし:
    - test/viewmodels/favorite_viewmodel_test.dart
      — 理由: GraphQL を使わない SharedPreferences 系のテスト

【ドキュメント更新】 2箇所
  - architecture_guidance.md: Section 2-5 Core Layer (行235) — デフォルト接続先の記述
  - architecture_guidance.md: Section 2-6 Provider 一覧 (行263) — graphQLHttpClientProvider の説明
  ...

【スキル更新】 1件
  - preview-setup: references/preview-structure.md — mock_providers.dart の GraphQLHttpClient 参照

【推奨アクション】
  1. graphql_config.dart のシグネチャ変更内容を確定する
  2. TravelPlanRemoteDataSource の参照箇所を更新する（直接依存 1件）
  3. /test-fix で一括テスト修復
  4. /doc-sync --fix でドキュメント同期
```

---

## 4. よくある影響パターンの具体例

### GraphQLHttpClient 変更時

```
直接依存 → travel_plan_remote_datasource.dart（1件）
間接依存 → travel_plan_repository_impl.dart → plan_list_viewmodel.dart など
テスト影響 → MockTravelPlanRepository を使う全 ViewModel テスト（mock 差し替えが必要な場合あり）
ドキュメント → architecture_guidance.md Section 2-5 Core Layer（接続先・設定値の記述）
スキル → preview-setup の mock_providers テンプレート（FakeTravelPlanRepository が依存する場合）
```

**注意点**: `graphQLHttpClientProvider` は `autoDispose` のため、画面遷移のたびに再生成される。シングルトン化する場合は Provider の `keepAlive` 変更と合わせて全依存を確認する。

---

### Model のフィールド追加時

```
直接依存 → 該当 Model を fromJson / toJson で使う DataSource / Repository
間接依存 → 該当 Repository を使う ViewModel → Screen
テスト影響 → テストデータ（mockPlan など）の更新が必要な全テスト
ドキュメント → architecture_guidance.md Section 2-3 モデル一覧テーブル
スキル → add-mock-data の data-patterns テンプレート（モックデータ定義に新フィールドを追加）
```

**注意点**: `toJson` / `fromJson` / `copyWith` の3メソッドすべてに追加漏れがないか確認する。GraphQL クエリ文字列（DataSource 内の `static const` ）にもフィールド追加が必要。

---

### ViewModel の State フィールド変更時

```
直接依存 → 該当 Screen（state.xxx を参照している Widget）
間接依存 → 影響なし（通常）
テスト影響 → ViewModel テストの state 検証部分（expect(state.xxx, ...) の更新）
ドキュメント → 影響なし（通常。State クラス自体は architecture_guidance.md に列挙されていない）
スキル → add-viewmodel-test のテストテンプレート（State フィールド検証のサンプルコード）
```

**注意点**: `copyWith` を追加・変更した場合、`clearError: true` のような bool フラグ引数のデフォルト値を確認する。

---

### Repository インターフェース変更時

```
直接依存 → 該当 RepositoryImpl（実装クラス）+ ViewModel（依存 Provider 経由）
間接依存 → Screen
テスト影響 → @GenerateMocks([対象Repository]) で生成した .mocks.dart の再生成が必要
             → build_runner 再実行（カテゴリ C: Mock ファイル未生成）
ドキュメント → architecture_guidance.md Section 2-3 Repository 一覧テーブル
スキル → add-viewmodel-test（テンプレート内の MockRepository 参照）
```

**注意点**: インターフェース変更後は必ず `dart run melos run build_runner` を実行して `.mocks.dart` を再生成する。

---

### Riverpod Provider の keepAlive 変更時

```
直接依存 → 該当 Provider を ref.watch / ref.read しているすべての ViewModel / Provider
間接依存 → 上記 ViewModel を使う Screen
テスト影響 → ProviderContainer.overrides で該当 Provider を差し替えているテスト
ドキュメント → architecture_guidance.md Section 2-6 Provider 一覧（keepAlive 列）
               → architecture_guidance.md Section 2-6 Provider 依存関係グラフ（keepAlive グループ）
スキル → 影響なし（通常）
```

**注意点**: `keepAlive: false`（autoDispose）から `keepAlive: true` に変更すると、画面離脱後も Provider が生存し続けるため、意図しないメモリ保持が発生する可能性がある。`/state-audit` で副作用を確認することを推奨。

---

## 5. 分析打ち切り基準

| 状況 | 対応 |
|---|---|
| 直接依存が 0 件 | 「この変更は外部に影響しません」と報告して終了 |
| 直接依存が 20 件超 | 上位 20 件を表示し「他 N 件（詳細省略）」と追記 |
| 間接依存の追跡が 3 階層以上に及ぶ | 2 階層で打ち切り「さらに深い依存があります（詳細は省略）」と追記 |
| バックエンド・モバイル両方に影響 | 両方のセクションを分けて報告 |
