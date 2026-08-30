import { z } from 'zod';
import { GraphQLError } from 'graphql';

export function validate<T>(schema: z.ZodSchema<T>, data: unknown): T {
  const result = schema.safeParse(data);
  if (!result.success) {
    const messages = result.error.issues.map(
      (issue) => `${issue.path.join('.')}: ${issue.message}`,
    );
    throw new GraphQLError(messages.join(', '), {
      extensions: { code: 'VALIDATION_ERROR' },
    });
  }
  return result.data;
}
