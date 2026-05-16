開発用データベースをリセットしてシードデータを再投入してください。

⚠️ 警告: この操作は `travel_booking` データベースの全データを削除します。開発環境専用です。

実行手順:
1. ユーザーに確認を求める（「本当にDBをリセットしますか？全データが削除されます」）
2. `travel_booking_backend/` ディレクトリで以下を順番に実行する:
   - `npm run db:reset` （Prisma migrate reset --force）
   - `npm run db:seed` （シードデータ投入）
3. 投入されたシードデータの件数（TravelPlan 数、Booking 数等）を確認して報告する
4. バックエンドサービスが起動中でない場合は `docker-compose up -d` を先に実行するよう案内する

注意事項:
- `db:reset` は本番環境（`db:migrate:prod`）では使用しない
- `.env` の `DATABASE_URL` が開発用 MySQL を指しているか確認してから実行する
