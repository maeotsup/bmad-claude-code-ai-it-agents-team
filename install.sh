#!/usr/bin/env bash
#
# Install the AI Team Bootstrap into a target project.
# Usage: ./install.sh /path/to/target/project
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="$SCRIPT_DIR/bootstrap"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <target-project-directory>"
    echo ""
    echo "Copies the AI Team Bootstrap files into the target project."
    echo "After copying, open the project in Claude Code and run /setup."
    exit 1
fi

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Target directory '$TARGET_DIR' does not exist."
    exit 1
fi

if [ ! -d "$BOOTSTRAP_DIR" ]; then
    echo "Error: Bootstrap directory not found at '$BOOTSTRAP_DIR'."
    exit 1
fi

# Check for existing .claude directory
if [ -d "$TARGET_DIR/.claude" ]; then
    echo "Warning: Target already has a .claude/ directory."
    read -p "Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

echo "Copying bootstrap files to $TARGET_DIR..."

# Copy visible files
cp -r "$BOOTSTRAP_DIR"/* "$TARGET_DIR/" 2>/dev/null || true

# Copy hidden files (.claude directory)
cp -r "$BOOTSTRAP_DIR"/.claude "$TARGET_DIR/"

echo ""
echo "Bootstrap installed successfully."
echo ""
echo "Next steps:"
echo "  1. Open $TARGET_DIR in your editor with Claude Code"
echo "  2. Run /setup to initialize your AI development team"
