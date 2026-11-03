
import type { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

export interface AuthUser {
  userId: string;
  role: "STUDENT" | "ASLAB";
}

// Menambahkan properti auth pada Express Request.
declare global {
  namespace Express {
    interface Request {
      auth?: AuthUser;
    }
  }
}

export function requireAuth(
  req: Request,
  res: Response,
  next: NextFunction,
) {
  const authorization = req.headers.authorization;

  if (!authorization || !authorization.startsWith("Bearer ")) {
    res.status(401).json({
      success: false,
      message: "Token autentikasi diperlukan",
    });
    return;
  }

  const token = authorization.slice(7);
  const secret = process.env.JWT_SECRET;

  if (!secret) {
    res.status(500).json({
      success: false,
      message: "Konfigurasi autentikasi server belum tersedia",
    });
    return;
  }

  try {
    const decoded = jwt.verify(token, secret);

    if (
      typeof decoded === "string" ||
      typeof decoded.userId !== "string" ||
      !["STUDENT", "ASLAB"].includes(String(decoded.role))
    ) {
      res.status(401).json({
        success: false,
        message: "Token autentikasi tidak valid",
      });
      return;
    }

    req.auth = {
      userId: decoded.userId,
      role: decoded.role as AuthUser["role"],
    };

    next();
  } catch {
    res.status(401).json({
      success: false,
      message: "Token tidak valid atau sudah kedaluwarsa",
    });
  }
}
