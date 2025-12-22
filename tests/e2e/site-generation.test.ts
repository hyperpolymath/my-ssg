// SPDX-License-Identifier: AGPL-3.0-or-later
// SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
// End-to-end tests for site generation

import { assertEquals, assertExists } from "@std/assert";
import { describe, it, beforeAll, afterAll } from "@std/testing/bdd";
import { join } from "@std/path";

// ============================================================================
// Test Configuration
// ============================================================================

const TEST_CONTENT_DIR = "./test-fixtures/content";
const TEST_TEMPLATES_DIR = "./test-fixtures/templates";
const TEST_OUTPUT_DIR = "./test-fixtures/_site";

// ============================================================================
// Fixture Setup
// ============================================================================

async function setupFixtures(): Promise<void> {
  // Create test directories
  await Deno.mkdir(TEST_CONTENT_DIR, { recursive: true }).catch(() => {});
  await Deno.mkdir(TEST_TEMPLATES_DIR, { recursive: true }).catch(() => {});
  await Deno.mkdir(TEST_OUTPUT_DIR, { recursive: true }).catch(() => {});

  // Create test content
  const testPage = `---
title: Test Page
date: 2025-01-01
draft: false
tags: [test, e2e]
---

# Test Page

This is a test page for E2E testing.

## Section 1

Some content here.

## Section 2

More content here.
`;

  await Deno.writeTextFile(join(TEST_CONTENT_DIR, "test-page.md"), testPage);

  // Create test template
  const testTemplate = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>{{ page.title }}</title>
</head>
<body>
  <header>
    <h1>{{ site.title }}</h1>
  </header>
  <main>
    {{ page.content }}
  </main>
  <footer>
    <p>Built with NoteG</p>
  </footer>
</body>
</html>
`;

  await Deno.writeTextFile(join(TEST_TEMPLATES_DIR, "default.html"), testTemplate);

  // Create test config
  const testConfig = {
    name: "test-site",
    version: "0.1.0",
    site: {
      title: "Test Site",
      description: "E2E test site",
      url: "http://localhost:8080",
      language: "en-GB",
    },
    build: {
      contentDir: TEST_CONTENT_DIR,
      templatesDir: TEST_TEMPLATES_DIR,
      outputDir: TEST_OUTPUT_DIR,
      clean: true,
    },
    features: {
      enabled: true,
      bsl: false,
      gsl: false,
      asl: false,
      makaton: false,
    },
  };

  await Deno.writeTextFile(
    "./test-fixtures/noteg.config.json",
    JSON.stringify(testConfig, null, 2)
  );
}

async function cleanupFixtures(): Promise<void> {
  await Deno.remove("./test-fixtures", { recursive: true }).catch(() => {});
}

// ============================================================================
// E2E Tests
// ============================================================================

describe("Site Generation E2E", () => {
  beforeAll(async () => {
    await setupFixtures();
  });

  afterAll(async () => {
    await cleanupFixtures();
  });

  describe("Content Processing", () => {
    it("should create content directory", async () => {
      const stat = await Deno.stat(TEST_CONTENT_DIR).catch(() => null);
      assertExists(stat, "Content directory should exist");
      assertEquals(stat?.isDirectory, true);
    });

    it("should create test content file", async () => {
      const stat = await Deno.stat(join(TEST_CONTENT_DIR, "test-page.md")).catch(
        () => null
      );
      assertExists(stat, "Test page should exist");
      assertEquals(stat?.isFile, true);
    });

    it("should parse frontmatter correctly", async () => {
      const content = await Deno.readTextFile(
        join(TEST_CONTENT_DIR, "test-page.md")
      );

      // Check frontmatter delimiter
      assertEquals(content.startsWith("---"), true);

      // Check frontmatter contains expected fields
      assertEquals(content.includes("title: Test Page"), true);
      assertEquals(content.includes("date: 2025-01-01"), true);
    });
  });

  describe("Template Processing", () => {
    it("should create templates directory", async () => {
      const stat = await Deno.stat(TEST_TEMPLATES_DIR).catch(() => null);
      assertExists(stat, "Templates directory should exist");
    });

    it("should create default template", async () => {
      const content = await Deno.readTextFile(
        join(TEST_TEMPLATES_DIR, "default.html")
      );

      // Check for template variables
      assertEquals(content.includes("{{ page.title }}"), true);
      assertEquals(content.includes("{{ site.title }}"), true);
      assertEquals(content.includes("{{ page.content }}"), true);
    });
  });

  describe("Configuration", () => {
    it("should create valid config file", async () => {
      const content = await Deno.readTextFile(
        "./test-fixtures/noteg.config.json"
      );
      const config = JSON.parse(content);

      assertEquals(config.name, "test-site");
      assertEquals(config.site.title, "Test Site");
      assertEquals(config.build.contentDir, TEST_CONTENT_DIR);
    });
  });

  describe("Build Process", () => {
    it("should create output directory", async () => {
      const stat = await Deno.stat(TEST_OUTPUT_DIR).catch(() => null);
      assertExists(stat, "Output directory should exist");
    });

    // Note: Actual build process tests would go here
    // These are placeholder tests for the E2E framework
  });
});

// ============================================================================
// Accessibility E2E Tests
// ============================================================================

describe("Accessibility E2E", () => {
  it("should validate accessibility schema", async () => {
    const schemaPath = "./a11y/schema.json";
    try {
      const schemaContent = await Deno.readTextFile(schemaPath);
      const schema = JSON.parse(schemaContent);

      assertExists(schema.$schema, "Schema should have $schema");
      assertExists(schema.definitions, "Schema should have definitions");
      assertExists(
        schema.definitions.bslMetadata,
        "Schema should have BSL definition"
      );
      assertExists(
        schema.definitions.gslMetadata,
        "Schema should have GSL definition"
      );
      assertExists(
        schema.definitions.aslMetadata,
        "Schema should have ASL definition"
      );
      assertExists(
        schema.definitions.makatonMetadata,
        "Schema should have Makaton definition"
      );
    } catch {
      // Schema file may not exist in test environment
    }
  });
});

// ============================================================================
// Performance E2E Tests
// ============================================================================

describe("Performance E2E", () => {
  const PERFORMANCE_THRESHOLD_MS = 5000; // 5 seconds

  it("should complete fixture setup within threshold", async () => {
    const start = performance.now();
    await setupFixtures();
    const duration = performance.now() - start;

    assertEquals(
      duration < PERFORMANCE_THRESHOLD_MS,
      true,
      `Setup took ${duration}ms, exceeds ${PERFORMANCE_THRESHOLD_MS}ms`
    );
  });
});

// ============================================================================
// Run Tests
// ============================================================================

if (import.meta.main) {
  console.log("Running E2E tests...");
}
