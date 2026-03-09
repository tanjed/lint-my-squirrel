#!/usr/bin/env bash
# =============================================================
#  PHP Selection Linter — One-command installer
#  Usage: bash install.sh
#  No PHP or Composer required!
# =============================================================

set -e

# ── Colours ──────────────────────────────────────────────────
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'
B='\033[0;34m'; C='\033[0;36m'; W='\033[1;37m'; N='\033[0m'

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Banner ───────────────────────────────────────────────────
echo -e ""
echo -e "${C}╔══════════════════════════════════════════════╗${N}"
echo -e "${C}║       PHP Selection Linter — Installer       ║${N}"
echo -e "${C}║  Select code → Ctrl+Shift+L → auto linted    ║${N}"
echo -e "${C}╚══════════════════════════════════════════════╝${N}"
echo -e ""

# ── Step helpers ─────────────────────────────────────────────
step()  { echo -e "\n${B}▶ $1${N}"; }
ok()    { echo -e "  ${G}✔ $1${N}"; }
warn()  { echo -e "  ${Y}⚠ $1${N}"; }
fail()  { echo -e "  ${R}✘ $1${N}"; exit 1; }

# ── 1. Check prerequisites ───────────────────────────────────
step "Checking prerequisites"

if command -v node &>/dev/null; then
    ok "Node.js found ($(node -v))"
else
    fail "Node.js not found. Install Node.js 18+ first: https://nodejs.org"
fi

if command -v code &>/dev/null; then
    ok "VS Code CLI found"
else
    fail "'code' CLI not found.\nOpen VS Code → Cmd/Ctrl+Shift+P → 'Install code command in PATH', then re-run."
fi

# ── 2. Install dependencies ──────────────────────────────────
step "Installing dependencies"

EXT_DIR="$REPO_DIR/php-selection-linter"
cd "$EXT_DIR"

if [ -d "node_modules" ]; then
    ok "Dependencies already installed"
else
    echo -e "  ${W}Installing prettier and PHP plugin...${N}"
    npm install --production
    ok "Dependencies installed"
fi

# ── 3. Package & install the VS Code extension ───────────────
step "Building & installing VS Code extension"

echo -e "  ${W}Packaging extension...${N}"
npx @vscode/vsce package --out "$EXT_DIR/php-selection-linter.vsix" 2>&1 | grep -E "(DONE|ERROR|WARNING)" || true
ok "Extension packaged"

# Install into VS Code
code --install-extension "$EXT_DIR/php-selection-linter.vsix" --force
ok "Extension installed into VS Code"

# ── Done ─────────────────────────────────────────────────────
cd "$REPO_DIR"
echo -e ""
echo -e "${C}╔══════════════════════════════════════════════╗${N}"
echo -e "${C}║              Installation complete!          ║${N}"
echo -e "${C}╚══════════════════════════════════════════════╝${N}"
echo -e ""
echo -e "  ${W}How to use:${N}"
echo -e "  1. Open any ${G}.php${N} file in VS Code"
echo -e "  2. ${W}Select${N} any block of code"
echo -e "  3. Press ${Y}Ctrl+Shift+L${N}  (Mac: ${Y}Cmd+Shift+L${N})"
echo -e "  4. Selected code is ${G}auto-linted${N} instantly"
echo -e ""
echo -e "  ${W}Features:${N}"
echo -e "  ${G}•${N} No PHP installation required"
echo -e "  ${G}•${N} No Composer required"
echo -e "  ${G}•${N} Works globally on any PHP file"
echo -e "  ${G}•${N} Uses Prettier with PHP plugin"
echo -e ""
echo -e "  ${Y}Reload VS Code for the extension to activate.${N}"
echo -e ""
