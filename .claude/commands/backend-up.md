旅行予約バックエンド環境（MySQL + GraphQL サーバー）を Docker で起動してください。

実行手順:
1. `travel_booking_backend/` ディレクトリで `docker-compose up -d` を実行する
2. `docker-compose ps` でコンテナの起動状態を確認する
3. MySQL の health check が passed になるまで待機する
4. GraphQL エンドポイント `http://localhost:4000/graphql` が応答するか確認する
5. 起動完了後、利用可能な操作（GraphQL Playground、Prisma Studio 等）を日本語で案内する

トラブルシューティング:
- MySQL が起動しない場合はポート 3306 の競合を確認する
- バックエンドコンテナが起動しない場合は `docker-compose logs backend` を確認する
