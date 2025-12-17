;;; STATE.scm — my-ssg
;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell

(define metadata
  '((version . "0.1.0") (updated . "2025-12-17") (project . "my-ssg")))

(define current-position
  '((phase . "v0.1 - Initial Setup")
    (overall-completion . 35)
    (components
      ((rsr-compliance ((status . "complete") (completion . 100)))
       (security-policy ((status . "complete") (completion . 100)))
       (adapters ((status . "in-progress") (completion . 100) (note . "27 SSG adapters implemented")))
       (testing ((status . "pending") (completion . 0)))
       (documentation ((status . "pending") (completion . 10)))))))

(define blockers-and-issues '((critical ()) (high-priority ())))

(define roadmap
  '((v0.1 . "Initial Setup - CURRENT"
      ((tasks
        ("RSR compliance" . complete)
        ("Security policy" . complete)
        ("SCM files (META, ECOSYSTEM, STATE)" . complete)
        ("CI/CD with CodeQL" . complete)
        ("27 SSG adapters" . complete))))
    (v0.2 . "Testing & Validation"
      ((tasks
        ("Unit tests for adapters" . pending)
        ("Integration tests" . pending)
        ("Deno test runner setup" . pending)
        ("Coverage reporting (70% target)" . pending))))
    (v0.3 . "Documentation & Examples"
      ((tasks
        ("README.adoc completion" . pending)
        ("API documentation" . pending)
        ("Usage examples per SSG" . pending)
        ("Contributing guide completion" . pending))))
    (v0.4 . "MCP Integration"
      ((tasks
        ("MCP server implementation" . pending)
        ("Hub integration with poly-ssg-mcp" . pending)
        ("Protocol compliance testing" . pending))))
    (v1.0 . "Stable Release"
      ((tasks
        ("All tests passing" . pending)
        ("Documentation complete" . pending)
        ("Security audit" . pending)
        ("Release automation" . pending))))))

(define critical-next-actions
  '((immediate
      (("Add unit tests for adapters" . high)
       ("Complete README.adoc" . medium)))
    (this-week
      (("Set up Deno test runner" . high)
       ("Add integration tests" . medium)))))

(define session-history
  '((snapshots
      ((date . "2025-12-17")
       (session . "security-review")
       (notes . "Fixed SECURITY.md placeholders, verified adapter security (no injection vulnerabilities), updated roadmap"))
      ((date . "2025-12-15")
       (session . "initial")
       (notes . "SCM files added")))))

(define state-summary
  '((project . "my-ssg")
    (completion . 35)
    (blockers . 0)
    (updated . "2025-12-17")
    (next-milestone . "v0.2 - Testing & Validation")))
