;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
;;; META.scm — my-ssg (SSG Adapter Collection)

(define-module (my-ssg meta)
  #:export (architecture-decisions development-practices design-rationale))

;; ============================================================================
;; Architecture Decision Records
;; ============================================================================

(define architecture-decisions
  '((adr-001
     (title . "RSR Compliance")
     (status . "accepted")
     (date . "2025-12-15")
     (context . "Project in the hyperpolymath ecosystem")
     (decision . "Follow Rhodium Standard Repository guidelines")
     (consequences . ("RSR Gold target" "SHA-pinned actions" "SPDX headers" "Multi-platform CI")))

    (adr-002
     (title . "Deno Runtime")
     (status . "accepted")
     (date . "2025-12-15")
     (context . "Need lightweight runtime for SSG adapters")
     (decision . "Use Deno for all adapter implementations")
     (consequences . ("Type safety" "Security sandbox" "No node_modules" "Built-in testing")))

    (adr-003
     (title . "Array-Based Command Execution")
     (status . "accepted")
     (date . "2025-12-15")
     (context . "Adapters execute external SSG commands")
     (decision . "Use Deno.Command with array-based args only, never shell: true")
     (consequences . ("No shell injection" "Command sanitization" "Explicit arguments")))

    (adr-004
     (title . "MCP Protocol Integration")
     (status . "accepted")
     (date . "2025-12-17")
     (context . "Enable AI agent integration for SSG operations")
     (decision . "Each adapter exposes tools via MCP-compatible interface")
     (consequences . ("AI-ready" "Tool ecosystem" "Standardized protocol")))

    (adr-005
     (title . "Satellite Project Pattern")
     (status . "accepted")
     (date . "2025-12-17")
     (context . "Need modular SSG support for poly-ssg-mcp hub")
     (decision . "Implement as satellite providing 28 adapters to hub")
     (consequences . ("Loose coupling" "Independent versioning" "Hub integration")))))

;; ============================================================================
;; Development Practices
;; ============================================================================

(define development-practices
  '((code-style
     (languages . ("JavaScript"))
     (formatter . "deno fmt")
     (linter . "deno lint"))

    (security
     (sast . "CodeQL")
     (credentials . "env vars only")
     (command-execution . "array-based args only")
     (audit . "just audit"))

    (testing
     (coverage-minimum . 70)
     (frameworks . ("Deno.test"))
     (types . ("unit" "integration")))

    (versioning
     (scheme . "SemVer 2.0.0"))

    (documentation
     (format . "Markdown/AsciiDoc")
     (required . ("README" "CONTRIBUTING" "SECURITY")))))

;; ============================================================================
;; Design Rationale
;; ============================================================================

(define design-rationale
  '((why-rsr
     "RSR ensures consistency, security, and maintainability across the hyperpolymath ecosystem.")

    (why-deno
     "Deno provides security sandbox, TypeScript support, and built-in testing for adapter development.")

    (why-adapters
     "Adapters allow uniform MCP interface across diverse SSG implementations in different languages.")

    (why-mcp
     "MCP (Model Context Protocol) enables standardized AI agent integration for content generation.")

    (why-satellite
     "Satellite pattern allows independent development while integrating with poly-ssg-mcp hub.")))
