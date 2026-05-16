import { ApolloServer } from '@apollo/server';
import { startStandaloneServer } from '@apollo/server/standalone';
import { PrismaClient } from '@prisma/client';
import dotenv from 'dotenv';
import { typeDefs } from './graphql/typeDefs';
import { resolvers } from './graphql/resolvers';

dotenv.config();

export const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
});

export interface Context {
  prisma: PrismaClient;
}

async function main() {
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

  const port = parseInt(process.env.PORT ?? '4000', 10);

  const { url } = await startStandaloneServer(server, {
    listen: { port },
    context: async (): Promise<Context> => ({
      prisma,
    }),
  });

  console.log(`🚀 Travel Booking GraphQL Server ready at: ${url}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV ?? 'development'}`);
}

main()
  .catch((err) => {
    console.error('Failed to start server:', err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
