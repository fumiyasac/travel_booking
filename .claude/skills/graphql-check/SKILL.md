---
name: graphql-check
description: |
  バックエンドの GraphQL スキーマ（typeDefs.ts）とモバイルアプリの
  クエリ文字列（TravelPlanRemoteDataSource）の整合性をチェックする。
  フィールド不足・型不一致・未使用フィールドを検出して優先度付きで報告する。
  「GraphQL の整合性を確認して」「スキーマが合っているか確認して」
  「フィールドが見つからないエラーが出る」「スキーマ変更後に確認したい」
  などの状況で使用する。本会話コンテキストを汚さず独立実行する。
context: fork
allowed-tools:
  - Read
  - Bash
metadata:
  version: "1.0.0"
---

# graphql-check — GraphQL 整合性チェック

バックエンドスキーマとモバイルクエリの整合性を確認します。
チェック対象ファイルの詳細: `references/check-targets.md` を参照。

## 実行手順

### 1. バックエンドスキーマの読み込み

```
Read: travel_booking_backend/src/graphql/typeDefs.ts
```

以下を抽出する：
- `type Query` に定義されているクエリ名と引数の型
- `type Mutation` に定義されているミューテーション名と引数の型
- 各 Type のフィールド名と型（nullable/non-null）
- `input` 型のフィールド定義

### 2. モバイル側クエリの読み込み

```
Read: travel_booking_mobile/lib/data/datasources/remote/travel_plan_remote_datasource.dart
Read: travel_booking_mobile/assets/graphql/queries.graphql
Read: travel_booking_mobile/assets/graphql/mutations.graphql
```

各クエリ・ミューテーション文字列から要求しているフィールドと変数を抽出する。

### 3. 整合性チェック

以下の項目を照合する：

**【必須チェック】**
- モバイルが要求しているフィールドがバックエンドスキーマに存在するか
- Query/Mutation 名がバックエンドの typeDefs に存在するか
- 変数の型が一致しているか（例: `$id: ID!` vs `id: ID!`）
- Non-null フィールド（`!` あり）を nullable として扱っていないか

**【任意チェック】**
- バックエンドに定義済みだがモバイルで未取得のフィールドがあるか（未使用フィールド）
- Resolver で返却できないフィールドをクエリで要求していないか

### 4. 結果報告

問題を優先度別に報告する：

```
【高】GetTravelPlan クエリで `updatedAt` を要求しているが typeDefs.ts に未定義
  ファイル: travel_plan_remote_datasource.dart
  修正: typeDefs.ts の TravelPlan type に `updatedAt: String!` を追加する

【低】TravelPlan.meetingPoint はスキーマに定義されているがモバイル側で未取得
  ファイル: typeDefs.ts
  対応: 不要なら削除を検討（任意）

整合性チェック完了 — 問題: 1件（高: 1, 中: 0, 低: 1）
```

問題なければ「整合性 OK — 全フィールドが一致しています」と報告する。
