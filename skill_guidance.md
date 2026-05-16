# Claude Code スキル活用ガイド — travel_booking

このプロジェクトには 10 個のカスタムスキルが定義されています。
Claude Code のチャット欄でスキル名を呼びかけるだけで自動起動するものと、
`/スキル名 [引数]` と明示的に呼び出すものがあります。

---

## スキル一覧早見表

| スキル名 | 起動方法 | 概要 | 自動起動 |
|---|---|---|:---:|
| `flutter-gen` | `/flutter-gen` または自然文 | Riverpod `.g.dart` コード生成 | ✓ |
| `backend-up` | `/backend-up` のみ | Docker バックエンド環境起動 | — |
| `db-reset` | `/db-reset` のみ | 開発用 DB 初期化（要確認） | — |
| `fix-endpoint` | `/fix-endpoint [IP]` のみ | GraphQL 接続先変更 | — |
| `graphql-check` | `/graphql-check` または自然文 | バックエンドとモバイルの GraphQL 整合性確認 | ✓ |
| `add-feature` | `/add-feature <機能名>` | MVVM+Repository 雛形ファイル一括生成 | — |
| `schema-update` | `/schema-update <変更内容>` または自然文 | DB〜Dart 全レイヤースキーマ変更 | ✓ |
| `bug-trace` | `/bug-trace <エラー>` または自然文 | バグ原因特定と修正 | ✓ |
| `add-viewmodel-test` | `/add-viewmodel-test <名前>` または自然文 | ViewModel テスト追加 | ✓ |
| `state-audit` | `/state-audit <名前>` または自然文 | 状態管理の問題チェック（独立実行） | ✓ |

> **自動起動 ✓**: 関連する自然な文章でも Claude が自動的にスキルを起動します。  
> **自動起動 —**: `disable-model-invocation: true` のため `/コマンド` での明示呼び出しが必要です。

---

## スキルファイルの構成

各スキルは `.claude/skills/スキル名/` ディレクトリ内に格納されています。

```
.claude/skills/
├── flutter-gen/
│   └── SKILL.md                    # 実行手順
├── backend-up/
│   └── SKILL.md
├── db-reset/
│   └── SKILL.md
├── fix-endpoint/
│   ├── SKILL.md
│   └── references/
│       └── platform-guide.md       # 環境別設定・dart-define ガイド
├── graphql-check/
│   ├── SKILL.md
│   └── references/
│       └── check-targets.md        # チェック対象ファイル一覧
├── add-feature/
│   ├── SKILL.md
│   └── references/
│       └── mvvm-pattern.md         # MVVM パターン・テンプレートコード
├── schema-update/
│   ├── SKILL.md
│   └── references/
│       └── layer-guide.md          # レイヤー別変更ルール・コード例
├── bug-trace/
│   ├── SKILL.md
│   └── references/
│       └── error-patterns.md       # エラーパターン辞書（5系統）
├── add-viewmodel-test/
│   ├── SKILL.md
│   └── references/
│       └── test-pattern.md         # テストコードテンプレート集
└── state-audit/
    ├── SKILL.md
    └── references/
        └── checklist.md            # 監査チェックリスト・コード例
```

---

## SKILL.md の frontmatter 設計について

各 SKILL.md は以下の frontmatter で動作を制御しています。

```yaml
---
name: スキル名
description: |
  # Claudeが「いつ使うか」を判断する記述
  # 具体的な自然文トリガーを含める
argument-hint: "引数の説明（タブ補完に表示）"
allowed-tools:        # このスキル実行時に自動許可するツール
  - Read
  - Edit
  - Bash
disable-model-invocation: true   # 手動実行専用（破壊的操作に設定）
context: fork                    # 独立実行（本会話コンテキストを汚さない）
metadata:
  version: "1.0.0"
---
```

