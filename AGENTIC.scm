;;; AGENTIC.scm — my-ssg
;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
;; Agentic AI Configuration for NoteG SSG

(define-module (my-ssg agentic)
  #:export (agent-config capabilities constraints tools))

;; ============================================================================
;; Agent Configuration
;; ============================================================================

(define agent-config
  '((name . "NoteG Agent")
    (version . "0.1.0")
    (description . "Agentic AI for static site generation and content management")
    (protocol . "MCP")  ; Model Context Protocol

    (identity
      ((role . "site-generator")
       (domain . "static-sites")
       (expertise . ("content-processing" "template-rendering" "accessibility"))))

    (behavior
      ((autonomy-level . "supervised")    ; supervised | semi-autonomous | autonomous
       (confirmation-required . ("delete" "publish" "deploy"))
       (retry-on-failure . #t)
       (max-retries . 3)
       (timeout-seconds . 300)))))

;; ============================================================================
;; Capabilities
;; ============================================================================

(define capabilities
  '((content-management
      ((create-page . #t)
       (edit-page . #t)
       (delete-page . #t)
       (organize-content . #t)
       (manage-assets . #t)))

    (generation
      ((build-site . #t)
       (preview-changes . #t)
       (validate-output . #t)
       (optimize-assets . #t)))

    (template-operations
      ((create-template . #t)
       (modify-template . #t)
       (apply-template . #t)
       (validate-template . #t)))

    (accessibility
      ((validate-a11y . #t)
       (generate-alt-text . #t)
       (create-transcripts . #f)  ; Requires human review
       (wcag-audit . #t)))

    (language-tooling
      ((parse-noteg . #t)
       (compile-noteg . #t)
       (interpret-noteg . #t)
       (lint-noteg . #t)))

    (adapter-operations
      ((list-adapters . #t)
       (invoke-adapter . #t)
       (configure-adapter . #t)))))

;; ============================================================================
;; Constraints
;; ============================================================================

(define constraints
  '((security
      ((no-credential-access . #t)
       (no-external-network . #t)  ; Except whitelisted domains
       (no-system-commands . #t)   ; Only predefined commands
       (sandboxed-execution . #t)
       (audit-logging . #t)))

    (content
      ((max-file-size-mb . 50)
       (allowed-extensions . (".md" ".noteg" ".html" ".css" ".js" ".json" ".yaml"))
       (forbidden-patterns . ("password" "secret" "api_key" "token"))
       (content-policy . "rsr-compliant")))

    (resources
      ((max-memory-mb . 1024)
       (max-cpu-time-s . 300)
       (max-files-per-operation . 100)
       (max-concurrent-operations . 5)))

    (rate-limits
      ((requests-per-minute . 60)
       (builds-per-hour . 10)
       (file-operations-per-minute . 100)))))

;; ============================================================================
;; MCP Tools
;; ============================================================================

(define tools
  '((site-tools
      ((name . "noteg_build")
       (description . "Build the static site")
       (input-schema
         ((type . "object")
          (properties
            ((clean . ((type . "boolean") (default . #f)))
             (verbose . ((type . "boolean") (default . #f)))))))
       (requires . ("content" "templates")))

      ((name . "noteg_serve")
       (description . "Start development server")
       (input-schema
         ((type . "object")
          (properties
            ((port . ((type . "number") (default . 8080)))
             (host . ((type . "string") (default . "localhost")))))))
       (long-running . #t))

      ((name . "noteg_validate")
       (description . "Validate site configuration and content")
       (input-schema
         ((type . "object")
          (properties
            ((strict . ((type . "boolean") (default . #t))))))))

    (content-tools
      ((name . "content_create")
       (description . "Create new content file")
       (input-schema
         ((type . "object")
          (properties
            ((title . ((type . "string") (required . #t)))
             (template . ((type . "string") (default . "default")))
             (path . ((type . "string")))))))
       (confirmation . #f))

      ((name . "content_list")
       (description . "List all content files")
       (input-schema
         ((type . "object")
          (properties
            ((filter . ((type . "string")))
             (sort . ((type . "string") (enum . ("date" "title" "path"))))))))
       (read-only . #t))

      ((name . "content_delete")
       (description . "Delete a content file")
       (input-schema
         ((type . "object")
          (properties
            ((path . ((type . "string") (required . #t)))))))
       (confirmation . #t)
       (dangerous . #t)))

    (language-tools
      ((name . "noteg_parse")
       (description . "Parse NoteG source and return AST")
       (input-schema
         ((type . "object")
          (properties
            ((source . ((type . "string") (required . #t)))))))
       (read-only . #t))

      ((name . "noteg_compile")
       (description . "Compile NoteG source to JavaScript")
       (input-schema
         ((type . "object")
          (properties
            ((source . ((type . "string") (required . #t)))
             (target . ((type . "string") (default . "es2022"))))))))

      ((name . "noteg_interpret")
       (description . "Interpret NoteG source directly")
       (input-schema
         ((type . "object")
          (properties
            ((source . ((type . "string") (required . #t))))))))

    (accessibility-tools
      ((name . "a11y_validate")
       (description . "Validate accessibility compliance")
       (input-schema
         ((type . "object")
          (properties
            ((path . ((type . "string")))
             (wcag-level . ((type . "string") (enum . ("A" "AA" "AAA"))))))))
       (read-only . #t))

      ((name . "a11y_report")
       (description . "Generate accessibility report")
       (input-schema
         ((type . "object")
          (properties
            ((format . ((type . "string") (enum . ("html" "json" "markdown"))))))))
       (read-only . #t))))))

;; ============================================================================
;; Prompt Templates
;; ============================================================================

(define prompts
  '((system . "You are NoteG Agent, an AI assistant for static site generation.
You help users create, manage, and deploy static websites using the NoteG SSG.
You have access to MCP tools for content management, site building, and accessibility validation.
Always follow RSR (Rhodium Standard Repository) guidelines.
Prioritize accessibility and security in all operations.")

    (content-creation . "Create a new {{type}} with title '{{title}}'.
Use the {{template}} template and ensure WCAG {{wcag-level}} compliance.")

    (build . "Build the site with the following options:
- Clean build: {{clean}}
- Verbose output: {{verbose}}
Report any errors or warnings.")

    (accessibility-check . "Validate accessibility for {{path}}.
Check against WCAG {{wcag-level}} guidelines.
Report any issues with severity and suggested fixes.")))

;; ============================================================================
;; Integration Points
;; ============================================================================

(define integrations
  '((mcp-server
      ((endpoint . "stdio")
       (protocol-version . "2024-11-05")
       (capabilities . ("tools" "prompts" "resources"))))

    (editor-integration
      ((vscode . #t)
       (neovim . #t)
       (emacs . #t)
       (protocol . "lsp")))

    (ci-integration
      ((github-actions . #t)
       (webhook-support . #f)))))
