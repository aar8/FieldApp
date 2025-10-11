import type { Router } from "express";
import { checkDatabase } from "../db/system.js";
import { withDatabase } from "../utils/database.js";

export const registerHealthRoute = (router: Router): void => {
  router.get("/health", async (_req, res, next) => {
    try {
      await withDatabase((db) => checkDatabase(db));
      res.json({ status: "ok", timestamp: new Date().toISOString() });
    } catch (error) {
      next(error);
    }
  });
};