| frontmatter | 使用スキル | 理由 |
|---|---|---|
| `disable-model-invocation: true` | `backend-up`・`db-reset`・`fix-endpoint` | 副作用・破壊的操作のため手動専用 |
| `context: fork` | `graphql-check`・`state-audit` | 読み取り専用の分析タスクで本会話を汚さない |

---

## スキル別詳細

---

### flutter-gen — Riverpod コード生成

#### 概要
`melos run build_runner` を実行して `@riverpod` アノテーション付きクラスの `.g.dart` ファイルを再生成します。

#### 起動方法
```
/flutter-gen
```
または以下の自然文で自動起動：
- 「コード生成して」
- 「build_runner を実行して」
- 「Provider が見つからない」
- 「getter 'xxxProvider' isn't defined」

#### 実行内容
1. `@riverpod` 付きファイルを確認
2. `melos run build_runner` を実行
3. 生成・更新された `.g.dart` ファイルを一覧表示
4. エラーがあれば原因と修正方法を日本語で説明

#### こんな時に使う
- ViewModel を新規作成・変更したとき
- `The getter 'xxxProvider' isn't defined` エラーが出たとき
- `add-feature` や `add-viewmodel-test` の実行後

---

### backend-up — バックエンド環境起動

#### 概要
Docker Compose で MySQL + Apollo GraphQL サーバーをバックグラウンド起動します。
副作用があるため **`/backend-up` の明示呼び出しが必要** です。

#### 起動方法
```
/backend-up
```

#### 実行内容
1. Docker Desktop の起動確認
2. `docker-compose up -d` を実行
3. `docker-compose ps` でコンテナ状態を確認
4. MySQL の `healthy` ステータスを確認
5. `http://localhost:4000/graphql` の疎通確認

#### こんな時に使う
- 朝の開発開始時
- `Connection refused` エラーが出たとき
- Docker コンテナの状態を確認したいとき

#### 注意点
- Docker Desktop が起動済みであることが前提
- ポート 3306（MySQL）・4000（GraphQL）が空いている必要あり

---

### db-reset — 開発用 DB 初期化

#### 概要
`travel_booking` データベースを完全リセットしてシードデータを再投入します。
**全データが削除**されるため、実行前に確認プロンプトが表示されます。
**`/db-reset` の明示呼び出しが必要**です。

#### 起動方法
```
/db-reset
```

#### 実行内容
1. ユーザー確認プロンプト
2. Docker 起動確認（未起動なら `backend-up` を案内）
3. `npm run db:reset`（Prisma migrate reset --force）
4. `npm run db:seed`（シードデータ投入）
5. 投入データ件数を報告

#### こんな時に使う
- テストデータが壊れてクリーンにしたいとき
- スキーマ変更後にデータを作り直したいとき

> **警告**: 開発環境専用です。本番では `npm run db:migrate:prod` を使用してください。

---

### fix-endpoint — GraphQL エンドポイント設定

#### 概要
`graphql_config.dart` の `_baseUrl` を確認・変更します。PC の IP アドレスが変わった時や
実機テストに切り替えるときに使います。設定ファイルを変更するため **`/fix-endpoint` の明示呼び出しが必要** です。

#### 起動方法
```
/fix-endpoint                    # 現在の設定確認と選択肢の提示
/fix-endpoint 192.168.1.50      # 直接変更
/fix-endpoint localhost          # localhost に変更
```

#### 実行内容（引数あり）
1. 現在の `_baseUrl` を表示
2. 指定アドレスに変更（ポート `4000/graphql` は維持）
3. 変更後の URL を確認

#### 実行内容（引数なし）
1. 現在の設定を表示
2. 環境別の推奨設定を提示

| 環境 | 推奨値 |
|---|---|
| iOS シミュレーター | `http://localhost:4000/graphql` |
| Android エミュレーター | `http://10.0.2.2:4000/graphql` |
| 実機（LAN） | `http://<ホストPCのIP>:4000/graphql` |

3. `--dart-define` を使った環境変数化への移行も提案
（詳細: `.claude/skills/fix-endpoint/references/platform-guide.md`）

