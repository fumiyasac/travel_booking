# ミドルウェアテンプレート集

`src/index.ts` の Apollo Server v4 + `startStandaloneServer` 構成を前提に記述。
Express ミドルウェアのテンプレートは `expressMiddleware` への移行後に使用する。
`<MiddlewareName>` / `<middlewareName>` を実際の名前に置き換えること。

---

## テンプレート 1: Express ミドルウェア — ヘルスチェックエンドポイント

> **前提**: `startStandaloneServer` → `expressMiddleware` への移行が必要。
> 現在の `src/index.ts` にある `startStandaloneServer` を下記 Express 構成に書き換える。

### 1-A: `src/middleware/healthCheck.ts`（ここを `<MiddlewareName>` に置換）

```typescript
// src/middleware/healthCheck.ts  // ここを <MiddlewareName> に置換
import { Request, Response } from 'express';
import { prisma } from '../index';

export async function healthCheck(req: Request, res: Response): Promise<void> {
  // ここを <MiddlewareName> に置換
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.status(200).json({
      status: 'ok',
      timestamp: new Date().toISOString(),
      database: 'connected',
    });
  } catch {
    res.status(503).json({
      status: 'error',
      timestamp: new Date().toISOString(),
      database: 'disconnected',
    });
  }
}
```

### 1-B: `src/index.ts` の Express 移行後の全体構成

```typescript
// src/index.ts — startStandaloneServer から expressMiddleware への移行後
import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@apollo/server/express4';
import express from 'express';
import { PrismaClient } from '@prisma/client';
import dotenv from 'dotenv';
import { typeDefs } from './graphql/typeDefs';
import { resolvers } from './graphql/resolvers';
import { healthCheck } from './middleware/healthCheck';  // ここを追加

dotenv.config();

export const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
});

export interface Context {
  prisma: PrismaClient;
}

async function main() {
  const app = express();
  app.use(express.json());

  const server = new ApolloServer<Context>({
    typeDefs,
    resolvers,
    formatError: (formattedError, error) => {
      console.error('GraphQL Error:', error);
      return {
        message: formattedError.message,
        locations: formattedError.locations,
        path: formattedError.path,
        extensions: {
          code: formattedError.extensions?.code ?? 'INTERNAL_SERVER_ERROR',
        },
      };
    },
  });

  await server.start();

  // ── ミドルウェア登録 ──────────────────────────────────────────────
  app.get('/health', healthCheck);  // ここを追加

  // GraphQL エンドポイント
  app.use(
    '/graphql',
    expressMiddleware(server, {
      context: async (): Promise<Context> => ({ prisma }),
    }),
  );

  const port = parseInt(process.env.PORT ?? '4000', 10);
  app.listen(port, () => {
    console.log(`🚀 Travel Booking GraphQL Server ready at: http://localhost:${port}/graphql`);
    console.log(`🏥 Health check: http://localhost:${port}/health`);
    console.log(`📊 Environment: ${process.env.NODE_ENV ?? 'development'}`);
  });
}

