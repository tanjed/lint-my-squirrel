# PHP Selection Linter

> Select PHP code → press `Ctrl+Shift+L` → it gets linted. Nothing else is touched.

## Quick Install

```bash
git clone https://github.com/tanjed/lint-my-squirrel.git
cd lint-my-squirrel
bash install.sh /path/to/your/project
```

That's it. Reload VS Code and you're ready.

---

## What it fixes

| Rule | Before | After |
|------|--------|-------|
| Trailing comma | `'foo'` | `'foo',` |
| Space in `if` | `if($x){` | `if ( $x ) {` |
| Imports by length | long imports first | short imports first |
| Brace on next line | `function foo() {` | brace moves to next line |
| Remove unnecessary blank lines | multiple empty lines | collapsed to one |
| No blank line after `}` | blank line after closing brace | removed |
| Space before `{` and `()` | `function foo(){` / `if($x){` | `function foo() {` / `if ($x) {` |

## Usage

1. Open any `.php` file
2. Select a block of code
3. Press `Ctrl+Shift+L` (Mac: `Cmd+Shift+L`)

## Requirements

- PHP 8.x
- Composer
- Node.js 18+
- VS Code

## Project structure

```
php-selection-linter/
├── install.sh                     ← run this once
├── config/
│   ├── .php-cs-fixer.php          ← linting rules
│   └── vscode-settings.json       ← copied to .vscode/
└── php-selection-linter/
    ├── extension.js               ← VS Code extension
    └── package.json
```
