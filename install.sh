#!/bin/bash

# install.sh - Install publish_notes command system-wide

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUBLISH_SCRIPT="$SCRIPT_DIR/publish_notes"

# Detect shell and determine where to add the alias/symlink
SHELL_NAME=$(basename "$SHELL")
SHELL_RC=""

case "$SHELL_NAME" in
    bash)
        if [ -f "$HOME/.bashrc" ]; then
            SHELL_RC="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            SHELL_RC="$HOME/.bash_profile"
        fi
        ;;
    zsh)
        SHELL_RC="$HOME/.zshrc"
        ;;
    *)
        echo "Warning: Unrecognized shell. Please manually add to your shell config."
        ;;
esac

# Option 1: Create a symlink in a directory in PATH
if [ -d "$HOME/.local/bin" ]; then
    BIN_DIR="$HOME/.local/bin"
elif [ -d "/usr/local/bin" ] && [ -w "/usr/local/bin" ]; then
    BIN_DIR="/usr/local/bin"
else
    mkdir -p "$HOME/.local/bin"
    BIN_DIR="$HOME/.local/bin"
fi

# Create symlink
if [ -L "$BIN_DIR/publish_notes" ]; then
    rm "$BIN_DIR/publish_notes"
fi
ln -s "$PUBLISH_SCRIPT" "$BIN_DIR/publish_notes"
chmod +x "$BIN_DIR/publish_notes"

echo "Created symlink: $BIN_DIR/publish_notes -> $PUBLISH_SCRIPT"

# Add to PATH if not already there
if [ -n "$SHELL_RC" ]; then
    if ! grep -q "$BIN_DIR" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# Add local bin to PATH for publish_notes" >> "$SHELL_RC"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_RC"
        echo "Added $BIN_DIR to PATH in $SHELL_RC"
    fi
fi

echo ""
echo "Installation complete!"
echo ""
echo "To use publish_notes:"
echo "  1. Restart your terminal, or run: source $SHELL_RC"
echo "  2. Then you can use: publish_notes <foldername>"
echo ""
echo "To set up the GitHub repository, run:"
echo "  ./setup_repo.sh"

