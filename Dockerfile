# Build stage: compile the Crystal application
FROM crystallang/crystal:1.18.1-alpine AS builder

WORKDIR /app

# Copy dependency files and install dependencies
COPY shard.yml shard.lock ./
RUN shards install --production

# Copy the rest of the application source code
COPY . .

# Build the application in release mode
RUN crystal build src/crit.cr --release --no-debug -o crit

# Runtime stage: minimal image for running the app
FROM alpine:3.23

WORKDIR /app

# Install required runtime libraries
RUN apk add --no-cache libssl3 pcre2 libgc++ libgcc git-daemon

# Copy the built binary and necessary directories
COPY --from=builder /app/crit .
COPY --from=builder /app/public ./public
COPY --from=builder /app/views ./views

# Create a non-root user for running the application
RUN addgroup -S crit && adduser -S crit -G crit

# Create repository directory and set permissions
RUN mkdir -p /data/git && chown -R crit:crit /data/git
VOLUME ["/data/git"]

# Set environment variables
ENV PORT=3000
ENV CRIT_REPO_ROOT=/data/git

# Expose the port
EXPOSE 3000

# Switch to non-root user
USER crit

# Start the application
ENTRYPOINT ["./crit"]
