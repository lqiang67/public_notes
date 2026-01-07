#!/bin/bash

# update_readme.sh - Script to update README.md with all published notes

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOTES_DIR="$SCRIPT_DIR/notes"
README_FILE="$SCRIPT_DIR/README.md"

# Default header template
DEFAULT_HEADER="# Public Notes

This repository contains my publicly shared notes and research materials.

## Usage

To publish new notes, use the \`publish_notes\` command:
\`\`\`bash
publish_notes /path/to/your/notes/folder
\`\`\`

The command will:
1. Copy your notes folder to this repository
2. Update this README with links to PDF files
3. Commit and push changes to GitHub

## Notes

"

# Read existing README to preserve manual edits
if [ -f "$README_FILE" ]; then
    # Check if README has the "## Notes" section
    if grep -q "^## Notes" "$README_FILE"; then
        # Extract everything before "## Notes" (including the line itself if we want to keep it)
        # We'll keep content up to but not including "## Notes", then add our own
        MANUAL_HEADER=$(sed '/^## Notes$/,$d' "$README_FILE")
        # Add the Notes header
        MANUAL_HEADER="${MANUAL_HEADER}## Notes

"
    else
        # Check if it's the old format (just has notes listed)
        # If it starts with "# Public Notes" or similar, preserve it
        if head -n 1 "$README_FILE" | grep -q "^#"; then
            # It has a header, preserve everything and add Notes section
            MANUAL_HEADER=$(cat "$README_FILE")
            # Remove any existing auto-generated notes (lines starting with "- **")
            MANUAL_HEADER=$(echo "$MANUAL_HEADER" | sed '/^- \*\*/d' | sed '/^---$/d' | sed '/automatically generated/d')
            # Clean up trailing empty lines
            MANUAL_HEADER=$(echo "$MANUAL_HEADER" | sed -e :a -e '/^\n*$/d;N;ba')
            MANUAL_HEADER="${MANUAL_HEADER}

## Notes

"
        else
            # Doesn't look like it has a proper header, use default
            MANUAL_HEADER="$DEFAULT_HEADER"
        fi
    fi
else
    # No README exists, use default
    MANUAL_HEADER="$DEFAULT_HEADER"
fi

# Write README with preserved header
printf "%s" "$MANUAL_HEADER" > "$README_FILE"

# Find all note folders and generate links
if [ -d "$NOTES_DIR" ]; then
    # Sort folders by name for consistent ordering
    for NOTE_DIR in $(find "$NOTES_DIR" -maxdepth 1 -type d ! -path "$NOTES_DIR" | sort); do
        NOTE_NAME=$(basename "$NOTE_DIR")
        
        # Find PDF files in the note directory
        PDF_FILES=$(find "$NOTE_DIR" -maxdepth 1 -name "*.pdf" -type f)
        
        if [ -n "$PDF_FILES" ]; then
            # Get the first PDF (or main PDF if there's a main.pdf)
            MAIN_PDF=""
            if [ -f "$NOTE_DIR/main.pdf" ]; then
                MAIN_PDF="main.pdf"
            else
                # Get the first PDF alphabetically
                MAIN_PDF=$(basename "$(echo "$PDF_FILES" | head -n1)")
            fi
            
            # Create relative path for GitHub
            PDF_PATH="notes/$NOTE_NAME/$MAIN_PDF"
            echo "- **[$NOTE_NAME]($PDF_PATH)**" >> "$README_FILE"
        else
            # No PDF found, just list the folder
            echo "- **$NOTE_NAME** (no PDF found)" >> "$README_FILE"
        fi
    done
fi

# Add footer
cat >> "$README_FILE" << 'EOF'

---

*The Notes section above is automatically generated. You can edit the README manually to add descriptions or organize notes differently.*
EOF

echo "README.md updated successfully"
