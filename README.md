# DataReporter Documentation

The source content for [DataReporter](https://datareporter.com) documentation. This is a **content-only repository** — markdown files and images that are automatically published to the DataReporter website when merged to `main`.

## Directory Structure

```
datareporter-docs/
├── user-guide/          # End-user docs (querying, dashboards, visualizations, alerts)
├── data-sources/        # Setup guides for 20+ supported data sources
├── open-source/         # Self-hosted deployment and admin guides
├── faq/                 # Frequently asked questions and troubleshooting
├── images/              # Screenshots, GIFs, and other assets
└── .github/workflows/   # CI — triggers website rebuild on push to main
```

## Contributing

We welcome contributions! Whether it's fixing a typo, improving an explanation, or documenting a new feature — every improvement helps.

### Quick Start

1. **Fork & clone** this repository
2. **Create a branch** for your changes:
   ```bash
   git checkout -b fix/improve-bigquery-docs
   ```
3. **Edit or add** markdown files (see [Writing Docs](#writing-docs) below)
4. **Commit & push** your changes:
   ```bash
   git add .
   git commit -m "Improve BigQuery setup instructions"
   git push origin fix/improve-bigquery-docs
   ```
5. **Open a Pull Request** against `main`

Once your PR is reviewed and merged, the website rebuilds automatically — your changes will be live within minutes.

### What You Can Help With

- **Fix typos or unclear wording** — if something confused you, it'll confuse others
- **Add missing steps** to setup guides
- **Update screenshots** that are outdated
- **Document new data sources** or features
- **Improve the FAQ** with questions you've seen from users

## Writing Docs

### Frontmatter

Every markdown file starts with YAML frontmatter:

```yaml
---
title: Page Title
section: user-guide          # user-guide | data-sources | open-source | faq
category: querying           # subcategory within the section
order: 1                     # controls page order in navigation
toc: true                    # show table of contents on the page
keywords:                    # optional, helps with search
  - relevant keyword
  - another keyword
description: Optional SEO description
---
```

**Required fields:** `title`, `section`
**Optional fields:** `category`, `order`, `toc`, `keywords`, `description`

### Images

- Place images in the `images/` directory
- Reference them as: `![Alt text](/docs/images/your-image.png)`
- Use descriptive filenames: `bigquery-setup-screen.png` not `screenshot1.png`
- Prefer PNG for screenshots, GIF for short workflow demonstrations

### Internal Links

Link to other docs pages using: `[link text](/docs/section/page-name)`

Examples:
```markdown
[Writing Queries](/docs/user-guide/querying/writing-queries)
[Supported Data Sources](/docs/data-sources/setup/supported-data-sources)
```

## Previewing Your Changes

For **content edits** (typos, wording, new sections), your editor's built-in markdown preview is sufficient — VS Code, GitHub's web editor, or any markdown viewer will show you the content accurately.

## Deployment

This repo uses a hands-off deployment model:

1. You push or merge to `main`
2. A GitHub Actions workflow automatically triggers a rebuild of the [DataReporter website](https://datareporter.com)
3. Changes go live within minutes

No build tools, no local preview server — just edit markdown and push. The website repository handles all rendering.

## License

This documentation includes content derived from the [Redash Knowledge Base](https://github.com/getredash/website), licensed under the BSD 2-Clause License. See [NOTICE](NOTICE) for full attribution.
