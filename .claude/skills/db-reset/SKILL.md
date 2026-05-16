---
name: db-reset
description: |
  開発用 MySQL データベースを完全リセットしシードデータを再投入する。
  「DB をリセットして」「データを初期化して」「テストデータを入れ直して」
  「データが壊れたのでクリーンにしたい」などのリクエストで使用する。
  全データが削除される破壊的操作のため必ずユーザー確認を取ってから実行する。
  本番環境では絶対に使用しない。手動実行専用。
disable-model-invocation: true
allowed-tools:
  - Bash
metadata:
  version: "1.0.0"
---

# db-reset — 開発用 DB 初期化

> **警告**: `travel_booking` データベースの **全データが削除** されます。開発環境専用です。

## 実行手順

### 1. ユーザー確認

実行前に必ず確認を取る：

> 「`travel_booking` データベースの全データを削除してシードデータを再投入します。よろしいですか？」

### 2. Docker 起動確認

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_backend && docker-compose ps | grep mysql
```

`healthy` でない場合は `backend-up` スキルを先に実行するよう案内する。

### 3. DB リセット

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_backend && npm run db:reset
```

Prisma が確認プロンプトを出す場合は `y` で続行する。

### 4. シードデータ投入

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_backend && npm run db:seed
```

### 5. 投入結果の確認

シードデータの件数を確認する：

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_backend && \
  npx prisma studio --port 5555 &
```

または GraphQL で件数を確認する：

```bash
curl -s -X POST http://localhost:4000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ travelPlans { totalCount } }"}' | grep totalCount
```

投入された TravelPlan 数・Booking 数を日本語で報告する。

## 注意事項

- `db:reset` は開発環境（`.env` の `DATABASE_URL` が `localhost:3306`）でのみ使用する
- 本番環境のマイグレーションは `npm run db:migrate:prod` を使用する
- スキーマ変更後にリセットする場合は `schema-update` スキルで変更を適用してからリセットする
