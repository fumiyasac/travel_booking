# スキーマ変更 レイヤー別詳細ガイド

## Step 1: Prisma スキーマ変更ルール {#step1}

### フィールド追加の型別パターン

```prisma
model TravelPlan {
  // nullable フィールド（既存レコードに値がない場合）
  newField  String?

  // non-null + デフォルト値（既存レコードにデフォルト値を設定）
  rating    Float   @default(0.0)
  count     Int     @default(0)
  flag      Boolean @default(false)

  // non-null（新規テーブルまたは同一マイグレーション内で値を埋める場合）
  requiredField String
}
```

### リレーション追加

```prisma
model TravelPlan {
  tags    Tag[]         // 1対多
  country Country @relation(fields: [countryId], references: [id])
  countryId String
}
```

---

## Step 2: GraphQL typeDefs 変更ルール

### Prisma → GraphQL 型マッピング

| Prisma 型 | GraphQL 型（non-null） | GraphQL 型（nullable） |
|---|---|---|
| `String` | `String!` | `String` |
| `Int` | `Int!` | `Int` |
| `Float` | `Float!` | `Float` |
| `Boolean` | `Boolean!` | `Boolean` |
| `DateTime` | `String!` | `String` |
| `String[]` | `[String!]!` | `[String!]` |

### Input 型の追加パターン

```typescript
input UpdateTravelPlanInput {
  title: String
  description: String
  # nullable フィールドのみで更新対象を表現
}
```

---

## Step 3: Resolver 変更ルール

### 計算フィールドの追加

```typescript
const planResolvers = {
  TravelPlan: {
    // DB に存在しない計算フィールド
    availableSpots: (plan: any) => plan.maxParticipants - plan.currentBookings,
    effectivePrice: (plan: any) => plan.discountPrice ?? plan.price,
  },
};
```

### リレーションの include 追加

```typescript
const plan = await prisma.travelPlan.findUnique({
  where: { id },
  include: {
    images: { orderBy: { displayOrder: 'asc' } },
    reviews: true,
    // 新しいリレーション
    newRelation: true,
  },
});
```

---

## Step 4: Dart モデル変更ルール {#step4}

### nullable フィールドの追加

```dart
class TravelPlan {
  // 1. フィールド宣言
  final String? newField;

  // 2. コンストラクタ引数
  const TravelPlan({
    // ...既存...
    this.newField,  // nullable は this.xxx, のみ
  });

  // 3. fromJson
  factory TravelPlan.fromJson(Map<String, dynamic> json) {
    return TravelPlan(
      // ...既存...
      newField: json['newField'] as String?,  // nullable は as Type?
    );
  }

  // 4. toJson
  Map<String, dynamic> toJson() => {
    // ...既存...
    'newField': newField,
  };

  // 5. copyWith
  TravelPlan copyWith({
    // ...既存...
    String? newField,
  }) {
    return TravelPlan(
      // ...既存...
      newField: newField ?? this.newField,
    );
  }
}
```

### non-null フィールドの追加

```dart
// 1. フィールド宣言
final int newCount;

// 2. コンストラクタ引数
const TravelPlan({required this.newCount});

// 3. fromJson（既存データに値がない場合はデフォルト値を指定）
newCount: json['newCount'] as int? ?? 0,

// 4. toJson
'newCount': newCount,

// 5. copyWith
int? newCount,
// ...
newCount: newCount ?? this.newCount,
```

---

## よくある移行ミス

| ミス | 症状 | 修正 |
|---|---|---|
| Step 4 の `copyWith` 追加忘れ | コンパイルエラー | `copyWith` にパラメータと値を追加 |
| `fromJson` で `as Type`（nullable 漏れ） | `Null check operator` エラー | `as Type?` に修正 |
| Step 7 の `build_runner` 忘れ | Provider が古い状態 | `melos run build_runner` を実行 |
| Step 6 でマイグレーション前にアプリ起動 | DB スキーマ不一致エラー | マイグレーション後に起動 |
