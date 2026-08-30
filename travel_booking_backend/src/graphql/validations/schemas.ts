import { z } from 'zod';

// ─── PlanFilterInput に対応 ───────────────────────────────────────────────────
// typeDefs: input PlanFilterInput { keyword, category, region, difficulty,
//           sortBy, sortOrder, minPrice, maxPrice, maxDuration }
// planResolver の buildPlanWhereClause / buildOrderByClause の制約を反映する
export const planFilterSchema = z
  .object({
    keyword: z.string().optional(),
    category: z.enum(['city', 'cultural', 'nature', 'adventure', 'leisure']).optional(),
    region: z.string().optional(),
    difficulty: z.enum(['easy', 'moderate', 'hard']).optional(),
    minPrice: z.number().min(0, { message: 'minPrice must be >= 0' }).optional(),
    maxPrice: z.number().min(0, { message: 'maxPrice must be >= 0' }).optional(),
    maxDuration: z.number().int().min(1, { message: 'maxDuration must be >= 1' }).optional(),
    sortBy: z.enum(['rating', 'price', 'duration', 'createdAt']).optional(),
    sortOrder: z.enum(['asc', 'desc']).optional(),
  })
  .refine(
    (data) =>
      data.minPrice === undefined ||
      data.maxPrice === undefined ||
      data.minPrice <= data.maxPrice,
    { message: 'minPrice must be <= maxPrice', path: ['minPrice'] },
  );

// ─── CreateBookingInput に対応 ────────────────────────────────────────────────
// typeDefs: input CreateBookingInput { planId!, customerName!, customerEmail!,
//           customerPhone!, numberOfPeople!, travelDate!, specialRequests, paymentMethod }
// bookingResolver の手動バリデーションを Zod に集約する
export const createBookingSchema = z.object({
  planId: z.string().min(1, { message: 'planId is required' }),
  customerName: z.string().min(1, { message: 'customerName is required' }),
  customerEmail: z
    .string()
    .email({ message: 'Invalid email address' }),
  customerPhone: z
    .string()
    .min(1, { message: 'customerPhone is required' })
    .regex(/^[\d\-\+\(\)\s]{10,15}$/, {
      message: 'customerPhone must be a valid phone number (10–15 digits)',
    }),
  numberOfPeople: z
    .number()
    .int()
    .min(1, { message: 'numberOfPeople must be >= 1' }),
  travelDate: z
    .string()
    .min(1, { message: 'travelDate is required' })
    .refine((s) => !isNaN(Date.parse(s)), {
      message: 'travelDate must be a valid date string (e.g. 2025-09-01)',
    }),
  specialRequests: z.string().optional(),
  paymentMethod: z.string().optional(),
});

// ─── ページネーション共通 ──────────────────────────────────────────────────────
// travelPlans(page: Int, pageSize: Int) のトップレベル引数に対応
// planResolver の Math.max / Math.min による上下限を Zod で明示する
export const paginationSchema = z.object({
  page: z.number().int().min(1, { message: 'page must be >= 1' }).default(1),
  pageSize: z
    .number()
    .int()
    .min(1, { message: 'pageSize must be >= 1' })
    .max(50, { message: 'pageSize must be <= 50' })
    .default(20),
});

// ─── 型エクスポート ───────────────────────────────────────────────────────────
export type PlanFilterInput = z.infer<typeof planFilterSchema>;
export type CreateBookingInput = z.infer<typeof createBookingSchema>;
export type PaginationInput = z.infer<typeof paginationSchema>;
