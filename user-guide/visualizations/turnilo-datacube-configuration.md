---
title: Datacube Configuration
section: user-guide
category: visualizations
order: 14
toc: true
keywords:
  - Turnilo
  - datacube
  - configuration
  - dimensions
  - measures
  - Plywood
  - YAML
  - model config
description: "Reference for configuring Turnilo datacubes in DataReporter, including dimensions, measures, attributes, and Plywood expression syntax."
---

## Datacube Configuration

DataReporter uses Turnilo's datacube configuration syntax to define how data sources are modeled for interactive exploration. Each datacube maps a database table to a set of dimensions (things you slice by) and measures (things you aggregate).

Datacube configurations are written in YAML and stored per model. They can be auto-generated from your database schema or hand-crafted for full control.

### Quick Example

```yaml
dataCubes:
  - name: orders
    title: Orders
    clusterName: postgres
    timeAttribute: created_at
    defaultSortMeasure: total_revenue
    defaultSelectedMeasures:
      - total_revenue
      - order_count

    attributes:
      - name: created_at
        type: TIME
        nativeType: TIMESTAMP WITH TIME ZONE
      - name: customer_email
        type: STRING
        nativeType: CHARACTER VARYING
      - name: status
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
      - name: customer_email
        title: Customer Email
        formula: $customer_email
      - name: status
        title: Order Status
        formula: $status

    measures:
      - name: order_count
        title: Order Count
        formula: $main.count()
      - name: total_revenue
        title: Total Revenue
        formula: $main.sum($revenue)
        units: USD
        format: "$0,0.00"
```

### Datacube Properties

Top-level properties for each datacube entry:

