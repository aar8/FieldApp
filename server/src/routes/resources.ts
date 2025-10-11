import type { Request, Router } from "express";
import { listCustomers } from "../db/customers.js";
import { listJobEventsByJobId } from "../db/jobEvents.js";
import { listJobs } from "../db/jobs.js";
import { listUsers } from "../db/users.js";
import { withDatabase } from "../utils/database.js";

export const registerResourceRoutes = (router: Router): void => {
  router.get("/users", async (req, res, next) => {
    try {
      const tenantId = resolveTenantId(req);
      const users = await withDatabase((db) => listUsers(db, tenantId));
      res.json({ data: users });
    } catch (error) {
      next(error);
    }
  });

  router.get("/customers", async (req, res, next) => {
    try {
      const tenantId = resolveTenantId(req);
      const customers = await withDatabase((db) => listCustomers(db, tenantId));
      res.json({ data: customers });
    } catch (error) {
      next(error);
    }
  });

  router.get("/jobs", async (req, res, next) => {
    try {
      const tenantId = resolveTenantId(req);
      const jobs = await withDatabase((db) => listJobs(db, tenantId));
      res.json({ data: jobs });
    } catch (error) {
      next(error);
    }
  });

  router.get("/jobs/:id/events", async (req, res, next) => {
    try {
      const tenantId = resolveTenantId(req);
      const jobId = req.params.id;
      const events = await withDatabase((db) => listJobEventsByJobId(db, tenantId, jobId));

      res.json({ data: events });
    } catch (error) {
      next(error);
    }
  });
};

const resolveTenantId = (req: Request): string => {
  const headerTenant = req.header("x-tenant-id");
  return req.auth?.tenantId ?? (typeof headerTenant === "string" ? headerTenant : undefined) ?? "default";
};
