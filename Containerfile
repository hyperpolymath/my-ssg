# SPDX-License-Identifier: AGPL-3.0-or-later
# SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
# Containerfile for my-ssg - NoteG Static Site Generator

# ============================================================================
# Stage 1: Build environment
# ============================================================================
FROM docker.io/denoland/deno:alpine-2.1.4 AS builder

WORKDIR /build

# Install build dependencies
RUN apk add --no-cache \
    git \
    just \
    nodejs \
    npm

# Copy source
COPY . .

# Build the project
RUN just build || true

# ============================================================================
# Stage 2: Runtime environment
# ============================================================================
FROM docker.io/denoland/deno:alpine-2.1.4

LABEL org.opencontainers.image.title="my-ssg"
LABEL org.opencontainers.image.description="NoteG Static Site Generator with MCP integration"
LABEL org.opencontainers.image.version="0.1.0"
LABEL org.opencontainers.image.authors="Jonathan D.A. Jewell"
LABEL org.opencontainers.image.licenses="AGPL-3.0-or-later"
LABEL org.opencontainers.image.source="https://github.com/hyperpolymath/my-ssg"

WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache \
    just \
    tini

# Copy built artifacts
COPY --from=builder /build/ssg /app/ssg
COPY --from=builder /build/noteg-lang /app/noteg-lang
COPY --from=builder /build/noteg-mcp /app/noteg-mcp
COPY --from=builder /build/adapters /app/adapters
COPY --from=builder /build/a11y /app/a11y
COPY --from=builder /build/Justfile /app/Justfile

# Create non-root user
RUN adduser -D -u 1000 noteg
USER noteg

# Default port for dev server
EXPOSE 8080

# Use tini as init
ENTRYPOINT ["/sbin/tini", "--"]

# Default command
CMD ["just", "serve"]
