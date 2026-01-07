# Quick Start Guide

## Initial Setup

1. **Install the publish_notes command:**
   ```bash
   ./install.sh
   ```
   This will create a symlink and add it to your PATH.

2. **Set up the GitHub repository:**
   
   **Option A: Using GitHub CLI (recommended, fully automated):**
   ```bash
   # Install GitHub CLI if not already installed
   brew install gh
   
   # Authenticate with GitHub
   gh auth login
   
   # Run setup script (creates repo and pushes automatically)
   ./setup_repo.sh
   ```
   
   **Option B: Manual setup (if you prefer not to use GitHub CLI):**
   ```bash
   ./setup_repo.sh
   # Then follow the instructions to create the repository manually
   ```
   
   The setup script will automatically:
   - Initialize the git repository
   - Create the GitHub repository (if using GitHub CLI)
   - Set up the remote
   - Create initial commit
   - Push to GitHub

## Publishing Notes

Once set up, you can publish any folder of notes from anywhere:

```bash
publish_notes /path/to/your/notes/folder
```

The command will:
- Copy the folder to `notes/` in this repository
- Update README.md with links to PDF files
- Commit and push changes to GitHub

## Manual README Editing

You can edit README.md manually to:
- Add descriptions to notes
- Reorganize the listing
- Add additional sections

The script will preserve everything above the "## Notes" section when updating.

