import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@apollo/server/express4';
import express from 'express';
import { PrismaClient } from '@prisma/client';
import dotenv from 'dotenv';
import { typeDefs } from './graphql/typeDefs';
import { resolvers } from './graphql/resolvers';
import { healthCheck } from './middleware/healthCheck';
import { graphqlRateLimiter } from './middleware/rateLimit';
import { requestLoggerPlugin } from './middleware/requestLogger';

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
    plugins: [requestLoggerPlugin],
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

  app.get('/health', healthCheck);

  app.use(
    '/graphql',
    graphqlRateLimiter,
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
