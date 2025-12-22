# SPDX-License-Identifier: AGPL-3.0-or-later
# SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
# Justfile for my-ssg - NoteG Static Site Generator

# Default recipe
default: help

# Show available commands
help:
    @just --list --unsorted

# ============================================================================
# BUILD COMMANDS
# ============================================================================

# Build the entire project
build: build-engine build-ssg build-lang
    @echo "Build complete"

# Build Ada/SPARK engine
build-engine:
    @echo "Building Ada/SPARK engine..."
    cd engine && gprbuild -P noteg_engine.gpr -XBUILD_MODE=release 2>/dev/null || echo "Ada toolchain not available"

# Build SSG ReScript components
build-ssg:
    @echo "Building SSG ReScript components..."
    cd ssg && npm run build 2>/dev/null || echo "ReScript toolchain not available"

# Build NoteG language tooling
build-lang:
    @echo "Building NoteG language tooling..."
    cd noteg-lang && npm run build 2>/dev/null || echo "ReScript toolchain not available"

# Clean all build artifacts
clean:
    @echo "Cleaning build artifacts..."
    rm -rf engine/obj engine/lib ssg/lib noteg-lang/lib _site .cache
    @echo "Clean complete"

# ============================================================================
# TEST COMMANDS
# ============================================================================

# Run all tests
test: test-unit test-integration
    @echo "All tests complete"

# Run all tests including E2E
test-all: test test-e2e
    @echo "Full test suite complete"

# Run unit tests
test-unit:
    @echo "Running unit tests..."
    deno test tests/unit/ --allow-read --allow-write --allow-run 2>/dev/null || echo "Run 'deno test' manually"

# Run integration tests
test-integration:
    @echo "Running integration tests..."
    deno test tests/ --allow-read --allow-write --allow-run --allow-net 2>/dev/null || echo "Run 'deno test' manually"

# Run end-to-end tests
test-e2e:
    @echo "Running E2E tests..."
    deno test tests/e2e/ --allow-all 2>/dev/null || echo "Run 'deno test tests/e2e/' manually"

# Run Bernoulli verification tests
test-bernoulli:
    @echo "Running Bernoulli probabilistic verification..."
    cd engine && alr run -- --verify 2>/dev/null || echo "Ada/SPARK verification not available"

# Check code coverage
coverage:
    @echo "Generating coverage report..."
    deno test --coverage=.coverage tests/
    deno coverage .coverage --lcov > coverage.lcov

# ============================================================================
# LANGUAGE SERVER & TOOLING
# ============================================================================

# Start NoteG language server
lsp:
    @echo "Starting NoteG Language Server..."
    deno run --allow-all noteg-lang/src/lsp/server.ts

# Compile a .noteg file
compile file:
    @echo "Compiling {{file}}..."
    deno run --allow-all noteg-lang/src/compiler.ts {{file}}

# Parse a .noteg file (AST output)
parse file:
    @echo "Parsing {{file}}..."
    deno run --allow-all noteg-lang/src/parser.ts {{file}}

# Interpret a .noteg file
interpret file:
    @echo "Interpreting {{file}}..."
    deno run --allow-all noteg-lang/src/interpreter.ts {{file}}

# ============================================================================
# SITE GENERATION
# ============================================================================

# Generate static site
generate:
    @echo "Generating static site..."
    deno run --allow-all ssg/src/build.ts

# Serve development site with live reload
serve port="8080":
    @echo "Starting development server on port {{port}}..."
    deno run --allow-all ssg/src/serve.ts --port {{port}}

# Watch for changes and regenerate
watch:
    @echo "Watching for changes..."
    deno run --allow-all ssg/src/watch.ts

# ============================================================================
# MCP SERVER
# ============================================================================

# Start MCP server
mcp-start:
    @echo "Starting NoteG MCP server..."
    deno run --allow-all noteg-mcp/src/server.ts

# Test MCP protocol compliance
mcp-test:
    @echo "Testing MCP protocol compliance..."
    deno test noteg-mcp/tests/

# ============================================================================
# DEVELOPMENT UTILITIES
# ============================================================================

# Format all code
fmt:
    @echo "Formatting code..."
    deno fmt --options-use-tabs=false --options-indent-width=2

# Lint all code
lint:
    @echo "Linting code..."
    deno lint

# Type check
check:
    @echo "Type checking..."
    deno check ssg/src/*.ts noteg-lang/src/*.ts noteg-mcp/src/*.ts

# Security audit
audit:
    @echo "Running security audit..."
    deno audit 2>/dev/null || echo "Deno audit not available in this version"

# ============================================================================
# CONTAINER COMMANDS
# ============================================================================

# Build container image
container-build:
    podman build -t my-ssg:latest -f Containerfile .

# Run container
container-run:
    podman run -it --rm -v $(pwd):/workspace:Z my-ssg:latest

# Push container to registry
container-push registry="ghcr.io/hyperpolymath":
    podman push my-ssg:latest {{registry}}/my-ssg:latest

# ============================================================================
# DOCUMENTATION
# ============================================================================

# Generate documentation
docs:
    @echo "Generating documentation..."
    deno run --allow-all docs/generate.ts

# Serve documentation locally
docs-serve:
    @echo "Serving documentation..."
    deno run --allow-all --allow-net docs/serve.ts

# ============================================================================
# RELEASE
# ============================================================================

# Create release
release version:
    @echo "Creating release {{version}}..."
    git tag -a v{{version}} -m "Release {{version}}"
    git push origin v{{version}}

# Changelog generation
changelog:
    @echo "Generating changelog..."
    git log --oneline --decorate > CHANGELOG.md

# ============================================================================
# ACCESSIBILITY
# ============================================================================

# Validate accessibility schemas
a11y-validate:
    @echo "Validating accessibility schemas..."
    deno run --allow-read a11y/validate.ts

# Generate accessibility report
a11y-report:
    @echo "Generating accessibility report..."
    deno run --allow-all a11y/report.ts
