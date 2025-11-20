#!/bin/bash

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="$REPO_ROOT/docs"
TEMP_DIR=$(mktemp -d)

echo "Creating documentation archive..."
echo "Repository: $REPO_ROOT"
echo "Documentation: $DOCS_DIR"
echo ""

if [ ! -d "$DOCS_DIR" ]; then
    echo "Error: docs directory not found at $DOCS_DIR"
    exit 1
fi

cd "$DOCS_DIR"

FILES=(
    "README.md"
    "SETUP-GUIDE.md"
    "QUICK-REFERENCE.md"
    "TROUBLESHOOTING.md"
    "SSH-SETUP.md"
)

echo "Checking files..."
MISSING=0
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file (missing)"
        MISSING=1
    fi
done

if [ $MISSING -eq 1 ]; then
    echo ""
    echo "Error: Some documentation files are missing."
    echo "Please create all files before running this script."
    exit 1
fi

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
ARCHIVE_NAME="development-containers-docs-$TIMESTAMP.tar.gz"

echo ""
echo "Creating archive: $ARCHIVE_NAME"

tar -czf "$REPO_ROOT/$ARCHIVE_NAME" \
    --transform 's,^,docs/,' \
    "${FILES[@]}"

echo ""
echo "✓ Archive created: $REPO_ROOT/$ARCHIVE_NAME"
echo ""
echo "To extract:"
echo "  tar -xzf $ARCHIVE_NAME"
echo ""
echo "Archive contents:"
tar -tzf "$REPO_ROOT/$ARCHIVE_NAME"

echo ""
echo "To add to git:"
echo "  cd $REPO_ROOT"
echo "  git add $ARCHIVE_NAME"
echo "  git commit -m \"Add documentation archive\""
echo ""
