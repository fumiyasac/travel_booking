import rateLimit from 'express-rate-limit';

export const graphqlRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    errors: [
      {
        message: 'リクエスト数が上限に達しました。しばらく時間をおいてから再試行してください。',
        extensions: { code: 'RATE_LIMITED' },
      },
    ],
  },
  skip: () => process.env.NODE_ENV === 'test',
});
