# Resolver テンプレート集

実際の `planResolver.ts` / `bookingResolver.ts` から抽出したパターン。
`<EntityName>` を対象エンティティ名（PascalCase）、`<entityName>` を camelCase に置換して使う。

---

## 1. typeDefs 追記テンプレート

### 1-1. Query エントリ（type Query ブロックに追記）

```graphql
# type Query ブロックに追加
<entityName>s(filter: <EntityName>FilterInput, page: Int, pageSize: Int): <EntityName>ListResult!  # ここを <EntityName> に置換（一覧）
<entityName>(id: ID!): <EntityName>  # ここを <EntityName> に置換（単体）
```

### 1-2. 一覧 Result type（totalCount / hasNextPage パターン）

```graphql
# TravelPlansResult と同じ構造を踏襲する
type <EntityName>ListResult {  # ここを <EntityName> に置換
  items: [<EntityName>!]!
  totalCount: Int!
  hasNextPage: Boolean!
  currentPage: Int!
  totalPages: Int!
}
```

### 1-3. Mutation エントリ（type Mutation ブロックに追記）

```graphql
# type Mutation ブロックに追加
create<EntityName>(input: Create<EntityName>Input!): <EntityName>Payload!  # ここを <EntityName> に置換
```

### 1-4. Input type

```graphql
input Create<EntityName>Input {  # ここを <EntityName> に置換
  # 必須フィールド（schema.prisma の対応モデルから導出する）
  fieldA: String!
  fieldB: Int!
  # 任意フィールド
  fieldC: String
}
```

### 1-5. Payload type（BookingResult と同じ success / message / data パターン）

```graphql
type <EntityName>Payload {  # ここを <EntityName> に置換
  success: Boolean!
  message: String!
  data: <EntityName>  # ここを <EntityName> に置換
}
```

---

## 2. 一覧 Query Resolver テンプレート

`travelPlans` resolver（planResolver.ts）から抽出。`skip/take + count` + ページネーション返却。

```typescript
<entityName>s: async (
  _: unknown,
  args: { filter?: <EntityName>FilterInput; page?: number; pageSize?: number },  // ここを <EntityName> に置換
  { prisma }: Context,
) => {
  const page = Math.max(1, args.page ?? 1);
  const pageSize = Math.min(50, Math.max(1, args.pageSize ?? 20));
  const skip = (page - 1) * pageSize;

  // where 句は buildXxxWhereClause() ヘルパーに切り出す（buildPlanWhereClause 参照）
  const where = build<EntityName>WhereClause(args.filter);  // ここを <EntityName> に置換

  const [items, totalCount] = await Promise.all([
    prisma.<entityName>.findMany({  // ここを <entityName> に置換（Prisma モデル名）
      where,
      orderBy: { createdAt: 'desc' },
      skip,
      take: pageSize,
      // include: ENTITY_INCLUDE,  // リレーションが必要な場合は定数で定義
    }),
    prisma.<entityName>.count({ where }),  // ここを <entityName> に置換
  ]);

  const totalPages = Math.ceil(totalCount / pageSize);

  return {
    items: items.map(format<EntityName>),  // ここを <EntityName> に置換
    totalCount,
    hasNextPage: page < totalPages,
    currentPage: page,
    totalPages,
  };
},
```

---

## 3. 単体 Query Resolver テンプレート

`travelPlan` resolver（planResolver.ts）から抽出。`findUnique` + null チェック付き。

```typescript
<entityName>: async (
  _: unknown,
  args: { id: string },
  { prisma }: Context,
) => {
  const item = await prisma.<entityName>.findUnique({  // ここを <entityName> に置換
    where: { id: args.id },
    // include: ENTITY_INCLUDE,  // リレーションが必要な場合
  });

  if (!item) return null;  // GraphQL スキーマで nullable にしておく（<EntityName> 型）

  return format<EntityName>(item);  // ここを <EntityName> に置換
},
```

---

## 4. Mutation Resolver テンプレート

`createBooking` resolver（bookingResolver.ts）から抽出。`prisma.$transaction` + `GraphQLError` パターン。

