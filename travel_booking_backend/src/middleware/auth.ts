import { Request, Response, NextFunction } from 'express';
import { verifyToken, TokenPayload } from '../utils/auth';

// Express の Request 型を拡張して user プロパティを追加
declare global {
  namespace Express {
    interface Request {
      user: TokenPayload | null;
    }
  }
}

export function authMiddleware(req: Request, _res: Response, next: NextFunction): void {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    req.user = null;
    return next();
  }

  const token = authHeader.slice(7); // 'Bearer ' の後
  try {
    req.user = verifyToken(token);
  } catch {
    // 期限切れ・改ざん等は null 扱い（閲覧系は未認証でも通す）
    req.user = null;
  }

  next();
}
