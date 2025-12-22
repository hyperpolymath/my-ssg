;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
;; ECOSYSTEM.scm — my-ssg (SSG Adapter Collection)

(define-module (my-ssg ecosystem)
  #:export (ecosystem-position related-projects integration-points))

(ecosystem
  (version "1.0.0")
  (name "my-ssg")
  (full-name "SSG Adapter Collection")
  (type "satellite-project")
  (purpose "28 SSG adapters providing MCP-compatible interface for AI integration")

  (position-in-ecosystem
    "Satellite implementation in the hyperpolymath ecosystem.
     Provides 28 SSG adapters for poly-ssg-mcp hub.
     Follows RSR guidelines for quality and consistency.")

  (related-projects
    (project
      (name "poly-ssg-mcp")
      (url "https://github.com/hyperpolymath/poly-ssg-mcp")
      (relationship "hub")
      (description "Unified MCP server for SSGs - consumes these adapters")
      (integration-type "adapter-provider"))

    (project
      (name "rhodium-standard-repositories")
      (url "https://github.com/hyperpolymath/rhodium-standard-repositories")
      (relationship "standard")
      (description "Repository quality guidelines"))

    (project
      (name "claude-code")
      (relationship "tooling")
      (description "AI coding assistant integration via MCP"))

    (project
      (name "model-context-protocol")
      (url "https://modelcontextprotocol.io")
      (relationship "protocol")
      (description "Standard protocol for AI tool integration")))

  (what-this-is
    "my-ssg is an SSG adapter collection providing:
     - 28 JavaScript/Deno adapters wrapping SSGs
     - MCP-compatible tool interface for each adapter
     - Secure command execution (array-based args only)
     - Multi-language SSG support (Rust, Haskell, Elixir, Julia, etc.)")

  (what-this-is-not
    "- NOT a static site generator itself (wraps existing SSGs)
     - NOT the NoteG language project (that is a separate repo)
     - NOT exempt from RSR compliance
     - NOT dependent on any specific AI model"))

;; ============================================================================
;; SSG Adapters (28 total)
;; ============================================================================

(define adapters
  '((rust ("zola" "cobalt" "mdbook"))
    (haskell ("hakyll" "ema"))
    (elixir ("serum" "tableau" "nimble-publisher"))
    (julia ("franklin" "publish" "documenter" "staticwebpages"))
    (scala ("laika" "scalatex"))
    (ocaml ("yocaml"))
    (clojure ("perun" "cryogen"))
    (lisp ("frog" "coleslaw"))
    (erlang ("zotonic"))
    (nim ("nimrod"))
    (racket ("pollen" "frog"))
    (java ("orchid"))
    (babashka ("babashka"))
    (other ("marmot" "reggae" "fornax" "wub"))))

;; ============================================================================
;; Integration Points
;; ============================================================================

(define integration-points
  '((mcp-protocol
     (role . "adapter provider")
     (capabilities . ("tools" "prompts"))
     (adapters . 28)
     (protocol-version . "2024-11-05"))

    (ci-cd
     (platform . "GitHub Actions")
     (workflows . ("ci" "codeql"))
     (container-registry . "ghcr.io"))))

;; ============================================================================
;; Dependency Tree
;; ============================================================================

(define dependencies
  '((runtime
     (deno . "2.1.4")
     (description . "JavaScript/TypeScript runtime"))

    (build
     (just . "1.36.0")
     (description . "Task runner"))

    (container
     (podman . "5.3.0")
     (description . "Container runtime (optional)"))))
