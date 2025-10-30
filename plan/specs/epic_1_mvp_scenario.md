/**
 * Unified record action type for deterministic scenario playback.
 * Separates action metadata from the record payload for clarity and schema alignment.
 */
interface RecordAction {
  order: number;
  action: 'create' | 'update' | 'patch' | 'delete';
  object_name: string;
  record: Record<string, any>; // The full, schema-compliant record payload.
  diff?: Record<string, any>; // For 'patch' actions, using JSON Patch format.
}

/**
 * Describes a set of expected field values for a specific record.
 * Used to verify the outcome of a user action in a test scenario.
 */
interface RecordExpectation {
  object_name: string;
  id_to_check: string; // The ID of the record to verify.
  expected_state: Record<string, any>; // A map of field names to their expected values.
}

/**
 * Represents one ordered step in a scenario.
 */
interface Step {
  id: string;
  title: string;
  user_action: string; // High-level description of what the user does.
  state_expectations?: RecordExpectation[]; // The verifiable outcomes of the user action.
  layout_query?: {
    object_name: string;
    object_type: string;
    status: string;
  };
  notes?: string;
}

/**
 * Represents a complete, ordered business scenario.
 */
interface ScenarioFlow {
  name: string;
  description: string;
  preScenarioSetup?: RecordAction[];
  steps: Step[];
}

/**
 * AC Tune-Up Happy Path — deterministic event log.
 */
