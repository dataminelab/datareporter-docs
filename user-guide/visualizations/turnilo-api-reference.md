---
title: Turnilo API Reference
section: user-guide
category: visualizations
order: 13
toc: true
keywords:
  - Turnilo
  - API
  - Plywood
  - endpoints
  - configuration
description: "API reference for DataReporter's Plywood backend serving Turnilo, including query execution, configuration, and utility endpoints."
---

## Turnilo API Reference

The Plywood backend exposes a REST API that the Turnilo frontend uses for configuration, query execution, and utility operations. All endpoints are served from the Plywood service (default port 3000).

### Configuration

#### GET /config-turnilo

Returns the complete Turnilo application configuration.

**Response:**

```json
{
  "appSettings": {
    "dataCubes": [...],
    "clusters": [...],
    "customization": {
      "sentryDSN": "optional-sentry-dsn"
    }
  },
  "timekeeper": {
    "timeTags": {}
  },
  "version": "1.40.5",
  "hash": "optional-config-hash"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `appSettings.dataCubes` | Array | Available data cubes with dimensions and measures |
| `appSettings.clusters` | Array | Configured data source clusters |
| `appSettings.customization` | Object | UI customization (Sentry DSN, etc.) |
| `timekeeper` | Object | Time context for data queries |
| `version` | String | Turnilo version (used for error reporting) |
| `hash` | String | Optional configuration hash for cache validation |

### Query Execution

#### POST /api/v1/plywood

Executes a Plywood expression against the configured data source and returns results.

This is the primary query endpoint. The Turnilo frontend translates user interactions (filters, splits, measures) into Plywood expressions and sends them here.

**Request Body:** Plywood expression object

**Response:** Query results formatted for Turnilo visualization rendering.

### Status

#### GET /api/v1/status

Returns the health status of the Plywood backend.

### Attribute Endpoints

#### GET /api/v1/plywood/attributes

Returns formatted attribute metadata for the configured data sources. Uses registered parsers (PostgreSQL, MySQL, BigQuery, Athena, Druid, JSON) to introspect available columns, types, and cardinalities.

#### GET /api/v1/plywood/attributes/engines

Returns the list of supported query engines/data source types.

**Supported engines:**
- PostgreSQL
- MySQL
- BigQuery
- Athena
- Druid
- JSON

### Hash Utilities

Turnilo uses URL hashes to encode the full exploration state. These endpoints convert between hash representations and structured objects.

#### GET /api/v1/plywood/expression

Converts an expression hash back into a structured Plywood expression object.

#### GET /api/v1/plywood/filter-to-hash

Converts a structured filter expression into a compact hash string for URL encoding.

#### GET /api/v1/plywood/hash-to-filter

Converts a hash string back into a structured filter expression.

### Response Formatting

#### GET /api/v1/plywood/response-shape

Returns metadata about the expected response shape for a given query, useful for pre-rendering visualization layouts before data arrives.

### Error Reporting

When `appSettings.customization.sentryDSN` is configured, the Turnilo frontend initializes Sentry error reporting using the version string from `/config-turnilo`. This captures client-side errors with version context for debugging.

```javascript
if (config.appSettings.customization?.sentryDSN) {
  errorReporterInit(
    config.appSettings.customization.sentryDSN,
    config.version
  );
}
```

### Authentication

All Turnilo API endpoints inherit DataReporter's authentication. Requests are proxied through the DataReporter frontend (webpack proxy in development, reverse proxy in production), so standard DataReporter session authentication applies.

No additional authentication is required for the Plywood backend itself — it trusts requests from the internal Docker network.
