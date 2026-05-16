---
name: add-feature
description: |
  MVVM + Repository パターンに従って新機能の雛形ファイルを一括生成する。
  Model・DataSource・Repository（インターフェース+実装）・ViewModel・Screen の
  6 ファイルを同時に生成し、build_runner まで実行する。
  「〜機能を追加したい」「〜の画面を作って」「新しいFeatureを作成して」
  「〜画面のスキャフォールドをして」などのリクエストで使用する。
argument-hint: "機能名（スネークケース英語 例: hotel_search, review_submission）"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
metadata:
  version: "1.0.0"
---

# add-feature — MVVM 機能スキャフォールド

機能名: `$ARGUMENTS`

MVVM + Repository パターンに沿った雛形ファイルを一括生成します。
パターン詳細とテンプレート: `references/mvvm-pattern.md` を参照。

## 前処理

機能名を snake_case に正規化する（例: `HotelSearch` → `hotel_search`）。
PascalCase クラス名も生成しておく（例: `hotel_search` → `HotelSearch`）。

## 生成ファイル一覧

```
travel_booking_mobile/lib/
├── data/
│   ├── models/{feature}_model.dart                      # Step 1
│   ├── datasources/remote/{feature}_remote_datasource.dart  # Step 2
│   └── repositories/
│       ├── {feature}_repository.dart                    # Step 3
│       └── {feature}_repository_impl.dart              # Step 4
└── presentation/
    ├── viewmodels/{feature}_viewmodel.dart              # Step 5
    └── screens/{feature}/{feature}_screen.dart          # Step 6
```

## 実行手順

### Step 1: データモデル生成

既存モデル（`travel_plan.dart`）を参考に `{feature}_model.dart` を生成する：
- フィールド定義（`final` + 型）
- コンストラクタ（`required` 引数）
- `fromJson(Map<String, dynamic> json)` ファクトリメソッド
- `toJson()` メソッド
- `copyWith()` メソッド
- `==` オーバーライドと `hashCode`

### Step 2: Remote DataSource 生成

既存の `travel_plan_remote_datasource.dart` を参考に生成する：
- GraphQL クエリ文字列定数（`TODO: クエリを定義する` コメントつき）
- `GraphQLHttpClient` を受け取るコンストラクタ
- データ取得メソッドのスケルトン

### Step 3: Repository インターフェース生成

既存の `travel_plan_repository.dart` を参考に生成する：
- `abstract class {Feature}Repository` として定義
- 基本 CRUD メソッドのシグネチャ（実装なし）

### Step 4: Repository 実装クラス生成

既存の `travel_plan_repository_impl.dart` を参考に生成する：
- `class {Feature}RepositoryImpl implements {Feature}Repository`
- DataSource を受け取るコンストラクタ
- Repository メソッドの実装（DataSource への委譲）

### Step 5: ViewModel 生成

既存の `plan_list_viewmodel.dart` を参考に生成する：
- Provider 定義（`@riverpod`）
- State クラス（`isLoading`・`error`・データフィールド・`copyWith`）
- `@riverpod class {Feature}ViewModel extends _{Feature}ViewModel`
- `build()` メソッドと基本メソッドのスケルトン

### Step 6: Screen 生成

既存の `home_screen.dart` を参考に生成する：
- `ConsumerStatefulWidget` として生成
- ローディング状態（Shimmer）
- エラー状態（`AppErrorWidget`）
- データ表示のスケルトン

## 生成後の処理

1. **ルート追加の案内**:
   `travel_booking_mobile/lib/core/router/app_router.dart` への追加箇所を表示する

2. **コード生成実行**:
   ```bash
   cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking && melos run build_runner
   ```

3. **完了報告**:
   生成したファイル一覧と次のステップ（GraphQL クエリの実装、ルート追加）を日本語で案内する