export const happyPathDemo: ScenarioFlow = {
  name: "AC Tune-Up Happy Path",
  description:
    "End-to-end narrative demonstrating instant sync, dynamic layouts, and offline-first architecture.",
  preScenarioSetup: [
    {
      order: 1,
      action: "create",
      object_name: "tenant",
      record: {
        id: "tnt_epic1_demo",
        version: 1,
        created_at: "2025-10-25T10:00:00Z",
        updated_at: "2025-10-25T10:00:00Z",
        data: {
          name: "FieldApp Demo Inc.",
          plan: "premium",
          settings: {},
        },
      },
    },
    {
      order: 2,
      action: "create",
      object_name: "product",
      record: {
        id: "prod_ac_tuneup",
        tenant_id: "tnt_epic1_demo",
        status: "active",
        version: 1,
        object_name: "product",
        object_type: "service",
        created_at: "2025-10-25T10:00:00Z",
        updated_at: "2025-10-25T10:00:00Z",
        data: {
          name: "AC Tuneup",
          product_code: "SVC-TUNEUP-AC",
          type: "service",
        },
      },
    },
    {
      order: 3,
      action: "create",
      object_name: "user",
      record: {
        id: "admin-sue",
        tenant_id: "tnt_epic1_demo",
        status: "active",
        version: 1,
        object_name: "user",
        object_type: "standard_user",
        created_at: "2025-10-25T10:00:00Z",
        updated_at: "2025-10-25T10:00:00Z",
        data: {
          display_name: "Sue (Admin)",
          email: "sue@example.com",
          role: "admin",
        },
      },
    },
    {
      order: 4,
      action: "create",
      object_name: "user",
      record: {
        id: "tech-bob",
        tenant_id: "tnt_epic1_demo",
        status: "active",
        version: 1,
        object_name: "user",
        object_type: "standard_user",
        created_at: "2025-10-25T10:00:00Z",
        updated_at: "2025-10-25T10:00:00Z",
        data: {
          display_name: "Tech Bob",
          email: "bob@example.com",
          role: "tech",
        },
      },
    },
    {
      order: 5,
      action: "create",
      object_name: "object_metadata",
      record: {
        id: "meta-job",
        tenant_id: "tnt_epic1_demo",
        object_name: "job",
        version: 1,
        created_at: "2025-10-25T10:00:00Z",
        updated_at: "2025-10-25T10:00:00Z",
        data: {
          field_definitions: [
            { name: "job_number", label: "Job Number", type: "string" },
            { name: "customer_id", label: "Customer", type: "reference", target_object: "customer" },
            { name: "job_address", label: "Job Address", type: "string" },
            { name: "job_description", label: "Description", type: "string" },
            { name: "assigned_tech_id", label: "Assigned Tech", type: "reference", target_object: "user" },
            { name: "quote_id", label: "Quote", type: "reference", target_object: "quote" },
          ],
        },
      },
    },
    {
      order: 6,
      action: "create",
      object_name: "layout_definition",
      record: {
        id: "layout-job-scheduled",
        tenant_id: "tnt_epic1_demo",
        object_name: "job",
        object_type: "job_residential_tuneup",
        status: "scheduled",
        version: 1,
        created_at: "2025-10-25T10:00:00Z",
        updated_at: "2025-10-25T10:00:00Z",
        data: {
          sections: [
            { label: "Job Info", fields: ["job_number", "customer_id", "job_address", "job_description"] },
            { label: "Scheduling", fields: ["assigned_tech_id"] },
          ],
        },
      },
    },
    {
      order: 7,
      action: "create",
      object_name: "layout_definition",
      record: {
        id: "layout-job-inprogress",
        tenant_id: "tnt_epic1_demo",
        object_name: "job",
        object_type: "job_residential_tuneup",
        status: "in_progress",
        version: 1,
        created_at: "2025-10-25T10:00:00Z",
        updated_at: "2025-10-25T10:00:00Z",
        data: {
          sections: [
            { label: "Work Checklist", fields: ["job_description"] },
          ],
        },
      },
    },
    {
      order: 8,
      action: "create",
      object_name: "object_metadata",
      record: {
        id: "meta-user",
        tenant_id: "tnt_epic1_demo",
        object_name: "user",
        version: 1,
        created_at: "2025-10-25T10:00:00Z",
        updated_at: "2025-10-25T10:00:00Z",
        data: {
          field_definitions: [
            { name: "display_name", label: "Display Name", type: "string" },
            { name: "email", label: "Email", type: "string", format: "email" },
            { name: "role", label: "Role", type: "picklist", options: ["admin", "tech", "dispatcher", "owner"] },
          ],
        },
      },
    },
    {
      order: 9,
      action: "create",
      object_name: "layout_definition",
      record: {
        id: "layout-user-default",
        tenant_id: "tnt_epic1_demo",
        object_name: "user",
        object_type: "*",
        status: "*",
        version: 1,
        created_at: "2025-10-25T10:00:00Z",
        updated_at: "2025-10-25T10:00:00Z",
        data: {
          sections: [
            { label: "User Information", fields: ["display_name", "email", "role"] },
          ],
        },
      },
    },
  ],
  steps: [
    {
      id: "1",
      title: "Customer Call & Quote Creation",
      user_action: "Jane Doe calls; Sue (admin) creates customer and quote for an AC Tuneup.",
      state_expectations: [
        {
          object_name: "customer",
          id_to_check: "cust-123",
          expected_state: {
            status: "active",
            data: { name: "Jane Doe" },
          },
        },
        {
          object_name: "quote",
          id_to_check: "quote-456",
          expected_state: {
            status: "pending",
            data: { quote_status: "draft", customer_id: "cust-123" },
          },
        },
      ],
      notes: "Customer and quote created. Quote remains pending until a manager approves.",
    },
    {
      id: "2",
      title: "Quote Approval",
      user_action: "Manager reviews quote and marks it approved so it can be converted to a job.",
      state_expectations: [
        {
          object_name: "quote",
          id_to_check: "quote-456",
          expected_state: {
            status: "approved",
            data: { quote_status: "accepted" },
          },
        },
      ],
      notes: "Explicit approval separates sales step from dispatch.",
    },
    {
      id: "3",
      title: "Dispatch Creates Job & Appointment",
      user_action: "Sue converts the approved quote into a job and schedules Tech Bob for tomorrow at 9 AM.",
      state_expectations: [
        {
          object_name: "job",
          id_to_check: "job-789",
          expected_state: {
            status: "scheduled",
            data: { customer_id: "cust-123", assigned_tech_id: "tech-bob" },
          },
        },
        {
          object_name: "calendar_event",
          id_to_check: "appt-001",
          expected_state: {
            status: "scheduled",
            data: { job_id: "job-789", user_id: "tech-bob" },
          },
        },
      ],
      layout_query: {
        object_name: "job",
        object_type: "job_residential_tuneup",
        status: "scheduled",
      },
      notes: "Proves real-time dispatch sync and layout selection.",
    },
    {
      id: "4",
      title: "Tech Requests Clarification",
      user_action: "Bob posts a question on the job feed asking which AC unit this is for.",
      state_expectations: [
        {
          object_name: "object_feed",
          id_to_check: "feed-001",
          expected_state: {
            status: "new",
            data: { related_record_id: "job-789", author_id: "tech-bob", entry_type: "comment" },
          },
        },
      ],
      notes: "Live collaboration proof point.",
    },
    {
      id: "5",
      title: "Admin Responds",
      user_action: "Sue replies on the feed to clarify the work.",
      state_expectations: [
        {
          object_name: "object_feed",
          id_to_check: "feed-002",
          expected_state: {
            status: "posted",
            data: { related_record_id: "job-789", author_id: "admin-sue" },
          },
        },
      ],
    },
    {
      id: "6",
      title: "Tech Verifies Inventory (Offline-First)",
      user_action: "Bob reviews today’s appointments and checks truck inventory while offline.",
      notes: "Demonstrates offline local queries using appointments, job_type_parts_template, and product_items tables.",
    },
    {
      id: "7",
      title: "Tech Rolls Out & Customer ETA",
      user_action: "Bob taps 'En Route'; backend updates his live status and notifies customer.",
      state_expectations: [
        {
          object_name: "user",
          id_to_check: "tech-bob",
          expected_state: {
            status: "en_route",
          },
        },
      ],
    },
    {
      id: "8",
      title: "Tech Arrives & Starts Work",
      user_action: "Bob marks job as 'in_progress', triggering live sync and dynamic layout reload.",
      state_expectations: [
        {
          object_name: "job",
          id_to_check: "job-789",
          expected_state: {
            status: "in_progress",
          },
        },
      ],
      layout_query: {
        object_name: "job",
        object_type: "job_residential_tuneup",
        status: "in_progress",
      },
    },
    {
      id: "9",
      title: "Tech Completes Work Items",
      user_action: "Bob checks off work line items; progress syncs in real-time to admin dashboard.",
      state_expectations: [
        {
          object_name: "job_line_item",
          id_to_check: "line-001",
          expected_state: {
            status: "complete",
            data: { job_id: "job-789" },
          },
        },
      ],
    },
    {
      id: "10",
      title: "Tech Completes Work",
      user_action: "Bob marks the job as 'work_complete'.",
      state_expectations: [
        {
          object_name: "job",
          id_to_check: "job-789",
          expected_state: {
            status: "work_complete",
          },
        },
      ],
      notes: "Job is now ready for administrative review.",
    },
    {
      id: "11",
      title: "Admin Approves for Invoicing",
      user_action: "Sue reviews the completed job and approves it for invoicing.",
      state_expectations: [
        {
          object_name: "job",
          id_to_check: "job-789",
          expected_state: {
            status: "invoice_approved",
          },
        },
      ],
      notes: "This status change will trigger automated invoicing.",
    },
    {
      id: "12",
      title: "System Generates Invoice",
      user_action: "(Automated) The system detects the 'invoice_approved' status and generates the invoice and its PDF.",
      state_expectations: [
        {
          object_name: "invoice",
          id_to_check: "inv-001",
          expected_state: {
            status: "active",
            data: {
              payment_status: "sent",
              job_id: "job-789",
              custom_fields: {
                pdf_url: "s3.com/inv-001.pdf",
              },
            },
          },
        },
      ],
      notes: "Demonstrates backend automation triggered by a record change.",
    },
  ],
};