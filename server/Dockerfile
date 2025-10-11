# Stage 1: Build the application
FROM --platform=$TARGETPLATFORM rust:1.82-slim-bullseye AS builder

# Set the working directory
WORKDIR /usr/src/app

# Copy the Cargo.toml and Cargo.lock files
COPY Cargo.toml Cargo.lock ./

# Copy the source code
COPY src ./src

# Build the application for release
RUN cargo build --release

# Stage 2: Create the final, smaller image
FROM --platform=$TARGETPLATFORM debian:bullseye-slim

# Copy the built binary from the builder stage
# The binary name is the same as the package name in Cargo.toml
COPY --from=builder /usr/src/app/target/release/fieldprime_server /usr/local/bin/fieldprime_server

# Expose port 8080 to the outside world
EXPOSE 8080

# Set the command to run the application
CMD ["/usr/local/bin/fieldprime_server"]
