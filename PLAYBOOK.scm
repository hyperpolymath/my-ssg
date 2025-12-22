;;; PLAYBOOK.scm — my-ssg
;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
;; Operational Playbook for NoteG SSG

(define-module (my-ssg playbook)
  #:export (operations runbooks emergency-procedures))

;; ============================================================================
;; Operations Configuration
;; ============================================================================

(define operations
  '((service-name . "my-ssg")
    (type . "static-site-generator")
    (criticality . "medium")
    (sla
      ((availability . 99.9)
       (response-time-ms . 500)
       (build-time-max-s . 300)))

    (monitoring
      ((health-endpoint . "/health")
       (metrics-endpoint . "/metrics")
       (logging
         ((level . "info")
          (format . "json")
          (retention-days . 30)))))

    (alerting
      ((channels . ("slack" "email"))
       (thresholds
         ((build-failure . "critical")
          (test-failure . "high")
          (coverage-drop . "medium")))))))

;; ============================================================================
;; Standard Operating Procedures
;; ============================================================================

(define runbooks
  '((deployment
      ((name . "Standard Deployment")
       (trigger . "git push to main")
       (steps
         (("Checkout code" . "git checkout $BRANCH")
          ("Install deps" . "asdf install")
          ("Run tests" . "just test-all")
          ("Build" . "just build")
          ("Deploy" . "just deploy")))
       (rollback . "git revert HEAD && just deploy")))

    (hotfix
      ((name . "Emergency Hotfix")
       (trigger . "critical bug in production")
       (steps
         (("Create hotfix branch" . "git checkout -b hotfix/$ISSUE main")
          ("Apply fix" . "# make changes")
          ("Fast test" . "just test-unit")
          ("Merge to main" . "git checkout main && git merge hotfix/$ISSUE")
          ("Deploy" . "just deploy")
          ("Cleanup" . "git branch -d hotfix/$ISSUE")))
       (approval-required . #t)))

    (security-update
      ((name . "Security Patch")
       (trigger . "CVE notification or Dependabot alert")
       (steps
         (("Assess severity" . "Review CVE details")
          ("Update dependencies" . "# update package versions")
          ("Run security scan" . "just audit")
          ("Run tests" . "just test-all")
          ("Deploy" . "just deploy")))
       (sla-hours . 24)))

    (release
      ((name . "Version Release")
       (trigger . "Manual or scheduled")
       (steps
         (("Version bump" . "just release-$TYPE")
          ("Generate changelog" . "just changelog")
          ("Create tag" . "git tag v$VERSION")
          ("Push" . "git push --follow-tags")
          ("Build container" . "just container-build")
          ("Push container" . "just container-push")))
       (artifacts . ("container-image" "source-tarball"))))))

;; ============================================================================
;; Emergency Procedures
;; ============================================================================

(define emergency-procedures
  '((build-failure
      ((severity . "high")
       (symptoms . ("CI pipeline fails" "Build command returns non-zero"))
       (diagnosis
         (("Check logs" . "just build 2>&1 | tee build.log")
          ("Identify failing component" . "grep -i error build.log")
          ("Check dependencies" . "asdf current")))
       (resolution
         (("Fix syntax errors" . "Review error messages")
          ("Update dependencies" . "asdf install")
          ("Clear cache" . "just clean")))
       (escalation . "Open GitHub issue with build.log")))

    (test-failure
      ((severity . "high")
       (symptoms . ("Test suite fails" "Coverage drops below threshold"))
       (diagnosis
         (("Run failing tests" . "just test-unit")
          ("Check test output" . "Review assertion failures")
          ("Verify fixtures" . "Check test data")))
       (resolution
         (("Fix broken tests" . "Update test expectations")
          ("Fix code bugs" . "Debug and patch")
          ("Update mocks" . "Sync with API changes")))
       (escalation . "Tag maintainer in PR")))

    (security-incident
      ((severity . "critical")
       (symptoms . ("CVE reported" "Vulnerability discovered" "Breach detected"))
       (immediate-actions
         (("Isolate" . "Disable affected features")
          ("Assess" . "Determine scope of impact")
          ("Notify" . "Contact security team")))
       (resolution
         (("Patch" . "Apply security fix")
          ("Verify" . "Run security scan")
          ("Document" . "Update SECURITY.md")))
       (post-incident
         (("Review" . "Conduct post-mortem")
          ("Improve" . "Update procedures")
          ("Communicate" . "Publish advisory")))))

    (dependency-conflict
      ((severity . "medium")
       (symptoms . ("Version mismatch" "Import errors" "Type errors"))
       (diagnosis
         (("Check versions" . "cat .tool-versions")
          ("List deps" . "deno info")
          ("Find conflicts" . "deno check")))
       (resolution
         (("Update .tool-versions" . "Pin correct versions")
          ("Clear cache" . "deno cache --reload")
          ("Reinstall" . "asdf install")))))))

;; ============================================================================
;; On-Call Procedures
;; ============================================================================

(define on-call
  '((schedule
      ((rotation . "weekly")
       (handoff-day . "monday")
       (handoff-time . "09:00 UTC")))

    (responsibilities
      (("Monitor alerts" . "Check Slack/email")
       ("Triage issues" . "Assign severity")
       ("First response" . "Acknowledge within 15min")
       ("Escalate" . "If unable to resolve within SLA")))

    (tools
      (("Alerting" . "GitHub Actions notifications")
       ("Logging" . "GitHub Actions logs")
       ("Communication" . "GitHub Discussions")))))

;; ============================================================================
;; Maintenance Windows
;; ============================================================================

(define maintenance
  '((scheduled
      ((frequency . "monthly")
       (day . "first-saturday")
       (time . "02:00-04:00 UTC")
       (activities
         (("Dependency updates" . "Run Dependabot PRs")
          ("Security patches" . "Apply CVE fixes")
          ("Performance review" . "Analyze metrics")))))

    (communication
      ((advance-notice-days . 7)
       (channels . ("github-discussions" "readme-banner"))))))