main()
  .catch((err) => {
    console.error('Failed to start server:', err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
```

---

## テンプレート 2: Apollo Server プラグイン — リクエストロガー

> **前提**: 現在の `startStandaloneServer` 構成のまま追加可能（Express 移行不要）。

### 2-A: `src/middleware/requestLogger.ts`（ここを `<MiddlewareName>` に置換）

```typescript
// src/middleware/requestLogger.ts  // ここを <MiddlewareName> に置換
import { ApolloServerPlugin, GraphQLRequestListener } from '@apollo/server';
import { Context } from '../index';

export const requestLoggerPlugin: ApolloServerPlugin<Context> = {  // ここを <MiddlewareName> に置換
  async requestDidStart({ request }) {
    const operationName = request.operationName ?? 'anonymous';
    const startTime = Date.now();

    console.log(`[GraphQL] → ${operationName}`);

    return {
      async willSendResponse({ response }) {
        const duration = Date.now() - startTime;
        const hasErrors = (response.body.kind === 'single' && response.body.singleResult.errors);

        if (hasErrors) {
          console.error(`[GraphQL] ✗ ${operationName} (${duration}ms) — errors detected`);
        } else {
          console.log(`[GraphQL] ✓ ${operationName} (${duration}ms)`);
        }
      },

      async didEncounterErrors({ errors }) {
        errors.forEach((error) => {
          console.error(`[GraphQL] Error in ${operationName}:`, {
            message: error.message,
            path: error.path,
            extensions: error.extensions,
          });
        });
      },
    } satisfies GraphQLRequestListener<Context>;
  },
};
```

### 2-B: `src/index.ts` への登録（`plugins` 配列に追加）

```typescript
// 追加する import
import { requestLoggerPlugin } from './middleware/requestLogger';  // ここを <MiddlewareName> に置換

// ApolloServer コンストラクタを修正
const server = new ApolloServer<Context>({
  typeDefs,
  resolvers,
  plugins: [
    requestLoggerPlugin,  // ここを <MiddlewareName> に置換
  ],
  formatError: /* 既存のまま */,
});
```

---

## テンプレート 3: Express ミドルウェア — レート制限

> **前提**: `expressMiddleware` への移行後に使用。`express-rate-limit` のインストールが必要。
> ```bash
> npm install express-rate-limit @types/express-rate-limit
> ```

### 3-A: `src/middleware/rateLimit.ts`（ここを `<MiddlewareName>` に置換）

```typescript
// src/middleware/rateLimit.ts  // ここを <MiddlewareName> に置換
import rateLimit from 'express-rate-limit';

export const graphqlRateLimiter = rateLimit({  // ここを <MiddlewareName> に置換
  windowMs: 15 * 60 * 1000,  // 15分ウィンドウ
  max: 100,                   // ウィンドウあたり最大リクエスト数
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    errors: [
      {
        message: 'リクエスト数が上限に達しました。しばらく時間をおいてから再試行してください。',
        extensions: { code: 'RATE_LIMITED' },
      },
    ],
  },
  skip: () => process.env.NODE_ENV === 'test',  // テスト環境ではスキップ
});
```

### 3-B: `src/index.ts` への登録（GraphQL エンドポイントに適用）

```typescript
// 追加する import
import { graphqlRateLimiter } from './middleware/rateLimit';  // ここを <MiddlewareName> に置換

// GraphQL エンドポイント定義に追加（expressMiddleware 構成の場合）
app.use(
  '/graphql',
  graphqlRateLimiter,       // ← レート制限を追加
  expressMiddleware(server, {
    context: async (): Promise<Context> => ({ prisma }),
  }),
);
```

---

## テンプレート 4: Apollo Server プラグイン — 構造化ログ（pino）

> **前提**: 現在の `startStandaloneServer` 構成のまま追加可能。`pino` のインストールが必要。
> ```bash
> npm install pino @types/pino
> ```

### 4-A: `src/middleware/structuredLogger.ts`（ここを `<MiddlewareName>` に置換）

```typescript
// src/middleware/structuredLogger.ts  // ここを <MiddlewareName> に置換
import pino from 'pino';
import { ApolloServerPlugin, GraphQLRequestListener } from '@apollo/server';
import { Context } from '../index';

const logger = pino({
  level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
  transport:
    process.env.NODE_ENV !== 'production'
      ? { target: 'pino-pretty', options: { colorize: true } }
      : undefined,
});

export const structuredLoggerPlugin: ApolloServerPlugin<Context> = {  // ここを <MiddlewareName> に置換
  async requestDidStart({ request }) {
    const operationName = request.operationName ?? 'anonymous';
    const startTime = Date.now();

    logger.debug({ operationName }, 'GraphQL request started');

    return {
      async willSendResponse({ response }) {
        const duration = Date.now() - startTime;
        const hasErrors = (response.body.kind === 'single' && response.body.singleResult.errors);

        logger.info(
          {
            operationName,
            durationMs: duration,
            hasErrors,
          },
          'GraphQL request completed',
        );
      },

      async didEncounterErrors({ errors }) {
        errors.forEach((error) => {
          logger.error(
            {
              operationName,
              errorMessage: error.message,
              errorPath: error.path,
              errorCode: error.extensions?.code,
            },
            'GraphQL error encountered',
          );
        });
      },
    } satisfies GraphQLRequestListener<Context>;
  },
};
```

### 4-B: `src/index.ts` への登録（`plugins` 配列に追加）

```typescript
// 追加する import
import { structuredLoggerPlugin } from './middleware/structuredLogger';  // ここを <MiddlewareName> に置換

const server = new ApolloServer<Context>({
  typeDefs,
  resolvers,
  plugins: [
    structuredLoggerPlugin,  // ここを <MiddlewareName> に置換
  ],
  formatError: /* 既存のまま */,
});
```

---

## 種別判定クイックリファレンス

| ミドルウェア名パターン | 種別 | テンプレート | Express 移行 |
|---|---|---|:---:|
| `healthCheck` | Express エンドポイント | テンプレート 1 | 必要 |
| `cors`, `static` | Express ミドルウェア | テンプレート 1-B の `app.use()` | 必要 |
| `rateLimit` | Express ミドルウェア | テンプレート 3 | 必要 |
| `requestLogger` | Apollo プラグイン | テンプレート 2 | 不要 |
| `structuredLogger` | Apollo プラグイン | テンプレート 4 | 不要 |
| `auth`, `cache` | Apollo プラグイン | テンプレート 2 を改変 | 不要 |

## Express 移行時の必要パッケージ

```bash
# Express 本体（移行時に必須）
npm install express @apollo/server
# @types は devDependencies へ
npm install --save-dev @types/express

# rate-limit（rateLimit ミドルウェアの場合）
npm install express-rate-limit
npm install --save-dev @types/express-rate-limit
```
