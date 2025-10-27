/**
 * Unified record action type for deterministic scenario playback.
 */
interface RecordAction {
  order: number;
  type: 'create' | 'update' | 'patch' | 'delete';
  object_name: string;
  id?: string;
  status?: string;
  data?: Record<string, any>;
  diff?: Record<string, any>;
}

/**
 * Represents one ordered step in a scenario.
 */
interface Step {
  id: string;
  title: string;
  user_action: string;
  record_actions?: RecordAction[];
  sync_moments?: SyncMoment[];
  layout_query?: {
    object_name: string;
    object_type: string;
    status: string;
    expected_layout: string;
  };
  notes?: string;
}

/**
 * Represents a complete, ordered business scenario.
 */
interface ScenarioFlow {
  name: string;
  description: string;
  steps: Step[];
}

/**
 * AC Tune-Up Happy Path — deterministic event log.
 */
export const happyPathDemo: ScenarioFlow = {
  name: "AC Tune-Up Happy Path",
  description:
    "End-to-end narrative demonstrating instant sync, dynamic layouts, and offline-first architecture.",
  steps: [
    {
      id: "1",
      title: "Customer Call & Quote Creation",
      user_action:
        "Jane Doe calls; Sue (admin) creates customer and quote for an AC Tuneup.",
      record_actions: [
        {
          order: 1,
          type: "create",
          object_name: "customer",
          id: "cust-123",
          status: "active",
          data: {
            name: "Jane Doe",
            address: "123 Main St",
            phone: "512-555-1212"
          }
        },
        {
          order: 2,
          type: "create",
          object_name: "quote",
          id: "quote-456",
          status: "pending",
          data: {
            customer_id: "cust-123",
            line_items: [{ service: "AC Tuneup", price: 150.0 }],
            total: 150.0
          }
        }
      ],
      notes:
        "Customer and quote created. Quote remains pending until a manager approves."
    },
    {
      id: "2",
      title: "Quote Approval",
      user_action:
        "Manager reviews quote and marks it approved so it can be converted to a job.",
      record_actions: [
        {
          order: 1,
          type: "update",
          object_name: "quote",
          id: "quote-456",
          status: "approved"
        }
      ],
      notes: "Explicit approval separates sales step from dispatch."
    },
    {
      id: "3",
      title: "Dispatch Creates Job & Appointment",
      user_action:
        "Sue converts the approved quote into a job and schedules Tech Bob for tomorrow at 9 AM.",
      record_actions: [
        {
          order: 1,
          type: "create",
          object_name: "job",
          id: "job-789",
          status: "scheduled",
          data: {
            job_number: "J-1025",
            customer_id: "cust-123",
            job_address: "123 Main St",
            job_description: "AC Tuneup",
            assigned_tech_id: "tech-bob",
            quote_id: "quote-456"
          }
        },
        {
          order: 2,
          type: "create",
          object_name: "calendar_event",
          id: "appt-001",
          status: "scheduled",
          data: {
            job_id: "job-789",
            user_id: "tech-bob",
            start_time: "2025-10-26T09:00:00",
            end_time: "2025-10-26T11:00:00"
          }
        }
      ],
      sync_moments: [
        {
          description:
            "Rust BFFE pushes job + appointment instantly to Tech Bob’s device via WebSocket.",
          records: ["job-789", "appt-001"],
          participants: ["tech-bob", "admin-sue"]
        }
      ],
      layout_query: {
        object_name: "job",
        object_type: "job_residential_tuneup",
        status: "scheduled",
        expected_layout: "JobScheduledLayout"
      },
      notes: "Proves real-time dispatch sync and layout selection."
    },
    {
      id: "4",
      title: "Tech Requests Clarification",
      user_action:
        "Bob posts a question on the job feed asking which AC unit this is for.",
      record_actions: [
        {
          order: 1,
          type: "create",
          object_name: "object_feed",
          id: "feed-001",
          status: "new",
          data: {
            related_object_name: "job",
            related_record_id: "job-789",
            author_id: "tech-bob",
            entry_type: "comment",
            message:
              "Customer has 3 units. Which one is this for? Is it the Goodman 3-ton on the roof?"
          }
        }
      ],
      sync_moments: [
        {
          description: "Feed item broadcast instantly to Sue’s dashboard.",
          records: ["feed-001"],
          participants: ["tech-bob", "admin-sue"]
        }
      ],
      notes: "Live collaboration proof point."
    },
    {
      id: "5",
      title: "Admin Responds",
      user_action:
        "Sue replies on the feed to clarify the work.",
      record_actions: [
        {
          order: 1,
          type: "create",
          object_name: "object_feed",
          id: "feed-002",
          status: "posted",
          data: {
            related_object_name: "job",
            related_record_id: "job-789",
            author_id: "admin-sue",
            entry_type: "comment",
            message:
              "Yes, it’s the 3-ton Goodman. Please proceed."
          }
        }
      ],
      sync_moments: [
        {
          description:
            "Feed reply instantly syncs to Bob’s device.",
          records: ["feed-002"],
          participants: ["tech-bob"]
        }
      ]
    },
    {
      id: "6",
      title: "Tech Verifies Inventory (Offline-First)",
      user_action:
        "Bob reviews today’s appointments and checks truck inventory while offline.",
      notes:
        "Demonstrates offline local queries using appointments, job_type_parts_template, and product_items tables."
    },
    {
      id: "7",
      title: "Tech Rolls Out & Customer ETA",
      user_action:
        "Bob taps 'En Route'; backend updates his live status and notifies customer.",
      record_actions: [
        {
          order: 1,
          type: "update",
          object_name: "user",
          id: "tech-bob",
          status: "en_route"
        }
      ],
      sync_moments: [
        {
          description:
            "Live Map updates instantly; backend sends ETA SMS to Jane Doe.",
          records: ["tech-bob", "job-789"],
          participants: ["admin-sue", "customer-jane"]
        }
      ]
    },
    {
      id: "8",
      title: "Tech Arrives & Starts Work",
      user_action:
        "Bob marks job as 'in_progress', triggering live sync and dynamic layout reload.",
      record_actions: [
        {
          order: 1,
          type: "update",
          object_name: "job",
          id: "job-789",
          status: "in_progress"
        }
      ],
      sync_moments: [
        {
          description:
            "Job status update broadcast; client reloads 'Work Checklist' layout.",
          records: ["job-789"],
          participants: ["tech-bob", "admin-sue"]
        }
      ],
      layout_query: {
        object_name: "job",
        object_type: "job_residential_tuneup",
        status: "in_progress",
        expected_layout: "JobWorkChecklistLayout"
      }
    },
    {
      id: "9",
      title: "Tech Completes Work Items",
      user_action:
        "Bob checks off work line items; progress syncs in real-time to admin dashboard.",
      record_actions: [
        {
          order: 1,
          type: "update",
          object_name: "job_line_item",
          id: "line-001",
          status: "in_progress"
        },
        {
          order: 2,
          type: "update",
          object_name: "job_line_item",
          id: "line-001",
          status: "complete"
        }
      ],
      sync_moments: [
        {
          description:
            "Admin sees live job progress bar move as line items update.",
          records: ["line-001"],
          participants: ["admin-sue"]
        }
      ]
    },
    {
      id: "10",
      title: "Job Completion & Invoicing",
      user_action:
        "Bob marks job 'work_complete'; Sue reviews and approves for invoicing; backend generates invoice PDF.",
      record_actions: [
        {
          order: 1,
          type: "update",
          object_name: "job",
          id: "job-789",
          status: "work_complete"
        },
        {
          order: 2,
          type: "update",
          object_name: "job",
          id: "job-789",
          status: "invoice_approved"
        },
        {
          order: 3,
          type: "create",
          object_name: "invoice",
          id: "inv-001",
          status: "active",
          data: {
            job_id: "job-789",
            customer_id: "cust-123",
            total: 150.0,
            payment_status: "sent",
            pdf_url: null
          }
        },
        {
          order: 4,
          type: "patch",
          object_name: "invoice",
          id: "inv-001",
          diff: { op: "add", path: "/pdf_url", value: "s3.com/inv-001.pdf" }
        }
      ],
      sync_moments: [
        {
          description:
            "Invoice created and emailed automatically; job transitions to 'Pending Review'.",
          records: ["inv-001", "job-789"],
          participants: ["admin-sue", "customer-jane"]
        }
      ],
      notes:
        "Demonstrates backend automation and document generation triggered by record change."
    }
  ]
};