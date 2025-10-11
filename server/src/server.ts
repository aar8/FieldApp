import express from "express";
import helmet from "helmet";
import type { Request, Response, NextFunction } from "express";
import { bootstrapDatabase } from "./utils/database.js";
import { registerHealthRoute } from "./routes/health.js";
import { registerResourceRoutes } from "./routes/resources.js";
import { registerSyncRoute } from "./routes/sync.js";
import { optionalJwtMiddleware } from "./middleware/jwt.js";
import { toErrorResponse, TypedError } from "./types/errors.js";

export const createServer = () => {
  bootstrapDatabase();

  const app = express();
  app.use(helmet());
  app.use(express.json());
  app.use(optionalJwtMiddleware);

  const router = express.Router();
  registerHealthRoute(router);
  registerResourceRoutes(router);
  registerSyncRoute(router);

  app.use("/", router);
  app.use("/api", router);

  app.use((_req, _res, next) => {
    next(new TypedError("Route not found", { status: 404, code: "not_found" }));
  });

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  app.use((error: unknown, _req: Request, res: Response, _next: NextFunction) => {
    const typed = error instanceof TypedError ? error : undefined;
    const status = typed?.status ?? 500;
    res.status(status).json(toErrorResponse(error));
  });

  return app;
};
