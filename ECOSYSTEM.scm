;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
;; ECOSYSTEM.scm — my-ssg (NoteG Static Site Generator)

(define-module (my-ssg ecosystem)
  #:export (ecosystem-position related-projects integration-points))

(ecosystem
  (version "1.0.0")
  (name "my-ssg")
  (full-name "NoteG Static Site Generator")
  (type "satellite-project")
  (purpose "Static site generation with MCP integration and accessibility-first design")

  (position-in-ecosystem
    "Satellite implementation in the hyperpolymath ecosystem.
     Integrates with poly-ssg-mcp hub for unified SSG access.
     Follows RSR guidelines for quality and consistency.")

  (related-projects
    (project
      (name "poly-ssg-mcp")
      (url "https://github.com/hyperpolymath/poly-ssg-mcp")
      (relationship "hub")
      (description "Unified MCP server for 28 SSGs - provides adapter interface")
      (integration-type "adapter-consumer"))

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
    "NoteG is a static site generator featuring:
     - Ada/SPARK formally verified core engine
     - Custom NoteG templating language
     - 28 SSG adapters via MCP protocol
     - First-class accessibility support (BSL, GSL, ASL, Makaton)
     - Neurosymbolic architecture for hybrid AI reasoning")

  (what-this-is-not
    "- NOT a replacement for existing SSGs (wraps them via MCP)
     - NOT exempt from RSR compliance
     - NOT a CMS (generates static files only)
     - NOT dependent on any specific AI model"))

;; ============================================================================
;; Integration Points
;; ============================================================================

(define integration-points
  '((mcp-protocol
     (role . "MCP server provider")
     (capabilities . ("tools" "prompts" "resources"))
     (adapters . 28)
     (protocol-version . "2024-11-05"))

    (editor-integration
     (lsp . "NoteG Language Server")
     (editors . ("VSCode" "Neovim" "Emacs"))
     (features . ("completion" "hover" "diagnostics" "formatting")))

    (ci-cd
     (platform . "GitHub Actions")
     (workflows . ("ci" "codeql" "release"))
     (container-registry . "ghcr.io"))

    (accessibility-standards
     (wcag . "2.1 AA target")
     (sign-languages . ("BSL" "GSL" "ASL"))
     (aac . ("Makaton")))))

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

    (optional
     (gnat . "2024")
     (description . "Ada compiler for engine")
     (nodejs . "22.12.0")
     (description . "For ReScript compilation"))

    (development
     (asciidoctor . "2.0.23")
     (nickel . "1.8.0"))))
