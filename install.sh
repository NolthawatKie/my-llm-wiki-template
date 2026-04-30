#!/usr/bin/env bash
# =============================================================================
# install.sh — second-brain vault installer
# Usage:   bash install.sh <target-directory>
# Example: bash install.sh ~/my-vaults/work-brain
# =============================================================================

set -euo pipefail

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------- argument check ---------------------------------------------------
if [[ $# -lt 1 ]]; then
  echo "Usage:   bash install.sh <target-directory>"
  echo "Example: bash install.sh ~/my-vaults/my-second-brain"
  exit 1
fi

TARGET="$(mkdir -p "$1" && cd "$1" && pwd)"

if [[ "$TARGET" == "$TEMPLATE_DIR" ]]; then
  echo "Error: target cannot be the template directory itself."
  echo "Choose a different path, e.g.: bash install.sh ~/my-vaults/my-second-brain"
  exit 1
fi

# ---------- check target is empty -------------------------------------------
if [[ -n "$(ls -A "$TARGET" 2>/dev/null)" ]]; then
  echo "Warning: $TARGET is not empty. Existing files will not be overwritten."
  read -r -p "Continue? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
fi

echo ""
echo "Installing second-brain vault to: $TARGET"
echo ""

# ---------- .claude config ---------------------------------------------------
echo "Copying .claude config..."
cp -r "$TEMPLATE_DIR/.claude" "$TARGET/"
rm -f "$TARGET/.claude/settings.local.json"   # never copy user-specific session file
echo "  ✓ CLAUDE.md, settings.json"
echo "  ✓ agents/ (4 files)"
echo "  ✓ skills/ (12 files)"
echo "  ✓ hooks/ (2 files)"

# ---------- wiki skeleton ----------------------------------------------------
echo ""
echo "Copying wiki skeleton..."
mkdir -p "$TARGET/wiki/gaps" "$TARGET/wiki/memory/sessions"
cp "$TEMPLATE_DIR/wiki/index.md"                  "$TARGET/wiki/index.md"
cp "$TEMPLATE_DIR/wiki/log.md"                    "$TARGET/wiki/log.md"
cp "$TEMPLATE_DIR/wiki/gaps/roadmap.md"           "$TARGET/wiki/gaps/roadmap.md"
cp "$TEMPLATE_DIR/wiki/memory/sessions/latest.md" "$TARGET/wiki/memory/sessions/latest.md"
echo "  ✓ wiki/index.md"
echo "  ✓ wiki/log.md"
echo "  ✓ wiki/gaps/roadmap.md  ← edit this with your learning goals"
echo "  ✓ wiki/memory/sessions/latest.md"

# ---------- root files -------------------------------------------------------
echo ""
echo "Copying root files..."
cp "$TEMPLATE_DIR/.gitignore"      "$TARGET/.gitignore"
cp "$TEMPLATE_DIR/.obsidianignore" "$TARGET/.obsidianignore"
cp "$TEMPLATE_DIR/README.md"       "$TARGET/README.md"
echo "  ✓ .gitignore, .obsidianignore, README.md"

# ---------- empty directories ------------------------------------------------
echo ""
echo "Creating empty directories..."
DIRS=(
  "staging/inbox"
  "staging/reviewed"
  "raw/sources"
  "raw/notes"
  "raw/data"
  "raw/code"
  "raw/_archived"
  "wiki/concepts"
  "wiki/entities"
  "wiki/synthesis"
  "wiki/sources"
  "wiki/cache/hot"
  "wiki/memory/answers"
  "wiki/memory/sessions/archive"
  "wiki/gaps"
  "wiki/_archived/sources"
  "output"
)

for dir in "${DIRS[@]}"; do
  mkdir -p "$TARGET/$dir"
  touch "$TARGET/$dir/.gitkeep"
  echo "  ✓ $dir/"
done

# ---------- git init ---------------------------------------------------------
echo ""
if command -v git &>/dev/null && [[ ! -d "$TARGET/.git" ]]; then
  echo "Initialising git repository..."
  git -C "$TARGET" init -q
  git -C "$TARGET" add .
  git -C "$TARGET" commit -q -m "init: second-brain vault from template"
  echo "  ✓ git init + initial commit"
elif [[ -d "$TARGET/.git" ]]; then
  echo "  (git repo already exists — skipping init)"
else
  echo "  (git not found — skipping git init)"
fi

# ---------- done -------------------------------------------------------------
echo ""
echo "✅  Vault installed at: $TARGET"
echo ""
echo "Next steps:"
echo "  1. Open the vault in Obsidian"
echo "     File → Open Vault → select: $TARGET"
echo ""
echo "  2. Start Claude Code inside the vault"
echo "     cd \"$TARGET\" && claude"
echo ""
echo "  3. Edit wiki/gaps/roadmap.md with your learning goals"
echo ""
echo "  4. Drop a source into raw/sources/ and ingest it"
echo "     /ingest raw/sources/<filename>"
