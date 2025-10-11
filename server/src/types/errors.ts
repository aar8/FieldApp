export type ErrorCode =
  | "internal_error"
  | "not_found"
  | "validation_error"
  | "unauthorized"
  | "conflict";

export interface TypedErrorOptions {
  readonly status: number;
  readonly code: ErrorCode;
  readonly details?: unknown;
}

export class TypedError extends Error {
  readonly status: number;
  readonly code: ErrorCode;
  readonly details?: unknown;

  constructor(message: string, options: TypedErrorOptions) {
    super(message);
    this.status = options.status;
    this.code = options.code;
    this.details = options.details;
    Object.setPrototypeOf(this, TypedError.prototype);
  }
}

export interface ErrorResponse {
  readonly error: {
    readonly code: ErrorCode;
    readonly message: string;
    readonly details?: unknown;
  };
}

export const toErrorResponse = (error: unknown): ErrorResponse => {
  if (error instanceof TypedError) {
    return {
      error: {
        code: error.code,
        message: error.message,
        details: error.details,
      },
    };
  }

  if (error instanceof Error) {
    return {
      error: {
        code: "internal_error",
        message: error.message,
      },
    };
  }

  return {
    error: {
      code: "internal_error",
      message: "Unknown error",
    },
  };
};