#### こんな時に使う
- Wi-Fi 環境が変わって PC の IP が変わったとき
- シミュレーター ↔ 実機を切り替えるとき
- `SocketException: Connection refused` が出たとき

---

### graphql-check — GraphQL 整合性チェック

#### 概要
バックエンドの `typeDefs.ts` とモバイルのクエリ文字列を比較し、
フィールド不足・型不一致・未使用フィールドを検出します。
独立実行（`context: fork`）で本会話のコンテキストを汚しません。

#### 起動方法
```
/graphql-check
```
または以下の自然文で自動起動：
- 「GraphQL の整合性を確認して」
- 「スキーマが合っているか確認して」
- 「フィールドが見つからないエラーが出る」

#### チェック内容
- モバイルが要求するフィールドがバックエンドスキーマに存在するか
- Query/Mutation 名が typeDefs と一致しているか
- 変数の型（`$id: ID!` 等）が一致しているか
- バックエンドに定義済みだがモバイルで未取得のフィールド

（チェック対象ファイル詳細: `.claude/skills/graphql-check/references/check-targets.md`）

#### こんな時に使う
- スキーマ変更（`schema-update`）の後
- GraphQL エラーが出てどこが原因か分からないとき
- スキーマレビュー前の自己チェックとして

---

### add-feature — MVVM 機能スキャフォールド

#### 概要
指定した機能名で MVVM + Repository パターンの雛形ファイル 6 つを一括生成します。
生成後に `build_runner` まで自動実行します。

#### 起動方法
```
/add-feature hotel_search
/add-feature review_submission
/add-feature user_profile
```

#### 生成ファイル（例: `hotel_search`）

```
lib/data/
├── models/hotel_search_model.dart
├── datasources/remote/hotel_search_remote_datasource.dart
└── repositories/
    ├── hotel_search_repository.dart          # インターフェース
    └── hotel_search_repository_impl.dart    # 実装
lib/presentation/
├── viewmodels/hotel_search_viewmodel.dart
└── screens/hotel_search/hotel_search_screen.dart
```

（MVVM パターン詳細・テンプレートコード: `.claude/skills/add-feature/references/mvvm-pattern.md`）

#### こんな時に使う
- 全く新しい画面・機能を追加するとき
- アーキテクチャパターンを統一したいとき

---

### schema-update — 全レイヤースキーマ変更

#### 概要
`schema.prisma` の変更を DB から Dart まで全 8 ステップにわたって反映します。
1 フィールドの追加でも 7 ファイル以上が対象になるため、ガイドに従って漏れなく変更します。

#### 起動方法
```
/schema-update TravelPlanにratingCountフィールドを追加
/schema-update BookingにpaidAt(nullable DateTime)を追加
```
または「フィールドを追加したい」「スキーマを変更したい」などの自然文で自動起動。

#### 実行ステップ

| ステップ | 対象 | 内容 |
|---|---|---|
| Step 1 | `prisma/schema.prisma` | フィールド追加 |
| Step 2 | `src/graphql/typeDefs.ts` | GraphQL スキーマ更新 |
| Step 3 | `src/graphql/resolvers/` | Resolver 更新 |
| Step 4 | `lib/data/models/xxx.dart` | Dart モデル更新 |
| Step 5 | `remote_datasource.dart` | クエリ文字列更新 |
| Step 6 | `npm run db:migrate` | DB マイグレーション |
| Step 7 | `melos run build_runner` | コード再生成 |
| Step 8 | 解析・テスト | 動作確認 |

（レイヤー別変更ルール・コード例: `.claude/skills/schema-update/references/layer-guide.md`）

---

### bug-trace — バグ原因特定と修正

#### 概要
エラーメッセージやスタックトレースを受け取り、このプロジェクト固有の 5 系統のエラーパターンと照合して原因を特定・修正します。

#### 起動方法
```
/bug-trace The getter 'planListViewModelProvider' isn't defined
/bug-trace Exception: GraphQL request failed: 400
/bug-trace Null check operator used on a null value
```
または「エラーが出た」「バグを直して」「クラッシュする」などの自然文で自動起動。

