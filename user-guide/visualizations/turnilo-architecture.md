---
title: Turnilo Architecture
section: user-guide
category: visualizations
order: 12
toc: true
keywords:
  - Turnilo
  - architecture
  - Plywood
  - Docker
  - integration
  - widget
description: "Technical architecture of DataReporter's Turnilo integration including Plywood backend, Docker services, and dashboard widget embedding."
---

## Turnilo Architecture

DataReporter runs a hardforked version of [Turnilo](https://github.com/allegro/turnilo) (v1.40.5) as an embedded component. This page describes the technical architecture.

### High-Level Architecture

```
┌─────────────────────────────────────────────────┐
│                DataReporter UI                   │
│  ┌──────────────┐  ┌─────────────────────────┐  │
│  │  Dashboards   │  │  TurniloWidget.jsx      │  │
│  │  (React)      │──│  TurniloApplication.ts  │  │
│  └──────────────┘  └────────────┬────────────┘  │
│                                  │               │
│  Webpack Proxy: /plywood/* ──────┘               │
│  Webpack Proxy: /config-turnilo ─┘               │
└─────────────────────┬───────────────────────────┘
                      │ HTTP
┌─────────────────────▼───────────────────────────┐
│           Plywood Backend (port 3000)            │
│  ┌──────────────────────────────────────────┐   │
│  │  Express Server (app.ts / server.ts)     │   │
│  │  ├── /config-turnilo                     │   │
│  │  ├── /api/v1/plywood (query executor)    │   │
│  │  ├── /api/v1/plywood/attributes          │   │
│  │  └── /api/v1/plywood/hash-to-filter      │   │
│  └──────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────┐   │
│  │  Attribute Parsers                        │   │
│  │  PostgreSQL │ MySQL │ BigQuery │ Athena   │   │
│  │  Druid │ JSON                             │   │
│  └──────────────────────────────────────────┘   │
└─────────────────────┬───────────────────────────┘
                      │ SQL / Native
              ┌───────▼───────┐
              │  Data Sources  │
              │  (PostgreSQL,  │
              │   BigQuery,    │
              │   Druid, etc.) │
              └───────────────┘
```

### Component Details

#### Hardforked Turnilo (Client)

**Location:** `client/app/components/TurniloComponent/`

DataReporter embeds a customized fork of Turnilo's frontend as a React component. The fork includes:

- **Widget mode** (`turnilo-application-widget.ts`) — Renders inside dashboard grid cells
- **Full page mode** (`turnilo-application.ts`) — Used in the report/explore page
- **Common models** — Data cube, dimension, measure, filter, split, series, and timekeeper models
- **Visualization manifests** — Bar chart, line chart, table, totals, heat map

Key files:

| File | Purpose |
|------|---------|
| `client/applications/turnilo-application.ts` | Full-page Turnilo app |
| `client/applications/turnilo-application-widget.ts` | Dashboard widget mode |
| `common/models/app-settings/app-settings.ts` | Application configuration model |
| `common/models/essence/essence.ts` | Query state (filters, splits, measures) |
| `common/models/data-cube/` | Data cube definitions |

#### Plywood Backend

**Location:** `plywood/`

A standalone Node.js (v14.17.0) Express server that:

1. Serves configuration via `/config-turnilo`
2. Translates Turnilo's Plywood expressions into backend-specific queries
3. Executes queries against configured data sources
4. Returns formatted results to the Turnilo frontend

**Docker service:** Runs as the `plywood` service in Docker Compose on port 3000.

**Dockerfile:** Based on `node:14.17.0-alpine`, runs as non-root `plywood` user.

#### Webpack Proxy

**Location:** `client/webpack.config.js`

In development, the webpack dev server proxies Turnilo-related requests:

```javascript
{
  context: ["/plywood", "/config-turnilo"],
  target: turniloBackend + "/",  // default: http://localhost:3000
  changeOrigin: true,
  secure: false,
}
```

The `TURNILO_BACKEND` environment variable controls the proxy target (default: `http://localhost:3000`).

### Dashboard Widget Integration

Turnilo visualizations embed in DataReporter dashboards as widgets.

#### Widget Identification

A widget is identified as a Turnilo widget when its `text` field contains the `[turnilo-widget]` marker. The widget service (`client/app/services/widget.js`) detects this and routes rendering to `TurniloWidget.jsx`.

#### State Management

Each Turnilo widget stores its state as a hash:

- **Hash encoding** — The full exploration state (dimensions, measures, filters, splits) is encoded into a URL-style hash
- **Persistence** — The hash is stored in the widget's `text` field alongside the `[turnilo-widget]` marker
- **Configuration** — The widget's `report` field contains Turnilo app settings (data cubes, clusters, timekeeper)

#### Parameter Mapping

Dashboard-level parameters pass through to Turnilo widgets:

- **Date range** — The `turnilo_daterange` global parameter maps dashboard date filters to Turnilo's time filter
- **Custom parameters** — `parameterMappings` array in the widget configuration maps arbitrary dashboard parameters to Turnilo filter dimensions

#### Configuration Flow

1. Dashboard loads → fetches `/config-turnilo` endpoint
2. Response contains `appSettings` (data cubes, clusters, customization), `timekeeper`, `version`
3. Widget renders with config + stored hash state
4. User interactions update the hash → widget state persists

### Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `TURNILO_BACKEND` | `http://localhost:3000` | Webpack proxy target for Turnilo |
| `PLYWOOD_SERVER_URL` | `http://plywood:3000` | Docker service URL for Plywood backend |
| `PORT` (Plywood) | `3000` | Plywood server listen port |

### Testing

Turnilo tests run via the `test_turnilo.sh` script:

```bash
cd client/app/components/TurniloComponent && npm run test:client
```

CI runs these as part of the `test-unit.yaml` GitHub Actions workflow with separate jobs for client and common test suites.

### Python Integration

**Location:** `plywood-python/plywood/`

A Python implementation of Plywood expression handling, including:

- `attributes/` — Attribute handling
- `datatypes/` — Data type definitions
- `dialect/` — SQL dialect support
- `expressions/` — 55+ expression type implementations
- `external/` — External data source definitions
- `turnilo/` — Turnilo-specific utilities

This enables server-side Plywood expression evaluation in Python contexts.
