import { GraphQLError } from 'graphql';
import { authResolvers } from '../../graphql/resolvers/authResolver';
import { prismaMock, resetPrismaMocks } from '../helpers/prismaMock';

// bcryptjs / jsonwebtoken をモックして外部依存を排除
jest.mock('bcryptjs', () => ({
  compare: jest.fn(),
  hash: jest.fn().mockResolvedValue('hashed-password'),
}));
jest.mock('jsonwebtoken', () => ({
  sign: jest.fn().mockReturnValue('mocked-jwt-token'),
  verify: jest.fn(),
}));

import bcrypt from 'bcryptjs';

// JWT_SECRET が必要なため設定（verifyToken は呼ばれないが getJwtSecret() が呼ばれうる）
process.env.JWT_SECRET = 'test-secret-for-jest';

// ── テスト共通ダミーデータ ───────────────────────────────────────
const now = new Date('2025-06-01T00:00:00Z');

const mockUser = {
  id: 'user-1',
  email: 'test@example.com',
  password: 'hashed-password',
  name: 'テストユーザー',
  createdAt: now,
  updatedAt: now,
};

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const ctx = { prisma: prismaMock as any, currentUser: null };

// ── テスト ────────────────────────────────────────────────────────
describe('authResolvers', () => {
  beforeEach(() => {
    resetPrismaMocks();
    jest.clearAllMocks();
    // hash のデフォルトモックを毎回リセット後に再設定
    (bcrypt.hash as jest.Mock).mockResolvedValue('hashed-password');
  });

  // ────────────────────────────────────────────────────────────────
  describe('Mutation.register', () => {
    it('正常系: 登録成功で token と user が返ること', async () => {
      prismaMock.user.findUnique.mockResolvedValue(null);
      prismaMock.user.create.mockResolvedValue(mockUser);

      const result = await authResolvers.Mutation.register(
        undefined,
        { input: { email: 'test@example.com', password: 'password123', name: 'テストユーザー' } },
        ctx,
      );

      expect(result.token).toBe('mocked-jwt-token');
      expect(result.user.email).toBe('test@example.com');
      expect(result.user.name).toBe('テストユーザー');
      expect(prismaMock.user.create).toHaveBeenCalledTimes(1);
    });

    it('重複メールアドレス: CONFLICT エラーがスローされること', async () => {
      prismaMock.user.findUnique.mockResolvedValue(mockUser);

      await expect(
        authResolvers.Mutation.register(
          undefined,
          { input: { email: 'test@example.com', password: 'password123', name: 'テストユーザー' } },
          ctx,
        ),
      ).rejects.toThrow(GraphQLError);

      await expect(
        authResolvers.Mutation.register(
          undefined,
          { input: { email: 'test@example.com', password: 'password123', name: 'テストユーザー' } },
          ctx,
        ),
      ).rejects.toMatchObject({ extensions: { code: 'CONFLICT' } });
    });

    it('空の name: VALIDATION_ERROR がスローされること', async () => {
      await expect(
        authResolvers.Mutation.register(
          undefined,
          { input: { email: 'test@example.com', password: 'password123', name: '' } },
          ctx,
        ),
      ).rejects.toThrow(GraphQLError);

      await expect(
        authResolvers.Mutation.register(
          undefined,
          { input: { email: 'test@example.com', password: 'password123', name: '' } },
          ctx,
        ),
      ).rejects.toMatchObject({ extensions: { code: 'VALIDATION_ERROR' } });

      // バリデーションエラーでは DB アクセスしない
      expect(prismaMock.user.findUnique).not.toHaveBeenCalled();
    });

    it('短すぎる password: VALIDATION_ERROR がスローされること', async () => {
      await expect(
        authResolvers.Mutation.register(
          undefined,
          { input: { email: 'test@example.com', password: '123', name: 'テスト' } },
          ctx,
        ),
      ).rejects.toMatchObject({ extensions: { code: 'VALIDATION_ERROR' } });
    });
  });

  // ────────────────────────────────────────────────────────────────
  describe('Mutation.login', () => {
    it('正常系: 正しい認証情報で token と user が返ること', async () => {
      prismaMock.user.findUnique.mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);

      const result = await authResolvers.Mutation.login(
        undefined,
        { input: { email: 'test@example.com', password: 'password123' } },
        ctx,
      );

      expect(result.token).toBe('mocked-jwt-token');
      expect(result.user.email).toBe('test@example.com');
      expect(result.user.id).toBe('user-1');
    });

    it('不正なパスワード: UNAUTHORIZED エラーがスローされること', async () => {
      prismaMock.user.findUnique.mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);

      await expect(
        authResolvers.Mutation.login(
          undefined,
          { input: { email: 'test@example.com', password: 'wrong-password' } },
          ctx,
        ),
      ).rejects.toThrow(GraphQLError);

      await expect(
        authResolvers.Mutation.login(
          undefined,
          { input: { email: 'test@example.com', password: 'wrong-password' } },
          ctx,
        ),
      ).rejects.toMatchObject({ extensions: { code: 'UNAUTHORIZED' } });
    });

    it('存在しないメールアドレス: UNAUTHORIZED エラーがスローされること', async () => {
      prismaMock.user.findUnique.mockResolvedValue(null);

      await expect(
        authResolvers.Mutation.login(
          undefined,
          { input: { email: 'nobody@example.com', password: 'password123' } },
          ctx,
        ),
      ).rejects.toMatchObject({ extensions: { code: 'UNAUTHORIZED' } });
    });

    it('不正なメールアドレス形式: VALIDATION_ERROR がスローされること', async () => {
      await expect(
        authResolvers.Mutation.login(
          undefined,
          { input: { email: 'not-an-email', password: 'password123' } },
          ctx,
        ),
      ).rejects.toMatchObject({ extensions: { code: 'VALIDATION_ERROR' } });

      expect(prismaMock.user.findUnique).not.toHaveBeenCalled();
    });
  });
});
