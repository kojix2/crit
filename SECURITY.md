# Security Policy

## Security Model

Crit is designed for a single trusted user and a minimal codebase.

Security strategy:

- Keep application-side security logic small.
- Delegate as much as possible to proven external tools and infrastructure.
- Prefer operational controls over in-app complexity.

## Supported Versions

Security fixes are provided for the latest code on `main`.

| Version | Supported |
| --- | --- |
| `main` (latest) | :white_check_mark: |
| Older commits/releases | :x: |

## Reporting a Vulnerability

Please do not report security issues in public GitHub issues.

Use one of the following private channels:

1. GitHub Security Advisories (preferred):
   - Go to the repository `Security` tab.
   - Click `Report a vulnerability`.
2. If the Security tab is unavailable, open a private contact request through the repository owner profile and include `[SECURITY]` in the subject.

Include as much detail as possible:

- Affected endpoint(s) or file(s)
- Reproduction steps / proof of concept
- Impact assessment
- Suggested mitigation (optional)
- Your contact information for follow-up

## Response Process

- Initial acknowledgment target: within 72 hours
- Triage and severity assessment target: within 7 days
- Fix timeline: depends on severity and complexity
- Coordinated disclosure: preferred after a fix is available

## Scope

In scope:

- Authentication and authorization bypass
- Command injection / path traversal
- Cross-site scripting (XSS)
- CSRF and session-related flaws
- Data exposure via logs or responses

Out of scope (unless chained with a security impact):

- Purely cosmetic issues
- Missing best-practice headers without exploitability details
- Denial of service requiring unrealistic resources

Not planned by design (for this project model):

- Multi-user authorization and RBAC
- Complex in-app policy engines
- Large custom security middleware layers

## Secure Deployment Guidance

This project is intended to be deployed behind standard infrastructure controls.

Recommended minimal stack:

- Reverse proxy for TLS termination and access control
- Network restriction (local network, VPN, or allowlist)
- Strong credentials in environment variables

- Always run behind HTTPS (TLS termination at a reverse proxy is acceptable).
- Set strong, unique values for `CRIT_USER` and `CRIT_PASS`.
- Do not use default credentials in any non-local environment.
- Restrict network access to trusted users (VPN, allowlists, or internal network).
- Set `LOG_LEVEL=INFO` or stricter in production to reduce sensitive debug logging.
- Keep Git and container base images up to date.

## Minimal Security Checklist

- Change `CRIT_USER` and `CRIT_PASS` before first non-local start.
- Place Crit behind HTTPS at a reverse proxy.
- Do not expose the service directly to the public Internet.
- Keep `LOG_LEVEL` at `INFO` or higher in production.
- Update base images and Git periodically.

## Disclosure and Credit

We support responsible disclosure. If you would like public credit after a fix is released, mention this in your report.
