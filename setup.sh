#!/usr/bin/env bash
# Portfolio Monitor — one-shot Claude Code setup
# Usage: bash setup.sh [target-folder]
# If you omit target-folder it'll set up in ./portfolio-monitor next to this script.

set -e

TARGET="${1:-./portfolio-monitor}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "  Portfolio Monitor — Claude Code setup"
echo "  ======================================"
echo ""

# 1) Verify Claude Code is installed
if ! command -v claude &> /dev/null; then
  echo "  Claude Code is not installed."
  echo "  Install it from https://docs.claude.com/claude-code then re-run this script."
  echo ""
  echo "  Quick install (Mac/Linux):"
  echo "    curl -fsSL https://claude.ai/install.sh | sh"
  echo ""
  exit 1
fi
echo "  Claude Code found: $(command -v claude)"

# 2) Build the target folder
echo ""
echo "  Creating project at: $TARGET"
mkdir -p "$TARGET"
cp -R "$SCRIPT_DIR"/CLAUDE.md "$TARGET/"
cp -R "$SCRIPT_DIR"/index.html "$TARGET/"
[ -f "$SCRIPT_DIR/render.yaml" ] && cp "$SCRIPT_DIR/render.yaml" "$TARGET/"
[ -f "$SCRIPT_DIR/sample_data.xlsx" ] && cp "$SCRIPT_DIR/sample_data.xlsx" "$TARGET/"
[ -f "$SCRIPT_DIR/portco_template.csv" ] && cp "$SCRIPT_DIR/portco_template.csv" "$TARGET/"
mkdir -p "$TARGET/public"
cp "$SCRIPT_DIR/index.html" "$TARGET/public/index.html"

# 3) Initialize git so Claude Code's tools work cleanly
cd "$TARGET"
if [ ! -d ".git" ]; then
  git init -q
  cat > .gitignore <<'EOF'
.DS_Store
node_modules/
*.log
.env
.env.local
EOF
  git add -A
  git commit -q -m "initial commit — portfolio monitor handoff from Cowork"
  echo "  Git initialized + first commit done."
else
  echo "  Git already initialized — skipping."
fi

# 4) Print next steps
cat <<EOF

  ✓ Setup complete.

  Next steps:

    cd $TARGET
    claude

  Claude Code will auto-load CLAUDE.md as project context. You can immediately ask things like:
    "Walk me through what this dashboard does."
    "Help me deploy this to Render."
    "Add a chart for customer concentration."

  Optional — wire up the Render MCP for AI-driven deploys:

    claude mcp add --transport http render https://mcp.render.com/mcp \\
      --header "Authorization: Bearer YOUR_RENDER_API_KEY"

  Get your Render API key from:
    https://dashboard.render.com/u/settings#api-keys

  Optional — wire up the GitHub MCP for AI-driven repo/PR management:

    claude mcp add --transport http github https://api.github.com/mcp \\
      --header "Authorization: Bearer YOUR_GITHUB_PAT"

  To open the dashboard in your browser right now:
    open $TARGET/index.html

EOF
