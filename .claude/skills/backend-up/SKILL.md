---
name: backend-up
description: |
  Docker Compose で MySQL + Apollo GraphQL サーバーをバックグラウンド起動する。
  「バックエンドを起動して」「Docker を立ち上げて」「開発環境を準備して」
  「GraphQL サーバーを起動して」「Connection refused が出ている」などの
  リクエストで使用する。副作用（Docker コンテナ起動）があるため手動実行専用。
disable-model-invocation: true
allowed-tools:
  - Bash
metadata:
  version: "1.0.0"
---

# backend-up — バックエンド環境起動

`travel_booking_backend/` の Docker Compose を起動し、MySQL と Apollo GraphQL サーバーを立ち上げます。

## 実行手順

### 1. Docker Desktop の起動確認

```bash
docker info 2>&1 | head -3
```

エラーが出る場合は Docker Desktop が起動していないため、先に起動するよう案内する。

### 2. コンテナ起動

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_backend && docker-compose up -d
```

### 3. 起動状態の確認

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_backend && docker-compose ps
```

| サービス | ポート | 正常状態 |
|---|---|---|
| mysql | 3306 | healthy |
| backend | 4000 | Up |

### 4. MySQL ヘルスチェック待機

MySQL の `health: healthy` が表示されるまで確認する（初回起動時は30秒程度かかる場合がある）。

```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_backend && docker-compose ps | grep mysql
```

### 5. GraphQL エンドポイント確認

```bash
curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:4000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __typename }"}'
```

`200` が返れば起動完了。

### 6. 完了報告

起動完了後、利用可能な操作を案内する：
- **GraphQL**: `http://localhost:4000/graphql`
- **Prisma Studio**: `npm run db:studio` で起動

## トラブルシューティング

**MySQL が起動しない（ポート競合）**:
```bash
lsof -i :3306
```
別の MySQL プロセスが動いている場合は停止が必要。

**バックエンドコンテナが起動しない**:
```bash
cd /Users/sakaifumiya/Desktop/FlutterApp/travel_booking/travel_booking_backend && docker-compose logs backend --tail=30
```
ログを確認して原因を日本語で説明する。
