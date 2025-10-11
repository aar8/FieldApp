import type { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken";
import { TypedError } from "../types/errors.js";

const secret = process.env.JWT_SECRET ?? "development-secret";

export interface AuthContext {
  readonly userId: string;
  readonly roles: ReadonlyArray<string>;
  readonly tenantId?: string;
}

declare module "express-serve-static-core" {
  interface Request {
    auth?: AuthContext;
  }
}

export const jwtMiddleware = (req: Request, _res: Response, next: NextFunction): void => {
  const header = req.header("Authorization");
  if (!header) {
    return next(
      new TypedError("Missing Authorization header", { status: 401, code: "unauthorized" })
    );
  }

  const token = header.replace("Bearer ", "");

  try {
    const decoded = jwt.verify(token, secret) as jwt.JwtPayload;
    if (!decoded.sub || typeof decoded.sub !== "string") {
      throw new TypedError("Invalid token payload", { status: 401, code: "unauthorized" });
    }

    req.auth = {
      userId: decoded.sub,
      roles: Array.isArray(decoded.roles) ? decoded.roles.map(String) : [],
      tenantId: resolveTenantId(decoded),
    };
    next();
  } catch (error) {
    next(
      error instanceof TypedError
        ? error
        : new TypedError("Invalid token", { status: 401, code: "unauthorized", details: error })
    );
  }
};

export const optionalJwtMiddleware = (
  req: Request,
  _res: Response,
  next: NextFunction
): void => {
  const header = req.header("Authorization");
  if (!header) {
    return next();
  }

  try {
    const token = header.replace("Bearer ", "");
    const decoded = jwt.verify(token, secret) as jwt.JwtPayload;
    if (decoded.sub && typeof decoded.sub === "string") {
      req.auth = {
        userId: decoded.sub,
        roles: Array.isArray(decoded.roles) ? decoded.roles.map(String) : [],
        tenantId: resolveTenantId(decoded),
      };
    }
  } catch {
    // Silently ignore invalid optional tokens
  }

  next();
};

const resolveTenantId = (payload: jwt.JwtPayload): string | undefined => {
  if (typeof payload.tenant_id === "string") {
    return payload.tenant_id;
  }

  if (typeof payload.tenantId === "string") {
    return payload.tenantId;
  }

  return undefined;
};
