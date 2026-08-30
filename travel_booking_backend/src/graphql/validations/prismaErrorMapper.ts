import { Prisma } from '@prisma/client';
import { GraphQLError } from 'graphql';

export function handlePrismaError(error: unknown): never {
  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    switch (error.code) {
      case 'P2002':
        throw new GraphQLError('既に存在するデータです', {
          extensions: { code: 'CONFLICT' },
        });
      case 'P2025':
        throw new GraphQLError('対象のデータが見つかりません', {
          extensions: { code: 'NOT_FOUND' },
        });
      default:
        throw new GraphQLError('データベースエラーが発生しました', {
          extensions: { code: 'DB_ERROR', prismaCode: error.code },
        });
    }
  }
  throw new GraphQLError('予期しないエラーが発生しました', {
    extensions: { code: 'INTERNAL_ERROR' },
  });
}
