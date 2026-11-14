import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { GraphQLError } from 'graphql';
import type { Context } from '../index';

export interface TokenPayload {
  userId: string;
  email: string;
}

// TODO: 本番環境では十分な長さ（32文字以上）のランダム文字列を設定すること
function getJwtSecret(): string {
  const secret = process.env.JWT_SECRET;
  if (!secret) throw new Error('JWT_SECRET is not defined');
  return secret;
}

export function generateToken(user: { id: string; email: string }): string {
  return jwt.sign(
    { userId: user.id, email: user.email } satisfies TokenPayload,
    getJwtSecret(),
    { expiresIn: '7d' },
  );
}

export function verifyToken(token: string): TokenPayload {
  return jwt.verify(token, getJwtSecret()) as TokenPayload;
}

export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, 10);
}

export async function comparePassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}

export function requireAuth(
  context: Context,
): { id: string; email: string; name: string } {
  if (!context.currentUser) {
    throw new GraphQLError('認証が必要です', {
      extensions: { code: 'UNAUTHENTICATED' },
    });
  }
  return context.currentUser;
}
