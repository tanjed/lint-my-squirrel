#!/usr/bin/env bash
# =============================================================
#  PHP Selection Linter — One-command installer
#  Usage: bash install.sh [/path/to/your/project]
# =============================================================

set -e

# ── Colours ──────────────────────────────────────────────────
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'
B='\033[0;34m'; C='\033[0;36m'; W='\033[1;37m'; N='\033[0m'

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-$(pwd)}"

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

# ── 1. Check prerequisites ────────────────────────────────────
step "Checking prerequisites"

command -v php  &>/dev/null && ok "PHP found ($(php -r 'echo phpversion();'))" || fail "PHP not found. Install PHP 8.x first."
command -v composer &>/dev/null && ok "Composer found" || {
  warn "Composer not found — installing globally..."
  php -r "copy('https://getcomposer.org/installer','composer-setup.php');"
  php composer-setup.php --quiet
  php -r "unlink('composer-setup.php');"
  sudo mv composer.phar /usr/local/bin/composer 2>/dev/null || mv composer.phar "$HOME/.local/bin/composer"
  ok "Composer installed"
}
command -v node &>/dev/null && ok "Node.js found ($(node -v))" || fail "Node.js not found. Install Node.js 18+ first: https://nodejs.org"
command -v code &>/dev/null && ok "VS Code CLI found" || fail "'code' CLI not found.\nOpen VS Code → Cmd/Ctrl+Shift+P → 'Install code command in PATH', then re-run."

# ── 2. Install php-cs-fixer into project ─────────────────────
step "Installing php-cs-fixer into your project"
echo -e "  ${W}Project:${N} $PROJECT_DIR"

cd "$PROJECT_DIR"

if [ ! -f "composer.json" ]; then
  composer init --no-interaction --name="project/app" --stability="dev" -q
  ok "composer.json created"
fi

if [ -f "vendor/bin/php-cs-fixer" ]; then
  ok "php-cs-fixer already installed — skipping"
else
  composer require --dev friendsofphp/php-cs-fixer --no-interaction -q
  ok "php-cs-fixer installed via Composer"
fi

# ── 3. Copy .php-cs-fixer.php config ─────────────────────────
step "Copying linter config to project"

cp "$REPO_DIR/config/.php-cs-fixer.php" "$PROJECT_DIR/.php-cs-fixer.php"
ok ".php-cs-fixer.php copied to project root"

# ── 4. Copy .vscode/settings.json ────────────────────────────
step "Setting up VS Code workspace settings"

mkdir -p "$PROJECT_DIR/.vscode"

SETTINGS="$PROJECT_DIR/.vscode/settings.json"
if [ -f "$SETTINGS" ]; then
  # Merge — back up existing first
  cp "$SETTINGS" "$SETTINGS.bak"
  warn "Existing settings.json backed up → settings.json.bak"
fi

cp "$REPO_DIR/config/vscode-settings.json" "$SETTINGS"
ok ".vscode/settings.json written"

# ── 5. Package & install the VS Code extension ───────────────
step "Building & installing VS Code extension"

EXT_DIR="$REPO_DIR/php-selection-linter"

cd "$EXT_DIR"

# Install vsce if missing
if ! npx --yes vsce --version &>/dev/null 2>&1; then
  npm install --save-dev @vscode/vsce -q
fi

ok "Dependencies ready"

# Package
npx vsce package --no-dependencies --out "$EXT_DIR/php-selection-linter.vsix" -q 2>/dev/null || \
  npx @vscode/vsce package --no-dependencies --out "$EXT_DIR/php-selection-linter.vsix" -q

ok "Extension packaged"

# Install into VS Code
code --install-extension "$EXT_DIR/php-selection-linter.vsix" --force
ok "Extension installed into VS Code"

# ── Done ─────────────────────────────────────────────────────
cd "$PROJECT_DIR"
echo -e ""
echo -e "${C}╔══════════════════════════════════════════════╗${N}"
echo -e "${C}║              Installation complete!          ║${N}"
echo -e "${C}╚══════════════════════════════════════════════╝${N}"
echo -e ""
echo -e "  ${W}How to use:${N}"
echo -e "  1. Open any ${G}.php${N} file in VS Code"
echo -e "  2. ${W}Select${N} any block of code"
echo -e "  3. Press ${Y}Ctrl+Shift+L${N}  (Mac: ${Y}Cmd+Shift+L${N})"
echo -e "  4. Selected code is ${G}auto-linted${N} instantly ✔"
echo -e ""
echo -e "  ${W}Linting rules applied:${N}"
echo -e "  ${G}•${N} Trailing comma after every array element"
echo -e "  ${G}•${N} Space inside if condition parentheses"
echo -e "  ${G}•${N} Imports sorted by length"
echo -e "  ${G}•${N} Method/class { on the next line"
echo -e ""
echo -e "  ${Y}Reload VS Code for the extension to activate.${N}"
echo -e ""
