import { GraphQLError } from 'graphql';
import { Context } from '../../index';
import { validate } from '../validations/validate';
import { loginSchema, registerSchema, LoginInput, RegisterInput } from '../validations/authSchemas';
import { generateToken, hashPassword, comparePassword } from '../../utils/auth';

function formatUser(user: { id: string; email: string; name: string; createdAt: Date }) {
  return {
    ...user,
    createdAt: user.createdAt.toISOString(),
  };
}

export const authResolvers = {
  Mutation: {
    login: async (
      _: unknown,
      args: { input: LoginInput },
      { prisma }: Context,
    ) => {
      const { email, password } = validate(loginSchema, args.input);

      const user = await prisma.user.findUnique({ where: { email } });
      if (!user) {
        throw new GraphQLError('メールアドレスまたはパスワードが正しくありません', {
          extensions: { code: 'UNAUTHORIZED' },
        });
      }

      const isValid = await comparePassword(password, user.password);
      if (!isValid) {
        throw new GraphQLError('メールアドレスまたはパスワードが正しくありません', {
          extensions: { code: 'UNAUTHORIZED' },
        });
      }

      return {
        token: generateToken(user),
        user: formatUser(user),
      };
    },

    register: async (
      _: unknown,
      args: { input: RegisterInput },
      { prisma }: Context,
    ) => {
      const { email, password, name } = validate(registerSchema, args.input);

      const existing = await prisma.user.findUnique({ where: { email } });
      if (existing) {
        throw new GraphQLError('このメールアドレスはすでに登録されています', {
          extensions: { code: 'CONFLICT' },
        });
      }

      const hashedPassword = await hashPassword(password);
      const user = await prisma.user.create({
        data: { email, password: hashedPassword, name },
      });

      return {
        token: generateToken(user),
        user: formatUser(user),
      };
    },
  },
};
