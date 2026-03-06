# Security Policy

## Purpose

This document is the security operating guide for maintainers and AI agents working on Crit.

Crit is a hobby project maintained by one person, intended for single-user trusted environments. Security work is handled on a best-effort basis.

## Security Goals

- Prevent auth bypass and unauthorized repository access.
- Prevent command injection and path traversal.
- Prevent sensitive data exposure in responses and logs.
- Keep security logic minimal and auditable.

## Non-Goals

- Multi-user authorization and RBAC.
- Complex in-app policy engines.
- Enterprise compliance features.

## Supported Versions

Only the latest `main` branch is supported for security fixes.

| Version | Supported |
| --- | --- |
| `main` (latest) | :white_check_mark: |
| Older commits/releases | :x: |

## Trust Boundaries

- User credentials come from `CRIT_USER` and `CRIT_PASS`.
- Git operations are high risk because they may execute external binaries and touch filesystem paths.
- HTTP input is untrusted.
- Repository content (file names, refs, paths) is untrusted.

## Security-Critical Areas

- `src/helpers/auth.cr`
- `src/helpers/cgi_helper.cr`
- `src/routes/git.cr`
- `src/routes/web.cr`
- `src/services/repo_service.cr`
- `src/models/repository.cr`
- `Dockerfile`

Changes in these files should be treated as security-sensitive and reviewed carefully.

## Rules For AI Agents

- Do not weaken authentication checks.
- Do not add default credentials.
- Do not introduce shell command construction from raw user input.
- Do not trust path input; normalize and validate before filesystem access.
- Do not log credentials, tokens, or secrets.
- Do not enable insecure fallback behavior by default.
- Prefer small, isolated patches over broad refactors in security-sensitive code.

## Required Checks Before Merging

For any change touching auth, routing, git execution, path handling, or logging:

1. Confirm authentication still gates protected operations.
2. Confirm user-controlled paths/refs are validated.
3. Confirm no new command injection vector is introduced.
4. Confirm error messages do not leak sensitive internals.
5. Run tests (`crystal spec`) and ensure they pass.

If tests cannot run, explicitly note that in the PR.

## Deployment Baseline

- Run behind HTTPS (reverse proxy is acceptable).
- Restrict network exposure (VPN, allowlist, or internal network).
- Set strong `CRIT_USER` and `CRIT_PASS`.
- Keep `LOG_LEVEL=INFO` or stricter in production.
- Keep Git and container base images updated.
- For SSH-first operation, set `CRIT_GIT_HTTP_ENABLED=false`.

## Reporting A Vulnerability

Do not report vulnerabilities in public issues.

Use GitHub Security Advisories (`Security` tab -> `Report a vulnerability`). If unavailable, contact the repository owner privately with `[SECURITY]` in the subject.

Include affected area, reproduction steps, impact, and contact information.

## Response Process

Best-effort response only. No guaranteed response or fix timeline. Coordinated disclosure is preferred when a fix is available.
