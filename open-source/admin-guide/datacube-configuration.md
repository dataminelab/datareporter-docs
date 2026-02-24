---
title: Datacube Configuration
section: open-source
category: admin-guide
order: 7
toc: true
keywords:
  - datacube
  - model config
  - Turnilo
  - Plywood
  - dimensions
  - measures
  - YAML
description: "How to configure and manage Turnilo datacubes in DataReporter, including auto-generation, manual editing, validation, and troubleshooting."
---

## Datacube Configuration

Datacubes define how DataReporter models your data for interactive Turnilo exploration. As an admin, you manage datacube configurations through the Model Config system, which stores YAML definitions that map database tables to dimensions and measures.

### How It Works

1. An admin creates a **Model** pointing to a data source table
2. DataReporter **auto-generates** a datacube config from the table schema
3. The admin **customizes** the YAML (rename dimensions, add computed measures, remove unnecessary columns)
4. The validator **checks** the config against the required schema
5. The Plywood backend **loads** the config and serves it to Turnilo widgets

### Auto-Generation

When you create a new model, DataReporter introspects the database schema and generates a starter config:

| Column Type | Generated As |
|------------|-------------|
| `VARCHAR`, `TEXT`, `CHARACTER VARYING` | Dimension (`kind: string`) |
| `INTEGER`, `FLOAT`, `NUMERIC`, `BIGINT` | Measure (`formula: $main.sum($col)`) |
| `BOOLEAN` | Dimension (`kind: boolean`) |
| `TIMESTAMP`, `DATE`, `TIMESTAMPTZ` | Dimension (`kind: time`) |

The first `TIME` column becomes the `timeAttribute`. The first numeric column becomes `defaultSortMeasure`.

This gives you a working starting point. You should review and customize it for your use case.

### Editing the Config

The datacube configuration is written in YAML. Here is a minimal working example:

```yaml
dataCubes:
  - name: orders
    title: Orders
    clusterName: postgres
    timeAttribute: created_at
    defaultSortMeasure: revenue
    defaultSelectedMeasures:
      - revenue

    attributes:
      - name: created_at
        type: TIME
        nativeType: TIMESTAMP WITH TIME ZONE
      - name: customer
        type: STRING
        nativeType: CHARACTER VARYING
      - name: revenue
        type: NUMBER
        nativeType: NUMERIC

    dimensions:
      - name: created_at
        title: Created At
        formula: $created_at
        kind: time
      - name: customer
        title: Customer
        formula: $customer

    measures:
      - name: revenue
        title: Revenue
        formula: $main.sum($revenue)
```

For the complete property reference, expression syntax, and advanced examples, see [Datacube Configuration Reference](/docs/user-guide/visualizations/turnilo-datacube-configuration).

### Required Fields

Every datacube must include these fields. The validator will reject configs that are missing any of them:

| Field | Max Length | Notes |
|-------|-----------|-------|
| `name` | 100 chars | Unique identifier, used in URLs |
| `title` | 120 chars | Display name in the UI |
| `clusterName` | — | Must match a supported cluster type |
| `timeAttribute` | — | Must exist in `attributes` |
| `defaultSortMeasure` | — | Must exist in `attributes` |
| `defaultSelectedMeasures` | — | Non-empty list, each must exist in `attributes` |
| `attributes` | — | At least one entry |
| `dimensions` | — | At least one entry (each needs `name`, `title`, `formula`) |
| `measures` | — | At least one entry (each needs `name`, `title`, `formula`) |

### Supported Cluster Types

The `clusterName` field determines which query engine is used:

| Cluster | Data Source | Engine Mapping |
|---------|------------|----------------|
| `native` | In-memory / JSON | `json` |
| `postgres` | PostgreSQL | `pg` |
| `mysql` | MySQL | `mysql` |
| `bigquery` | Google BigQuery | `bigquery` |
| `druid` | Apache Druid | `druid` |
| `athena` | AWS Athena | `athena` |

### Validation

DataReporter validates configs in three stages:

1. **Length check** -- config must not exceed the maximum content size
2. **YAML syntax** -- must be valid YAML (errors report line and column number)
3. **Schema validation** -- required fields present, correct types, allowed enum values
4. **Cross-reference check** -- `timeAttribute`, `defaultSortMeasure`, and `defaultSelectedMeasures` must all exist in `attributes`

If validation fails, the API returns a 400 error with a descriptive message.

### Common Measure Formulas

| Pattern | Formula | Use Case |
|---------|---------|----------|
| Count rows | `$main.count()` | Row count |
| Sum column | `$main.sum($revenue)` | Total revenue |
| Average | `$main.avg($price)` | Average price |
| Min/Max | `$main.min($latency)` | Minimum latency |
| Distinct count | `$main.countDistinct($user_id)` | Unique users |
| Ratio | `$main.sum($a) / $main.sum($b)` | Conversion rate |
| Filtered | `$main.filter($country == 'US').sum($revenue)` | US revenue only |

### Troubleshooting

**"Config has the following issues"**
: Schema validation failed. Check that all required fields are present and correctly typed. Common causes: missing `timeAttribute`, empty `defaultSelectedMeasures`, or typos in field names.

**"timeAttribute 'X' not found in attributes"**
: The `timeAttribute` value doesn't match any entry in the `attributes` list. Make sure the name matches exactly (case-sensitive).

**"defaultSortMeasure 'X' not found in attributes"**
: The measure referenced in `defaultSortMeasure` isn't listed in `attributes`. Add it or change to a measure that exists.

**Datacube not showing in Turnilo**
: Check that the Plywood service is running and reachable. Verify the config loads at `/config-turnilo`. Check browser console for errors.

**Wrong data types**
: If numeric columns show as dimensions or string columns appear as measures, update the `attributes` type and move the entry between `dimensions` and `measures` as appropriate.

### Further Reading

- [Datacube Configuration Reference](/docs/user-guide/visualizations/turnilo-datacube-configuration/) -- Full property reference with expression syntax and advanced examples
- [Turnilo Overview](/docs/user-guide/visualizations/turnilo-overview/) -- Introduction to interactive data exploration
- [Environment Variables](/docs/open-source/admin-guide/env-vars-settings/) -- Plywood-related env vars (`TURNILO_BACKEND`, `PLYWOOD_SERVER_URL`)
