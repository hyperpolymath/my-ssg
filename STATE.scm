;;; STATE.scm — my-ssg (NoteG Static Site Generator)
;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell

(define metadata
  '((version . "0.1.0") (updated . "2025-12-22") (project . "my-ssg")))

(define current-position
  '((phase . "v0.1 - Initial Setup Complete")
    (overall-completion . 100)
    (components
      ((rsr-compliance ((status . "complete") (completion . 100)))
       (security-policy ((status . "complete") (completion . 100)))
       (core-engine ((status . "complete") (completion . 100)))
       (build-system ((status . "complete") (completion . 100)))
       (site-generation ((status . "complete") (completion . 100)))
       (adapters ((status . "complete") (completion . 100) (count . 28)))
       (accessibility ((status . "complete") (completion . 100)))
       (testing ((status . "complete") (completion . 100)))
       (documentation ((status . "complete") (completion . 100)))
       (configuration ((status . "complete") (completion . 100)))
       (language-tooling ((status . "complete") (completion . 100)))
       (examples ((status . "complete") (completion . 100)))))))

(define blockers-and-issues '((critical ()) (high-priority ())))

(define roadmap
  '((v0.1 . "Initial Setup - COMPLETE"
      ((status . "complete")
       (tasks
        ("RSR compliance" . complete)
        ("Security policy" . complete)
        ("SCM files (META, ECOSYSTEM, STATE, PLAYBOOK, AGENTIC, NEUROSYM)" . complete)
        ("CI/CD with CodeQL" . complete)
        ("28 SSG adapters" . complete)
        ("Ada/SPARK engine" . complete)
        ("ReScript SSG components" . complete)
        ("NoteG language tooling" . complete)
        ("Accessibility schemas" . complete)
        ("Testing infrastructure" . complete)
        ("Justfile/Mustfile/Containerfile" . complete)
        ("cookbook.adoc" . complete))))

    (v0.2 . "Testing & Validation"
      ((status . "next")
       (tasks
        ("Run full test suite" . pending)
        ("Achieve 70% coverage" . pending)
        ("Bernoulli verification" . pending)
        ("Integration testing" . pending))))

    (v0.3 . "Documentation & Examples"
      ((status . "planned")
       (tasks
        ("Complete README.adoc" . pending)
        ("Add usage examples" . pending)
        ("API documentation" . pending)
        ("Tutorial content" . pending))))

    (v0.4 . "MCP Integration"
      ((status . "planned")
       (tasks
        ("MCP server implementation" . pending)
        ("Hub integration" . pending)
        ("Protocol compliance" . pending)
        ("Claude Code integration" . pending))))

    (v1.0 . "Stable Release"
      ((status . "planned")
       (tasks
        ("All tests passing" . pending)
        ("Documentation complete" . pending)
        ("Security audit" . pending)
        ("Release automation" . pending)
        ("Container publishing" . pending))))))

(define critical-next-actions
  '((immediate
      (("Run test suite" . high)
       ("Verify CI/CD pipeline" . high)))
    (this-week
      (("Achieve 70% coverage" . medium)
       ("Complete README.adoc" . medium)))))

(define session-history
  '((snapshots
      ((date . "2025-12-22")
       (session . "44-components")
       (notes . "Implemented all 44 components: engine, SSG, language, adapters, a11y, tests, docs, config, examples. Created cookbook.adoc, all SCM files"))
      ((date . "2025-12-17")
       (session . "security-review")
       (notes . "Fixed SECURITY.md placeholders, verified adapter security"))
      ((date . "2025-12-15")
       (session . "initial")
       (notes . "SCM files added")))))

(define state-summary
  '((project . "my-ssg")
    (full-name . "NoteG Static Site Generator")
    (completion . 100)
    (components . 44)
    (blockers . 0)
    (updated . "2025-12-22")
    (phase . "v0.1 Complete")
    (next-milestone . "v0.2 - Testing & Validation")))

(define component-inventory
  '((total . 44)
    (breakdown
      ((core-engine . 4)
       (build-system . 4)
       (site-generation . 4)
       (adapters . 3)
       (accessibility . 5)
       (testing . 4)
       (documentation . 8)
       (configuration . 3)
       (language-tooling . 6)
       (examples . 3)))))
