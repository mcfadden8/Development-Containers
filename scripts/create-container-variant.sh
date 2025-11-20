#!/bin/bash

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <source-container> <new-container>"
    echo ""
    echo "Example:"
    echo "  $0 spheral-gcc11 spheral-gcc13"
    echo ""
    exit 1
fi

SOURCE=$1
TARGET=$2

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$REPO_ROOT/$SOURCE"
TARGET_DIR="$REPO_ROOT/$TARGET"

SOURCE_PROJECT=$(echo $SOURCE | sed 's/-gcc[0-9]*//')
TARGET_PROJECT=$(echo $TARGET | sed 's/-gcc[0-9]*//')

PROJECT_DIR="$HOME/projects/$TARGET_PROJECT"
HISTORY_DIR="$HOME/.container-data/$TARGET"

echo "================================================"
echo "Creating Container Variant"
echo "================================================"
echo "Source:          $SOURCE"
echo "Target:          $TARGET"
echo "Source Project:  $SOURCE_PROJECT"
echo "Target Project:  $TARGET_PROJECT"
echo "================================================"
echo ""

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source container directory does not exist: $SOURCE_DIR"
    exit 1
fi

if [ -d "$TARGET_DIR" ]; then
    echo "Error: Target container directory already exists: $TARGET_DIR"
    exit 1
fi

echo "Step 1: Copying container directory..."
cp -r "$SOURCE_DIR" "$TARGET_DIR"
echo "  ✓ Copied $SOURCE -> $TARGET"

echo ""
echo "Step 2: Updating file references..."

cd "$TARGET_DIR"

find . -type f -not -path './.git/*' | while read file; do
    if file "$file" | grep -q text; then
        sed -i "s/$SOURCE/$TARGET/g" "$file"
    fi
done

if [ -f "${SOURCE}.Dockerfile" ]; then
    mv "${SOURCE}.Dockerfile" "${TARGET}.Dockerfile"
    echo "  ✓ Renamed Dockerfile"
fi

echo "  ✓ Updated all references from $SOURCE to $TARGET"

echo ""
echo "Step 3: Creating project directory..."
if [ ! -d "$PROJECT_DIR" ]; then
    mkdir -p "$PROJECT_DIR"
    echo "  ✓ Created $PROJECT_DIR"
else
    echo "  ℹ Project directory already exists: $PROJECT_DIR"
fi

echo ""
echo "Step 4: Creating history directory..."
if [ ! -d "$HISTORY_DIR" ]; then
    mkdir -p "$HISTORY_DIR"
    touch "$HISTORY_DIR/.zsh_history"
    echo "  ✓ Created $HISTORY_DIR/.zsh_history"
else
    echo "  ℹ History directory already exists: $HISTORY_DIR"
fi

echo ""
echo "Step 5: Verification..."
echo ""
echo "Files created:"
find "$TARGET_DIR" -type f | sed "s|$REPO_ROOT/||"

echo ""
echo "================================================"
echo "Container variant created successfully!"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Review and customize $TARGET configuration:"
echo "   cd $TARGET_DIR"
echo "   vim ${TARGET}.Dockerfile"
echo ""
echo "2. Commit to git:"
echo "   cd $REPO_ROOT"
echo "   git add $TARGET/"
echo "   git commit -m \"Add $TARGET container variant\""
echo ""
echo "3. Open in VSCode:"
echo "   cd $TARGET_DIR"
echo "   code ."
echo "   Then: F1 → Dev Containers: Reopen in Container"
echo ""
echo "Directories:"
echo "  Container config: $TARGET_DIR"
echo "  Project work:     $PROJECT_DIR"
echo "  History:          $HISTORY_DIR/.zsh_history"
echo ""
