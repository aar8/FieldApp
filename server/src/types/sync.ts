import { z } from "zod";

export interface SyncResult {
  readonly summary: {
    readonly appliedChanges: number;
    readonly pendingChanges: number;
    readonly lastSyncedAt: string;
  };
  readonly conflicts: ReadonlyArray<SyncConflict>;
}

export interface SyncConflict {
  readonly entity: string;
  readonly entityId: string;
  readonly reason: string;
}

export interface SyncError {
  readonly error: {
    readonly code: "sync_failed";
    readonly message: string;
    readonly detail?: unknown;
  };
}

export const syncPayloadSchema = z.object({
  deviceId: z.string().min(1),
  checkpoint: z.string().nullable().optional(),
  changes: z.array(
    z.object({
      table: z.enum(["users", "customers", "jobs", "job_events", "attachments"]),
      action: z.enum(["insert", "update", "delete"]),
      data: z.record(z.any()),
      primaryKey: z.string().min(1),
      version: z.number().int().nonnegative(),
    })
  ),
});

export type SyncPayloadSchema = z.infer<typeof syncPayloadSchema>;