```typescript
create<EntityName>: async (  // ここを <EntityName> に置換
  _: unknown,
  args: { input: Create<EntityName>Input },  // ここを <EntityName> に置換
  { prisma }: Context,
) => {
  const { input } = args;

  // バリデーション（bookingResolver と同じく return { success: false } パターン）
  if (!input.fieldA?.trim()) {
    return { success: false, message: 'fieldA を入力してください', data: null };
  }

  try {
    const result = await prisma.$transaction(async (tx) => {
      // 関連エンティティの存在チェック（必要な場合）
      // const parent = await tx.parentEntity.findUnique({ where: { id: input.parentId } });
      // if (!parent) {
      //   throw new GraphQLError('親エンティティが見つかりません', {
      //     extensions: { code: 'NOT_FOUND' },
      //   });
      // }

      const item = await tx.<entityName>.create({  // ここを <entityName> に置換
        data: {
          fieldA: input.fieldA.trim(),
          fieldB: input.fieldB,
          fieldC: input.fieldC?.trim() ?? null,
        },
      });

      // 関連エンティティのカウンタ更新（必要な場合、cancelBooking の decrement 参照）
      // await tx.parentEntity.update({
      //   where: { id: input.parentId },
      //   data: { someCount: { increment: 1 } },
      // });

      return item;
    });

    return {
      success: true,
      message: '登録が完了しました',
      data: format<EntityName>(result),  // ここを <EntityName> に置換
    };
  } catch (error) {
    if (error instanceof GraphQLError) {
      return { success: false, message: error.message, data: null };
    }
    console.error('<EntityName> creation error:', error);  // ここを <EntityName> に置換
    return { success: false, message: '処理中にエラーが発生しました。しばらくしてから再度お試しください', data: null };
  }
},
```

---

## 5. 新規 Resolver ファイルの全体構造テンプレート

`planResolver.ts` / `bookingResolver.ts` の構造を踏襲したファイル全体。

```typescript
// src/graphql/resolvers/<entityName>Resolver.ts  // ここを <entityName> に置換
import { GraphQLError } from 'graphql';
import { Context } from '../../index';

// Input 型定義（bookingResolver.ts の CreateBookingInput と同じ形式）
export interface Create<EntityName>Input {  // ここを <EntityName> に置換
  fieldA: string;
  fieldB: number;
  fieldC?: string;
}

// Filter 型定義（Query フィルタが必要な場合。planResolver.ts の PlanFilterInput 参照）
export interface <EntityName>FilterInput {  // ここを <EntityName> に置換
  keyword?: string;
  // 必要なフィルタフィールドを追加
}

// リレーション include 定数（planResolver.ts の PLAN_INCLUDE 参照）
// const ENTITY_INCLUDE = {
//   relatedModel: true,
// };

// 日付変換ヘルパー（bookingResolver.ts の formatBooking / planResolver.ts の formatPlan 参照）
function format<EntityName>(item: any) {  // ここを <EntityName> に置換
  return {
    ...item,
    createdAt: item.createdAt instanceof Date ? item.createdAt.toISOString() : item.createdAt,
    updatedAt: item.updatedAt instanceof Date ? item.updatedAt.toISOString() : item.updatedAt,
  };
}

// Where 句ビルダー（planResolver.ts の buildPlanWhereClause 参照）
function build<EntityName>WhereClause(filter?: <EntityName>FilterInput) {  // ここを <EntityName> に置換
  if (!filter) return {};
  const where: any = {};
  if (filter.keyword) {
    where.OR = [
      { fieldA: { contains: filter.keyword } },
    ];
  }
  return where;
}

export const <entityName>Resolvers = {  // ここを <entityName> に置換
  Query: {
    // → セクション 2・3 のテンプレートを貼り付ける
  },
  Mutation: {
    // → セクション 4 のテンプレートを貼り付ける（Mutation が不要な場合は削除）
  },
};
```

### index.ts への追記（resolvers/index.ts）

```typescript
// 追加する import（既存 import の下に追記）
import { <entityName>Resolvers } from './<entityName>Resolver';  // ここを <entityName> に置換

export const resolvers = {
  Query: {
    ...planResolvers.Query,
    ...bookingResolvers.Query,
    ...<entityName>Resolvers.Query,  // ここを <entityName> に置換（Query が必要な場合）
  },
  Mutation: {
    ...bookingResolvers.Mutation,
    ...<entityName>Resolvers.Mutation,  // ここを <entityName> に置換（Mutation が必要な場合）
  },
};
```
