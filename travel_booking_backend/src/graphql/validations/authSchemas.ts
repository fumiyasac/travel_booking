import { z } from 'zod';

export const loginSchema = z.object({
  email: z.string().email({ message: 'email: Invalid email address' }),
  password: z.string().min(6, { message: 'password: must be at least 6 characters' }),
});

export const registerSchema = z.object({
  email: z.string().email({ message: 'email: Invalid email address' }),
  password: z.string().min(6, { message: 'password: must be at least 6 characters' }),
  name: z
    .string()
    .min(1, { message: 'name: must be at least 1 character' })
    .max(100, { message: 'name: must be at most 100 characters' }),
});

export type LoginInput = z.infer<typeof loginSchema>;
export type RegisterInput = z.infer<typeof registerSchema>;