#### 対応エラー種別

| 種別 | 代表的なエラー |
|---|---|
| Riverpod / コード生成 | `getter 'xxxProvider' isn't defined`・`ProviderNotFoundException` |
| GraphQL 通信 | `GraphQL request failed: 4xx/5xx`・`Connection refused` |
| JSON パース | `Null check operator`・`type 'Null' is not a subtype of type` |
| Navigation | `GoException: No routes for location` |
| State 管理 | 無限ローディング・状態が更新されない |

（エラーパターン辞書: `.claude/skills/bug-trace/references/error-patterns.md`）

---

### add-viewmodel-test — ViewModel テスト追加

#### 概要
指定した ViewModel のユニットテストを `Mockito + ProviderContainer` パターンで追加・拡充します。
未テストのメソッドを自動検出して成功/失敗/エッジケースを網羅します。

#### 起動方法
```
/add-viewmodel-test booking
/add-viewmodel-test favorite
/add-viewmodel-test plan_list
```
または「テストを追加して」「〜のテストを書いて」などの自然文で自動起動。

#### 既存テストファイルとの対応

| 引数 | 既存テストファイル |
|---|---|
| `plan_list` | あり → 未テストメソッドを追加 |
| `plan_detail` | あり → 未テストメソッドを追加 |
| `booking` | あり → 未テストメソッドを追加 |
| `favorite` | あり → 未テストメソッドを追加 |
| 新規機能名 | なし → テンプレートから新規作成 |

（テストコードテンプレート: `.claude/skills/add-viewmodel-test/references/test-pattern.md`）

---

### state-audit — 状態管理監査

#### 概要
指定した ViewModel を 5 つの観点で監査し、問題を重大度付きで報告します。
独立実行（`context: fork`）で本会話のコンテキストを汚しません。

#### 起動方法
```
/state-audit booking
/state-audit home
/state-audit plan_detail
```
または「状態管理を確認して」「ViewModel をレビューして」などの自然文で自動起動。

#### チェック観点

| 観点 | 主な確認内容 |
|---|---|
| 三態管理 | loading/error/success の各パスで isLoading と error が正しいか |
| 二重実行防止 | ガード句（`if (state.isLoading) return`）があるか |
| リソースリーク | `StreamSubscription`・`GraphQLHttpClient` が `onDispose` で解放されているか |
| copyWith の一貫性 | `clearError: true` フラグが一貫して使われているか |
| Provider 配置 | `ref.watch` と `ref.read` の使い分けが正しいか |

（監査チェックリスト・コード例: `.claude/skills/state-audit/references/checklist.md`）

---

## シナリオ別推奨フロー

### 開発開始時（毎朝）
```
/backend-up
```

---

### 新機能を追加するとき
```
1. /add-feature <機能名>
2. （各ファイルの TODO を実装）
3. /schema-update <変更内容>    ← DB〜Dart まで反映
4. /flutter-gen                  ← .g.dart を確認
5. /add-viewmodel-test <機能名>  ← テストを追加
6. /graphql-check                ← 整合性を確認
```

---

### バグが発生したとき
```
1. /bug-trace <エラーメッセージをそのまま貼る>
2. /add-viewmodel-test <対象ViewModel名>  ← リグレッションテストを追加
```

---

### バックエンドのスキーマを変更するとき
```
1. /schema-update <変更内容の説明>
2. /graphql-check                ← 変更後の整合性を確認
```

---

### コードレビュー前の品質チェック
```
1. /state-audit <変更した画面名>
2. /graphql-check
3. /add-viewmodel-test <変更した ViewModel 名>
```

---

### PC の IP が変わったとき（実機テスト時）
```
1. /fix-endpoint <新しいIPアドレス>
2. /backend-up
```

---

### テスト環境を初期化したいとき
```
1. /backend-up
2. /db-reset
```
