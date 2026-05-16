# GraphQL 整合性チェック 対象ファイル一覧

## バックエンド側（チェック元）

| ファイル | 確認内容 |
|---|---|
| `travel_booking_backend/src/graphql/typeDefs.ts` | Type・Query・Mutation・Input の完全定義 |
| `travel_booking_backend/src/graphql/resolvers/planResolver.ts` | TravelPlan クエリの実装・返却フィールド |
| `travel_booking_backend/src/graphql/resolvers/bookingResolver.ts` | Booking ミューテーションの実装 |

## モバイル側（チェック対象）

| ファイル | 確認内容 |
|---|---|
| `travel_booking_mobile/lib/data/datasources/remote/travel_plan_remote_datasource.dart` | `_getPlansQuery`・`_getPlanQuery`・`_createBookingMutation`・`_cancelBookingMutation` |
| `travel_booking_mobile/assets/graphql/queries.graphql` | 外部定義クエリ |
| `travel_booking_mobile/assets/graphql/mutations.graphql` | 外部定義ミューテーション |

## 現在の主要クエリ

### GetTravelPlans
- Query 名: `travelPlans(filter: PlanFilterInput, page: Int, pageSize: Int)`
- 返却型: `TravelPlansResult`（`plans`・`totalCount`・`hasNextPage`・`currentPage`・`totalPages`）

### GetTravelPlan
- Query 名: `travelPlan(id: ID!)`
- 返却型: `TravelPlan`（フルフィールド）

### CreateBooking
- Mutation 名: `createBooking(input: CreateBookingInput!)`
- 返却型: `BookingResult`（`success`・`message`・`booking`）

### CancelBooking
- Mutation 名: `cancelBooking(id: ID!)`
- 返却型: `BookingResult`

## よくある不整合パターン

| パターン | 原因 | 修正 |
|---|---|---|
| フィールドが見つからない | typeDefs にフィールド未追加 | typeDefs.ts を更新 |
| null が返ってくる | Resolver でフィールドを返していない | planResolver.ts を更新 |
| 型エラー | `Int!` vs `Int` のミスマッチ | どちらかに統一 |
| ミューテーション名が違う | typo またはリネーム後の未修正 | 名前を揃える |
