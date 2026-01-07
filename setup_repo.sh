#!/bin/bash

# setup_repo.sh - Initialize GitHub repository for public notes

# Don't use set -e so we can handle errors gracefully
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}Setting up GitHub repository...${NC}"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed${NC}"
    exit 1
fi

cd "$SCRIPT_DIR"

# Initialize git repository if not already initialized
if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
    echo -e "${GREEN}Git repository initialized${NC}"
else
    echo -e "${YELLOW}Git repository already initialized${NC}"
fi

# Set up remote and create GitHub repository
REPO_NAME="public_notes"
GITHUB_USER="lqiang67"
REPO_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

if ! git remote | grep -q origin; then
    echo "Setting up GitHub repository..."
    
    # Check if GitHub CLI is installed
    if command -v gh &> /dev/null; then
        echo "GitHub CLI found. Creating repository..."
        
        # Check if user is authenticated
        if ! gh auth status &> /dev/null; then
            echo -e "${YELLOW}GitHub CLI not authenticated. Please run: gh auth login${NC}"
            echo "Then run this script again."
            exit 1
        fi
        
        # Check if repository already exists
        if gh repo view "${GITHUB_USER}/${REPO_NAME}" &> /dev/null; then
            echo -e "${YELLOW}Repository already exists on GitHub${NC}"
            git remote add origin "$REPO_URL" 2>/dev/null || true
        else
            # Create the repository (public, with description)
            echo "Creating public repository on GitHub..."
            if gh repo create "${REPO_NAME}" --public --description "Public notes and research materials" --remote=origin 2>/dev/null; then
                echo -e "${GREEN}Repository created on GitHub${NC}"
            else
                # If creation failed, try without setting remote (we'll add it manually)
                if gh repo create "${REPO_NAME}" --public --description "Public notes and research materials" 2>/dev/null; then
                    echo -e "${GREEN}Repository created on GitHub${NC}"
                    git remote add origin "$REPO_URL" 2>/dev/null || true
                else
                    echo -e "${RED}Failed to create repository. It may already exist.${NC}"
                    git remote add origin "$REPO_URL" 2>/dev/null || true
                fi
            fi
        fi
    else
        # GitHub CLI not installed - try using GitHub API with curl
        echo -e "${YELLOW}GitHub CLI not found. Attempting to create repository via API...${NC}"
        
        # Check if we have a GitHub token
        GITHUB_TOKEN="${GITHUB_TOKEN:-$(gh auth token 2>/dev/null || echo '')}"
        
        if [ -z "$GITHUB_TOKEN" ]; then
            # Try to get token from gh config if available
            if [ -f "$HOME/.config/gh/hosts.yml" ]; then
                echo -e "${YELLOW}No GitHub token found.${NC}"
            fi
            
            echo ""
            echo "To create the repository automatically, you have two options:"
            echo ""
            echo "Option 1: Install GitHub CLI (recommended):"
            echo "  brew install gh"
            echo "  gh auth login"
            echo "  Then run this script again"
            echo ""
            echo "Option 2: Create repository manually and set remote:"
            echo "  1. Go to https://github.com/new"
            echo "  2. Create repository 'public_notes' (public)"
            echo "  3. Run: git remote add origin $REPO_URL"
            echo "  4. Run: git push -u origin main"
            echo ""
            
            # Still set the remote URL so user can push manually
            git remote add origin "$REPO_URL" 2>/dev/null || true
            echo -e "${YELLOW}Remote 'origin' set to $REPO_URL${NC}"
            echo -e "${YELLOW}Please create the repository on GitHub and then push manually${NC}"
        else
            # Create repository using GitHub API
            echo "Creating repository using GitHub API..."
            RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
                -H "Authorization: token $GITHUB_TOKEN" \
                -H "Accept: application/vnd.github.v3+json" \
                https://api.github.com/user/repos \
                -d "{\"name\":\"$REPO_NAME\",\"description\":\"Public notes and research materials\",\"public\":true}")
            
            HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
            if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "422" ]; then
                # 201 = created, 422 = already exists (which is fine)
                if [ "$HTTP_CODE" = "422" ]; then
                    echo -e "${YELLOW}Repository already exists on GitHub${NC}"
                else
                    echo -e "${GREEN}Repository created on GitHub${NC}"
                fi
                git remote add origin "$REPO_URL"
            else
                echo -e "${RED}Failed to create repository. HTTP code: $HTTP_CODE${NC}"
                echo "Response: $(echo "$RESPONSE" | head -n-1)"
                git remote add origin "$REPO_URL" 2>/dev/null || true
                echo -e "${YELLOW}Remote set, but you may need to create the repository manually${NC}"
            fi
        fi
    fi
else
    echo -e "${YELLOW}Remote 'origin' already exists${NC}"
    CURRENT_REMOTE=$(git remote get-url origin)
    echo "Current remote: $CURRENT_REMOTE"
fi

# Create initial README if it doesn't exist
if [ ! -f "README.md" ]; then
    echo "Creating initial README.md..."
    "$SCRIPT_DIR/update_readme.sh"
fi

# Add all files
git add .

# Check if there are changes to commit
if ! git diff --staged --quiet || [ -z "$(git log --oneline 2>/dev/null)" ]; then
    git commit -m "Initial commit: Public notes repository"
    echo -e "${GREEN}Initial commit created${NC}"
else
    echo -e "${YELLOW}No changes to commit${NC}"
fi

# Set default branch to main if it doesn't exist
if ! git branch | grep -q "main"; then
    if git branch | grep -q "master"; then
        git branch -M main
        echo -e "${GREEN}Renamed branch to 'main'${NC}"
    else
        git checkout -b main
        echo -e "${GREEN}Created 'main' branch${NC}"
    fi
fi

# Try to push to GitHub
echo ""
if git remote | grep -q origin; then
    echo "Pushing to GitHub..."
    if git push -u origin main 2>/dev/null; then
        echo -e "${GREEN}Successfully pushed to GitHub!${NC}"
    elif git ls-remote --exit-code origin main &>/dev/null; then
        # Remote exists but push failed - might need to pull first
        echo -e "${YELLOW}Remote repository exists but push failed.${NC}"
        echo "Trying to pull and merge..."
        if git pull origin main --allow-unrelated-histories --no-edit 2>/dev/null; then
            git push -u origin main 2>/dev/null && echo -e "${GREEN}Successfully pushed to GitHub!${NC}" || echo -e "${YELLOW}Push still failed. You may need to resolve conflicts manually.${NC}"
        else
            echo "You may need to:"
            echo "  git pull origin main --allow-unrelated-histories"
            echo "  git push -u origin main"
        fi
    else
        # Remote doesn't exist or not accessible
        echo -e "${YELLOW}Could not push to GitHub.${NC}"
        echo "Please check your GitHub authentication and try:"
        echo "  git push -u origin main"
    fi
else
    echo -e "${YELLOW}Remote not configured. Repository may not have been created.${NC}"
fi

echo ""
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo "You can now use: publish_notes <foldername>"

