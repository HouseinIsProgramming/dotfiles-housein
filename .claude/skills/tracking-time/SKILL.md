---
name: tracking-time
description:
  Log worked time in TrackingTime for GitHub issues in this repo. Use when the
  user wants to track, log, or book time for a ticket/issue/PR, reconstruct how
  long they worked on something, or fill in their timesheet. Triggers on "track
  time", "log time", "book hours", "time tracking", "timesheet", or
  "tracking-time".
metadata:
  author: elevantiq
  version: '1.0.0'
---

# TrackingTime — Log Time for GitHub Issues

Log worked time in TrackingTime, mapped from GitHub issues in
`feddersen-group/feddersen-monorepo`. Every project has a `project:*` label on
its GitHub issues and a corresponding project in TrackingTime.

## Prerequisites

- The TrackingTime MCP server, installed **per user** (not committed to the
  repo). Generate an App Password in TrackingTime → Settings → Apps &
  Integrations → App Passwords, then add the server to your user scope:

  ```bash
  claude mcp add --scope user --transport http trackingtime \
    https://mcp.trackingtime.co/mcp \
    --header "X-API-Key: <your-app-password>"
  ```

  If the `trackingtime` MCP tools are not available, stop and tell the user to
  install it with the command above.
- `gh` CLI authenticated for the repo.

## Important: account_id

All TrackingTime MCP list/query tools need `account_id: 477392` (the shared
workspace). Without it, `list_workspaces` returns empty and other tools fail
with "The action you requested doesn't exist".

## Project Mapping

GitHub issues carry a `project:*` label mapping to a TrackingTime project:

| GitHub label | TrackingTime project | ID |
|--------------|----------------------|-----|
| `project:akrp` | AKRO - Customer Portal | 1868656 |
| `project:akrw` | _(no TrackingTime project yet — ask the user)_ | — |
| `project:cop` | CO - Customer Portal | 2350426 |
| `project:cow` | CO - Website | 2350427 |
| `project:fmbp` | HOL - Multi Brand Portal | 2002470 |
| `project:fmbw` | Feddersen: Multi Brand Websites | 1871032 |
| `project:fdoc` | HOL - Feddersen.Docs | 2350405 |
| `project:afcw` | AFC - Website | 2210312 |
| `project:stfw` | STFG - Website | 2350547 |
| `project:fedw` | FED - Website | 2229366 |

Caution: TrackingTime contains similarly-named duplicate projects (e.g. both
"Feddersen: Multi Brand Websites" and an unused "HOL - Multi Brand Websites").
When in doubt, check which project has recent time entries (`list_events` with
`filter: PROJECT`) — book where the team actually books. Verify the ID still
exists via `list_projects` (with `account_id`) before logging. For labels not in this table, list projects and match by the label
description (`gh label list --search "project:"` descriptions mirror the
TrackingTime project names). If no match is found, show the user the available
projects and ask — never guess or create a new project without confirmation.

## Workflow

### 1. Identify the issue and project

- If the user names an issue/PR, fetch it: `gh issue view <n> --json title,labels,url`
- If they describe work loosely ("the time I spent on the checkout bug"),
  search: `gh issue list --search "..." --state all`
- Read the `project:*` label → resolve the TrackingTime project (table above).
- **Multiple labels / cross-tenant work**: portal work for both AKRO and CO →
  book to FMBP.