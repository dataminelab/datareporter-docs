#!/bin/bash
# Enforce trailing slashes on all internal doc links (page URLs only).
# Checks: markdown files (link syntax) and docs-nav.json (link values).
# Skips: image/file references (paths containing a file extension like .png, .jpg, .gif).
set -e

ERRORS=0

echo "=== Checking markdown internal links (page URLs only) ==="

# Step 1: Find all /docs/ links without trailing slash
# Step 2: Exclude file references (images, assets with extensions)
while IFS= read -r line; do
  file=$(echo "$line" | cut -d: -f1)
  lineno=$(echo "$line" | cut -d: -f2)
  match=$(echo "$line" | cut -d: -f3-)
  echo "ERROR: $file:$lineno - Link missing trailing slash: $match"
  ERRORS=$((ERRORS + 1))
done < <(
  grep -rnE '\]\(/docs/[^)]*[^/)\s#]\)' --include='*.md' . 2>/dev/null \
    | grep -vE '\]\(/docs/[^)]*\.(png|jpg|jpeg|gif|svg|webp|ico|pdf|PNG|JPG|GIF|SVG)\)' \
    | grep -vE '\]\(/docs/[^)]*/#[^)]*\)' \
    || true
)

echo ""
echo "=== Checking docs-nav.json links ==="
# Every "link" value must end with /
if [ -f docs-nav.json ]; then
  while IFS= read -r line; do
    echo "ERROR: docs-nav.json - Link missing trailing slash: $line"
    ERRORS=$((ERRORS + 1))
  done < <(grep -oE '"link"\s*:\s*"[^"]*"' docs-nav.json | grep -v '/"' || true)
fi

echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo "FAILED: Found $ERRORS link(s) missing trailing slashes."
  echo ""
  echo "All internal page links must end with a trailing slash (/)."
  echo "Example: [Writing Queries](/docs/user-guide/querying/writing-queries/)"
  echo "NOT:     [Writing Queries](/docs/user-guide/querying/writing-queries)"
  echo ""
  echo "Note: Image/file references (e.g., .png, .jpg) are excluded from this check."
  exit 1
else
  echo "PASSED: All internal links have trailing slashes."
fi