| Property | Required | Type | Description |
|----------|----------|------|-------------|
| `name` | Yes | string (max 100) | Unique identifier, used in URLs. Changing this breaks existing bookmarks. |
| `title` | Yes | string (max 120) | Display name shown in the UI. Safe to change. |
| `description` | No | string (max 256) | Shown on the datacube selection screen. |
| `clusterName` | Yes | string | Data source type. See [Supported Clusters](#supported-clusters). |
| `timeAttribute` | Yes | string | Name of the primary time column. Must exist in `attributes`. |
| `defaultSortMeasure` | Yes | string | Measure used for default sorting. Must exist in `attributes`. |
| `defaultSelectedMeasures` | Yes | string[] | Measures shown by default. Each must exist in `attributes`. |
| `attributes` | Yes | list | Column definitions. See [Attributes](#attributes). |
| `dimensions` | Yes | list | Dimension definitions. See [Dimensions](#dimensions). |
| `measures` | Yes | list | Measure definitions. See [Measures](#measures). |

#### Additional Properties (TypeScript/Advanced)

These properties are supported by the Turnilo frontend but not enforced by DataReporter's YAML validator:

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `source` | string or string[] | same as `name` | Table or data source name. Multiple values create a union. |
| `defaultTimezone` | string | `Etc/UTC` | Timezone in Olsen format (e.g., `Europe/Riga`). |
| `defaultDuration` | string | `P1D` | ISO 8601 duration for initial time range (e.g., `P3D` for 3 days). |
| `defaultPinnedDimensions` | string[] | — | Dimensions pinned in the right panel. |
| `subsetFormula` | string | — | Plywood filter applied transparently to all queries. |
| `introspection` | string | `autofill-all` | Schema discovery strategy. See [Introspection](#introspection). |
| `maxSplits` | number | 3 | Maximum number of dimension splits. |
| `maxQueries` | number | 500 | Maximum concurrent queries. |
| `rollup` | boolean | false | Enable rollup mode (Druid). |
| `refreshRule` | object | — | Data refresh strategy. See [Refresh Rules](#refresh-rules). |

### Supported Clusters

The `clusterName` determines which query engine DataReporter uses:

| Cluster Name | Data Source | Notes |
|-------------|------------|-------|
| `native` | In-memory / JSON | Static or API-driven data |
| `postgres` | PostgreSQL | Full SQL support |
| `mysql` | MySQL | Full SQL support |
| `bigquery` | Google BigQuery | Requires service account |
| `athena` | AWS Athena | S3-based queries |
| `druid` | Apache Druid | Full introspection, rollups, sketches |

### Attributes

Attributes define the raw columns available from your data source. Every column referenced in dimensions, measures, `timeAttribute`, `defaultSortMeasure`, or `defaultSelectedMeasures` must have a corresponding attribute entry.

```yaml
attributes:
  - name: created_at
    type: TIME
    nativeType: TIMESTAMP WITH TIME ZONE

  - name: user_id
    type: NUMBER
    nativeType: INTEGER

  - name: country
    type: STRING
    nativeType: CHARACTER VARYING

  - name: is_active
    type: BOOLEAN
    nativeType: BOOLEAN
```

| Property | Required | Description |
|----------|----------|-------------|
| `name` | Yes | Column name, must match the database column exactly. |
| `type` | Yes | Plywood type: `STRING`, `NUMBER`, `TIME`, or `BOOLEAN`. |
| `nativeType` | No | Native database type (e.g., `INTEGER`, `FLOAT`, `CHARACTER VARYING`). Informational. |

**Druid-specific native types:** `hyperUnique`, `thetaSketch`, `HLLSketch`, `approximateHistogram`, `quantilesDoublesSketch`. These trigger special aggregation behavior.

### Dimensions

Dimensions define the axes you can slice and filter data by. Each dimension references a column via a Plywood formula.

```yaml
dimensions:
  - name: country
    title: Country
    formula: $country

  - name: signup_date
    title: Signup Date
    formula: $signup_date
    kind: time

  - name: is_premium
    title: Premium User
    formula: $is_premium
    kind: boolean

  - name: age_group
    title: Age Group
    formula: $age
    kind: number
```

| Property | Required | Type | Description |
|----------|----------|------|-------------|
| `name` | Yes | string | Unique identifier, used in URLs. |
| `title` | Yes | string | Display name in the UI. |
| `formula` | Yes | string | Plywood expression. Typically `$columnName`. |
| `kind` | No | string | Data type: `string` (default), `time`, `number`, `boolean`. |
| `description` | No | string (max 100) | Tooltip or help text. |
| `multiValue` | No | boolean | Set `true` for multi-value dimensions (Druid). |

#### Dimension Kinds

| Kind | When to Use | UI Behavior |
|------|-------------|-------------|
| `string` | Categorical data (names, IDs, labels) | Filter list, search |
| `time` | Timestamps and dates | Time picker, granularity selector |
| `number` | Numeric ranges (age, price) | Histogram bucketing |
| `boolean` | True/false flags | Toggle filter |

#### Advanced Dimension Formulas

Beyond simple column references (`$columnName`), dimensions support:

```yaml
# Lookup (Druid)
- name: country_name
  formula: $country_code.lookup('country_names')

# Regex extraction
- name: version_major
  formula: $version.extract('(\d+\.\d+)')

# Boolean expression
- name: is_usa
  formula: $country == 'United States'
```

### Measures

Measures define the aggregations computed over your data. Each measure uses a Plywood expression against `$main` (the data segment).

```yaml
measures:
  - name: count
    title: Row Count
    formula: $main.count()

  - name: total_revenue
    title: Total Revenue
    formula: $main.sum($revenue)
    units: USD
    format: "$0,0.00"

  - name: avg_order_value
    title: Avg Order Value
    formula: $main.sum($revenue) / $main.count()
    format: "$0,0.00"

  - name: unique_customers
    title: Unique Customers
    formula: $main.countDistinct($customer_id)

  - name: max_order
    title: Largest Order
    formula: $main.max($revenue)
    format: "$0,0.00"
```

| Property | Required | Type | Description |
|----------|----------|------|-------------|
| `name` | Yes | string | Unique identifier. Changing this breaks bookmarked URLs. |
| `title` | Yes | string | Display name in the UI. |
| `formula` | Yes | string | Plywood aggregation expression. See [Formula Reference](#formula-reference). |
| `description` | No | string (max 100) | Tooltip or help text. |
| `units` | No | string | Unit label displayed next to the title (e.g., `seconds`, `USD`). |
| `format` | No | string | Number format string ([numbro](https://numbrojs.com/) syntax). Default: `0,0.0 a`. |
| `lowerIsBetter` | No | boolean | Set `true` when lower values are preferable (e.g., error rates). |
| `transformation` | No | string | `none` (default), `percent-of-parent`, or `percent-of-total`. |

### Formula Reference

All measure formulas operate on `$main`, which represents the current data segment. Dimension formulas reference columns directly with `$columnName`.

#### Aggregation Functions

| Formula | Description | Example |
|---------|-------------|---------|
| `$main.count()` | Count of rows | Row count |
| `$main.sum($col)` | Sum of values | `$main.sum($revenue)` |
| `$main.avg($col)` | Average of values | `$main.avg($price)` |
| `$main.min($col)` | Minimum value | `$main.min($latency)` |
| `$main.max($col)` | Maximum value | `$main.max($latency)` |
| `$main.countDistinct($col)` | Distinct count | `$main.countDistinct($user_id)` |
| `$main.quantile($col, p)` | Percentile (Druid only) | `$main.quantile($response_time, 0.98)` |

#### Arithmetic and Ratios

Combine aggregations with standard arithmetic:

```yaml
# Revenue per order
formula: $main.sum($revenue) / $main.count()

# Conversion rate as percentage
formula: $main.sum($conversions) / $main.sum($visits) * 100

# Profit margin
formula: ($main.sum($revenue) - $main.sum($cost)) / $main.sum($revenue)
```

#### Filtered Aggregations

Apply filters within a measure:

```yaml
# Revenue from US only
formula: $main.filter($country == 'United States').sum($revenue)

# High-value orders
formula: $main.filter($revenue.greaterThan(100)).count()
```

#### Column References

| Syntax | Meaning |
|--------|---------|
| `$columnName` | Reference to a column |
| `$main` | The current data segment (used in measures) |
| `$col.lookup('name')` | Named lookup (Druid) |
| `$col.extract('regex')` | Regex extraction |
| `$col.customTransform('name')` | Custom transform (Druid) |

### Introspection

Controls how DataReporter discovers schema information from the data source:

| Strategy | Description |
|----------|-------------|
| `autofill-all` | Auto-create dimensions and measures from database columns (default) |
| `autofill-dimensions-only` | Auto-create dimensions only, measures must be manual |
| `autofill-measures-only` | Auto-create measures only, dimensions must be manual |
| `no-autofill` | Introspect columns but don't auto-create dimensions/measures |
| `none` | Skip introspection entirely, use only what's in the config |

### Refresh Rules

Control how DataReporter detects new data:

```yaml
# Batch sources - queries for max time value every minute
refreshRule:
  rule: query

# Real-time sources - assumes current time is latest
refreshRule:
  rule: realtime

# Static/historical data - fixed point in time
refreshRule:
  rule: fixed
  time: "2026-01-15T00:00:00.000Z"
```

### Auto-Generation

DataReporter can auto-generate datacube configurations from your database schema. When you create a new model, the system introspects the table and produces a configuration where:

- **STRING/VARCHAR columns** become dimensions with `formula: $columnName`
- **NUMBER/INTEGER/FLOAT columns** become measures with `formula: $main.sum($columnName)`
- **BOOLEAN columns** become dimensions with `kind: boolean`
- **TIMESTAMP columns** become dimensions with `kind: time` (the first one becomes `timeAttribute`)

You can then customize the generated YAML to rename dimensions, add computed measures, or remove unnecessary columns.

### Validation

DataReporter validates datacube configurations against a strict schema. The validator checks:

1. **YAML syntax** is valid
2. **Required fields** are present (`name`, `title`, `timeAttribute`, `clusterName`, `defaultSortMeasure`, `defaultSelectedMeasures`, `attributes`, `dimensions`, `measures`)
3. **Field lengths** don't exceed limits (name: 100, title: 120, description: 256 chars)
4. **Cross-references** are valid:
   - `timeAttribute` must exist in `attributes`
   - `defaultSortMeasure` must exist in `attributes`
   - Every entry in `defaultSelectedMeasures` must exist in `attributes`
5. **Allowed values** for enums (e.g., `transformation` must be `none`, `percent-of-parent`, or `percent-of-total`)

### Complete Example

A production-ready datacube for an e-commerce orders table:

```yaml
dataCubes:
  - name: ecommerce_orders
    title: E-Commerce Orders
    description: Customer orders with revenue and product data
    clusterName: postgres
    timeAttribute: order_date
    defaultTimezone: Europe/Riga
    defaultDuration: P7D
    defaultSortMeasure: revenue
    defaultSelectedMeasures:
      - revenue
      - order_count
      - unique_customers

    attributes:
      - name: order_date
        type: TIME
        nativeType: TIMESTAMP WITH TIME ZONE
      - name: customer_id
        type: NUMBER
        nativeType: INTEGER
      - name: customer_email
        type: STRING
        nativeType: CHARACTER VARYING
      - name: country
        type: STRING
        nativeType: CHARACTER VARYING
      - name: product_category
        type: STRING
        nativeType: CHARACTER VARYING
      - name: revenue
        type: NUMBER
        nativeType: NUMERIC
      - name: quantity
        type: NUMBER
        nativeType: INTEGER
      - name: is_returned
        type: BOOLEAN
        nativeType: BOOLEAN

    dimensions:
      - name: order_date
        title: Order Date
        formula: $order_date
        kind: time
      - name: customer_email
        title: Customer
        formula: $customer_email
      - name: country
        title: Country
        formula: $country
      - name: product_category
        title: Product Category
        formula: $product_category
      - name: is_returned
        title: Returned
        formula: $is_returned
        kind: boolean

    measures:
      - name: order_count
        title: Orders
        formula: $main.count()
      - name: revenue
        title: Revenue
        formula: $main.sum($revenue)
        units: EUR
        format: "0,0.00"
      - name: avg_order_value
        title: Avg Order Value
        formula: $main.sum($revenue) / $main.count()
        format: "0,0.00"
      - name: total_quantity
        title: Items Sold
        formula: $main.sum($quantity)
      - name: unique_customers
        title: Unique Customers
        formula: $main.countDistinct($customer_id)
      - name: return_rate
        title: Return Rate
        formula: $main.filter($is_returned == true).count() / $main.count()
        format: "0.0%"
        lowerIsBetter: true
        transformation: none
```

### Further Reading

- [Turnilo Overview](/docs/user-guide/visualizations/turnilo-overview) - Introduction to interactive data exploration
- [Turnilo Architecture](/docs/user-guide/visualizations/turnilo-architecture) - Technical architecture and integration details
- [Turnilo API Reference](/docs/user-guide/visualizations/turnilo-api-reference) - Plywood backend REST API
- [Official Turnilo Datacube Configuration](https://allegro.github.io/turnilo/configuration-datacubes.html) - Full upstream reference with additional advanced options
