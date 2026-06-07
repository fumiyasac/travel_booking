---
name: add-mock-data
description: |
  seed.ts を参照して任意エンティティの追加テストデータを DB に投入する。
  以下のような発言で自動起動すること：
  - 「満席プランのテストデータが欲しい」
  - 「割引中のプランを何件か追加して」
  - 「特定条件のシードデータを作りたい」
  - 「テスト用データを追加したい」
argument-hint: "<エンティティ名> <件数> [--condition <条件>]"
allowed-tools:
  - Read
  - Edit
  - Bash
disable-model-invocation: false
---

# add-mock-data — 条件付きテストデータ投入

引数: `$ARGUMENTS`

`prisma/seed.ts` のパターンに従い、指定条件のテストデータを DB に追加します。
条件別のデータパターン・コードスニペット: `references/data-patterns.md` を参照。

---

## Step 1: 引数を解析する

`$ARGUMENTS` を以下のルールで解析する。

| 位置 | 変数 | 省略時のデフォルト |
|---|---|---|
| `$0` | エンティティ名 | `travelPlan` |
| `$1` | 件数 | `3` |
| `--condition <値>` | 生成条件 | 条件なし（通常プラン） |

**使用可能な条件値:**
- `soldOut` — 満席（`maxParticipants === currentBookings` かつ `isAvailable: true`）
- `discounted` — 割引中（`discountPrice` が `price` の 70% 以下）
- `unavailable` — 募集停止（`isAvailable: false`）
- `highRating` — 高評価（`rating` が 4.5 以上）

---

## Step 2: 既存スキーマを確認する

以下の 2 ファイルを Read して、フィールド構成・必須制約・既存データパターンを把握する。

```
travel_booking_backend/prisma/schema.prisma
travel_booking_backend/prisma/seed.ts
```

確認するポイント:
- 必須フィールドと省略可能フィールド（`?` の有無）
- `tags` が `String @db.Text`（JSON 文字列）で保存されていること
- `images`・`highlights` はネスト `create` で一緒に投入すること
- `currentBookings` のデフォルトは `0`

---

## Step 3: 条件別データパターンを選択する

`references/data-patterns.md` の該当セクションを参照してコードを生成する。

- 条件なし → `## 通常プラン` セクション
- `--condition soldOut` → `## soldOut（満席）` セクション
- `--condition discounted` → `## discounted（割引中）` セクション
- `--condition unavailable` → `## unavailable（募集停止）` セクション
- `--condition highRating` → `## highRating（高評価）` セクション

指定件数分、タイトル・目的地・説明文・座標などを変えてバリエーションを作ること。
日本語の現実的な値を使うこと（例: `'ローマ歴史探訪5日間'`、`'カナダ大自然8日間'`）。

---

## Step 4: TypeScript スニペットを生成して Bash で実行する

Docker が起動していることを確認してから実行する。
起動していない場合は `/backend-up` を案内して停止する。

```bash
# Docker 稼働確認
docker compose ps
```

投入コマンド（`travel_booking_backend/` ディレクトリから実行）:

```bash
cd travel_booking_backend && docker compose exec -T backend npx ts-node -e "
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
  // ← Step 3 で生成したコードをここに展開
}
main().then(() => { console.log('Done'); prisma.\$disconnect(); });
" 2>&1
```

**注意事項:**
- UUID は `prisma` の `@default(uuid())` に任せるため `id` フィールドは渡さない
- `tags` は必ず `JSON.stringify([...])` 形式の文字列で渡す
- `images` は少なくともプライマリ画像（`isPrimary: true`）を 1 枚含める
- `highlights` は 3〜5 件含める
- `prisma.$transaction` は不要（単純な create で可）

---

## Step 5: 投入結果を確認する

GraphQL で `totalCount` を取得して結果をレポートする:

```bash
curl -s -X POST http://localhost:4000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ travelPlans { totalCount } }"}' | python3 -m json.tool
```

以下の形式で日本語レポートを出力する:

```
✅ 投入完了
- エンティティ: TravelPlan
- 追加件数:     <N> 件
- 条件:         <condition または "なし">
- DB 合計:      <totalCount> 件

リセットが必要な場合は /db-reset を実行してください。
```
