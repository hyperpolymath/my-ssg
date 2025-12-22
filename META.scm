;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
;;; META.scm — my-ssg (NoteG Static Site Generator)

(define-module (my-ssg meta)
  #:export (architecture-decisions development-practices design-rationale
            component-architecture language-specification))

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
     (title . "Ada/SPARK Core Engine")
     (status . "accepted")
     (date . "2025-12-22")
     (context . "Need formally verified generation primitives")
     (decision . "Use Ada/SPARK for core engine with SPARK mode enabled")
     (consequences . ("Formal verification" "Type safety" "Memory safety" "Requires Ada toolchain")))

    (adr-003
     (title . "ReScript for SSG Logic")
     (status . "accepted")
     (date . "2025-12-22")
     (context . "Need type-safe JavaScript interop for Deno runtime")
     (decision . "Use ReScript for SSG components and language tooling")
     (consequences . ("Type safety" "JavaScript output" "Pattern matching" "Requires ReScript compiler")))

    (adr-004
     (title . "NoteG Custom Language")
     (status . "accepted")
     (date . "2025-12-22")
     (context . "Need powerful templating with functional programming features")
     (decision . "Create NoteG language with lexer, parser, interpreter, compiler, and LSP")
     (consequences . ("Custom syntax" "Editor support via LSP" "Compiles to JavaScript")))

    (adr-005
     (title . "MCP Protocol Integration")
     (status . "accepted")
     (date . "2025-12-22")
     (context . "Enable AI agent integration for content generation")
     (decision . "Implement MCP server with 28 SSG adapters")
     (consequences . ("AI-ready" "Tool ecosystem" "Standardized protocol")))

    (adr-006
     (title . "Accessibility First Design")
     (status . "accepted")
     (date . "2025-12-22")
     (context . "Ensure content is accessible to all users")
     (decision . "Support BSL, GSL, ASL, Makaton with JSON Schema validation")
     (consequences . ("WCAG compliance" "Sign language support" "Symbol-supported communication")))))

;; ============================================================================
;; Development Practices
;; ============================================================================

(define development-practices
  '((code-style
     (languages . ("Ada" "ReScript" "TypeScript" "JavaScript"))
     (formatter . "deno fmt")
     (linter . "deno lint"))

    (security
     (sast . "CodeQL")
     (credentials . "env vars only")
     (command-execution . "array-based args only")
     (audit . "weekly"))

    (testing
     (coverage-minimum . 70)
     (frameworks . ("Deno.test" "Ada AUnit"))
     (types . ("unit" "integration" "e2e" "bernoulli")))

    (versioning
     (scheme . "SemVer 2.0.0"))

    (documentation
     (format . "AsciiDoc")
     (required . ("README" "CONTRIBUTING" "SECURITY" "USER-GUIDE" "HANDOVER")))))

;; ============================================================================
;; Design Rationale
;; ============================================================================

(define design-rationale
  '((why-rsr
     "RSR ensures consistency, security, and maintainability across the hyperpolymath ecosystem.")

    (why-ada-spark
     "Ada/SPARK provides formal verification guarantees for safety-critical generation logic.")

    (why-rescript
     "ReScript offers type safety with seamless JavaScript interop for the Deno runtime.")

    (why-noteg-language
     "A custom language enables powerful templating while maintaining type safety and composability.")

    (why-mcp
     "MCP (Model Context Protocol) enables standardized AI agent integration for content generation.")

    (why-accessibility
     "First-class accessibility support ensures content reaches all users regardless of ability.")))

;; ============================================================================
;; Component Architecture (44/44 Complete)
;; ============================================================================

(define component-architecture
  '((core-engine (count . 4) (status . "complete")
     (components . ("Ada/SPARK Engine" "Mill-Based Synthesis" "Operation-Card Templating" "Variable Store")))

    (build-system (count . 4) (status . "complete")
     (components . ("Justfile" "Mustfile" "Containerfile" ".tool-versions")))

    (site-generation (count . 4) (status . "complete")
     (components . ("Content Processing" "Template Engine" "Output Generation" "Content Schema")))

    (adapters (count . 3) (status . "complete")
     (components . ("NoteG-MCP Server" "ReScript Adapter" "Deno Adapter"))
     (ssg-count . 28))

    (accessibility (count . 5) (status . "complete")
     (components . ("BSL Metadata" "GSL Metadata" "ASL Metadata" "Makaton Schema" "a11y/schema.json")))

    (testing (count . 4) (status . "complete")
     (components . ("Bernoulli Verification" "Unit Tests" "E2E Tests" "CI/CD Pipeline")))

    (documentation (count . 8) (status . "complete")
     (components . ("README" "Note G Original" "Grammar Analysis" "HANDOVER"
                    "POLY-SSG-TEMPLATE" "Module READMEs" "USER-GUIDE" "Language Spec")))

    (configuration (count . 3) (status . "complete")
     (components . ("Site Config Schema" "Example Config" "Environment Handling")))

    (language-tooling (count . 6) (status . "complete")
     (components . ("Lexer" "Parser" "Interpreter" "Compiler" "Syntax Highlighting" "LSP")))

    (examples (count . 3) (status . "complete")
     (components . ("Example Content" "Example Templates" "Example Config")))))

;; ============================================================================
;; Language Specification
;; ============================================================================

(define language-specification
  '((name . "NoteG")
    (version . "0.1.0")
    (paradigm . "functional")
    (typing . "static-inferred")

    (features
     ((variables . "let/const bindings")
      (functions . "first-class lambdas")
      (operators . "arithmetic, comparison, logical, pipe")
      (templates . "{{ expr }} interpolation")
      (pattern-matching . "match expressions")
      (modules . "import/export")))

    (syntax-highlights
     ((keywords . ("let" "const" "fn" "if" "then" "else" "match" "with" "type" "module" "import" "export"))
      (literals . ("strings" "numbers" "booleans" "null" "arrays" "records"))
      (operators . ("+" "-" "*" "/" "%" "==" "!=" "<" "<=" ">" ">=" "&&" "||" "!" "|>" "->" "=>"))))))
