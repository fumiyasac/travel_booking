import { z } from 'zod';
import { GraphQLError } from 'graphql';

export function validate<S extends z.ZodTypeAny>(schema: S, data: unknown): z.infer<S> {
  const result = schema.safeParse(data);
  if (!result.success) {
    const messages = result.error.issues.map(
      (issue: z.ZodIssue) => `${issue.path.join('.')}: ${issue.message}`,
    );
    throw new GraphQLError(messages.join(', '), {
      extensions: { code: 'VALIDATION_ERROR' },
    });
  }
  return result.data;
}
