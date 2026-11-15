import { z } from 'zod';

export const loginSchema = z.object({
  email: z.string().email({ message: 'メールアドレスの形式が正しくありません' }),
  password: z.string().min(6, { message: 'パスワードは6文字以上で入力してください' }),
});

export const registerSchema = z.object({
  email: z.string().email({ message: 'メールアドレスの形式が正しくありません' }),
  password: z.string().min(6, { message: 'パスワードは6文字以上で入力してください' }),
  name: z
    .string()
    .min(1, { message: 'お名前を入力してください' })
    .max(100, { message: 'お名前は100文字以内で入力してください' }),
});

export type LoginInput = z.infer<typeof loginSchema>;
export type RegisterInput = z.infer<typeof registerSchema>;
