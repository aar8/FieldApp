import Alpine from "alpinejs";

type Job = {
  id: string;
  customerName: string;
  status: string;
  scheduledStart?: string | null;
};

const fetchJobs = async (): Promise<Job[]> => {
  const response = await fetch("/api/jobs", {
    headers: {
      Accept: "application/json"
    }
  });

  if (!response.ok) {
    const message = await response.text();
    throw new Error(message || "Failed to load jobs");
  }

  const payload = (await response.json()) as { data: Job[] };
  return payload.data;
};

window.jobBoard = function jobBoard() {
  return {
    jobs: [] as Job[],
    status: "Idle",
    error: "",
    async refresh() {
      this.status = "Loading…";
      this.error = "";
      try {
        this.jobs = await fetchJobs();
        this.status = `Updated ${new Date().toLocaleTimeString()}`;
      } catch (error) {
        this.error = error instanceof Error ? error.message : "Unexpected error";
        this.status = "Failed";
      }
    }
  };
};

declare global {
  interface Window {
    jobBoard: () => {
      jobs: Job[];
      status: string;
      error: string;
      refresh: () => Promise<void>;
    };
  }
}

document.addEventListener("alpine:init", () => {
  Alpine.data("jobBoard", window.jobBoard);
});

Alpine.start();
