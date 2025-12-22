;;; STATE.scm — my-ssg (SSG Adapter Collection)
;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell

(define metadata
  '((version . "0.1.0") (updated . "2025-12-22") (project . "my-ssg")))

(define current-position
  '((phase . "v0.1 - Core Adapters Complete")
    (overall-completion . 85)
    (components
      ((rsr-compliance ((status . "complete") (completion . 100)))
       (security-policy ((status . "complete") (completion . 100)))
       (adapters ((status . "complete") (completion . 100) (count . 28)))
       (build-system ((status . "complete") (completion . 100)))
       (testing ((status . "in-progress") (completion . 60)))
       (documentation ((status . "in-progress") (completion . 70)))
       (ci-cd ((status . "complete") (completion . 100)))))))

(define blockers-and-issues '((critical ()) (high-priority ())))

(define roadmap
  '((v0.1 . "Core Adapters"
      ((status . "complete")
       (tasks
        ("RSR compliance" . complete)
        ("Security policy" . complete)
        ("SCM files (META, ECOSYSTEM, STATE)" . complete)
        ("28 SSG adapters" . complete)
        ("Justfile build system" . complete)
        ("Containerfile" . complete)
        ("CI/CD with CodeQL" . complete))))

    (v0.2 . "Testing & Validation"
      ((status . "next")
       (tasks
        ("Complete unit test suite" . in-progress)
        ("Achieve 70% coverage" . pending)
        ("Adapter interface validation" . pending)
        ("Security audit automation" . complete))))

    (v0.3 . "Hub Integration"
      ((status . "planned")
       (tasks
        ("poly-ssg-mcp hub connection" . pending)
        ("Adapter registration protocol" . pending)
        ("Version synchronization" . pending))))

    (v0.4 . "Documentation"
      ((status . "planned")
       (tasks
        ("Complete README" . pending)
        ("Adapter usage examples" . pending)
        ("Hub integration guide" . pending))))

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
      (("Complete test suite" . high)
       ("Verify adapter exports" . high)))
    (this-week
      (("Hub integration planning" . medium)
       ("Documentation improvements" . medium)))))

(define session-history
  '((snapshots
      ((date . "2025-12-22")
       (session . "scm-correction")
       (notes . "Fixed SCM files to correctly identify as adapter collection, not NoteG language"))
      ((date . "2025-12-17")
       (session . "security-review")
       (notes . "Fixed SECURITY.md placeholders, verified adapter security"))
      ((date . "2025-12-15")
       (session . "initial")
       (notes . "SCM files added, 28 adapters created")))))

(define state-summary
  '((project . "my-ssg")
    (full-name . "SSG Adapter Collection")
    (completion . 85)
    (adapters . 28)
    (blockers . 0)
    (updated . "2025-12-22")
    (phase . "v0.1 Complete")
    (next-milestone . "v0.2 - Testing & Validation")))
