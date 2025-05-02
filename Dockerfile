# Build stage: compile the Crystal application
FROM crystallang/crystal:1.16.2-alpine AS builder

WORKDIR /app

# Copy dependency files and install dependencies
COPY shard.yml shard.lock ./
RUN shards install --production

# Copy the rest of the application source code
COPY . .

# Build the application in release mode
RUN crystal build src/crit.cr --release --no-debug -o crit

# Runtime stage: minimal image for running the app
FROM alpine:3.21

WORKDIR /app

# Install required runtime libraries
RUN apk add --no-cache libssl3 pcre2 libgc++ libgcc git-daemon

# Copy the built binary and necessary directories
COPY --from=builder /app/crit .
COPY --from=builder /app/public ./public
COPY --from=builder /app/views ./views

# Set environment variables (PORT is set by Koyeb, but default to 3000 for local)
ENV PORT=3000

EXPOSE 3000

# Start the application
ENTRYPOINT ["./crit"]
