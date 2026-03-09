# PHP Selection Linter — Project Context Prompt
# Use this prompt to resume work on this project in a future session.
# Paste this entire file as your first message, then describe what you want to add or change.

---

## Project Overview

This is a **VS Code extension + shell installer** that lints only a **selected block of PHP code** when the user presses `Ctrl+Shift+L` (Mac: `Cmd+Shift+L`). It does NOT format on save and does NOT touch the rest of the file — only the selected text is replaced with the linted version.

The linting engine is **php-cs-fixer** (`friendsofphp/php-cs-fixer`), installed per-project via Composer. The VS Code extension is a **custom locally-installed `.vsix`** built from source using `@vscode/vsce`.

---

## Project File Structure

```
php-selection-linter/
├── install.sh                          ← single one-command installer (bash)
├── README.md                           ← usage docs
├── .gitignore
│
├── config/
│   ├── .php-cs-fixer.php               ← all linting rules (php-cs-fixer config)
│   └── vscode-settings.json            ← copied to .vscode/settings.json in user's project
│
└── php-selection-linter/               ← VS Code extension source
    ├── extension.js                    ← extension logic (Node.js)
    └── package.json                    ← extension manifest + keybinding
```

---

## How It Works (Technical Flow)

1. User selects PHP code in VS Code and presses `Ctrl+Shift+L`
2. `extension.js` captures the selected text
3. If the selection doesn't start with `<?php`, it prepends `<?php\n` so php-cs-fixer can parse it
4. The wrapped code is written to a **temp file** (`os.tmpdir()/php_lint_<timestamp>.php`)
5. The extension runs: `php-cs-fixer fix "<tmpfile>" --config="<project>/.php-cs-fixer.php" --allow-risky=yes`
6. If `.php-cs-fixer.php` is not found in the workspace root, it falls back to **inline JSON rules** passed via `--rules='...'`
7. The fixed content is read back from the temp file
8. The `<?php\n` wrapper is stripped if it was added
9. The selection in the editor is **replaced** with the fixed content
10. The temp file is deleted
11. A status bar message `$(check) PHP block linted` appears for 3 seconds

---

## install.sh — What It Does Step by Step

1. **Checks prerequisites**: PHP 8.x, Composer (auto-installs if missing), Node.js 18+, VS Code `code` CLI
2. **Installs php-cs-fixer** via `composer require --dev friendsofphp/php-cs-fixer` into the target project
3. **Copies** `config/.php-cs-fixer.php` → `<project>/.php-cs-fixer.php`
4. **Copies** `config/vscode-settings.json` → `<project>/.vscode/settings.json` (backs up existing)
5. **Packages** the VS Code extension using `npx vsce package --no-dependencies`
6. **Installs** the `.vsix` into VS Code using `code --install-extension`

Usage: `bash install.sh [/path/to/your/php/project]`
If no path is given, it uses the current working directory.

---

## config/.php-cs-fixer.php — All 7 Linting Rules

### Rule 1 — Trailing comma after every array element
- **php-cs-fixer rules**: `trailing_comma_in_multiline`, `no_trailing_comma_in_singleline`
- **What it does**: Adds a trailing comma after the last element in multiline arrays, function arguments, and parameters. Keeps single-line arrays/calls clean (no trailing comma on one-liners).
- **Before**: `['foo', 'bar']` (multiline, no trailing comma)
- **After**: `['foo', 'bar',]` (multiline, trailing comma added)

### Rule 2 — Space inside `if` condition parentheses
- **php-cs-fixer rules**: `spaces_inside_parentheses` with `space: single`, `no_spaces_inside_parenthesis: false`
- **What it does**: Adds a single space after `(` and before `)` in all control structure conditions.
- **Before**: `if($x)`, `foreach($items as $k)`
- **After**: `if ( $x )`, `foreach ( $items as $k )`

### Rule 3 — Imports sorted by length, shortest first
- **php-cs-fixer rules**: `ordered_imports` with `sort_algorithm: length`, `no_unused_imports`, `single_import_per_statement`, `no_leading_import_slash`
- **What it does**: Sorts all `use` import statements by string length ascending (shortest `use` line at the top).
- **Before**: Long imports listed first or randomly
- **After**: Short `use App\Models\User;` before long `use App\Http\Controllers\Api\UserController;`

### Rule 4 — Method/class opening brace on the next line
- **php-cs-fixer rules**: `braces_position` with `functions_opening_brace: next_line_unless_newline_at_signature_end`, `classes_opening_brace: next_line_unless_newline_at_signature_end`, `anonymous_functions_opening_brace: same_line`, `control_structures_opening_brace: same_line`
- **What it does**: Moves the `{` to the next line for named functions, methods, and classes. Anonymous functions/closures keep `{` on the same line. `if`, `for`, `foreach` etc. also keep `{` on the same line.
- **Before**: `function foo() {`
- **After**: `function foo()\n{`

### Rule 5 — Remove unnecessary blank lines and whitespace
- **php-cs-fixer rules**: `no_extra_blank_lines` (tokens: extra, blank_line_before_statement, curly_brace_block, parenthesis_brace_block, square_brace_block, throw, use), `no_whitespace_in_blank_line`, `no_trailing_whitespace`, `compact_nullable_type_declaration`, `no_spaces_after_function_name`
- **What it does**: Collapses multiple consecutive blank lines into one. Strips spaces from blank lines. Strips trailing whitespace from all lines. Removes blank lines inside `{}`, `()`, `[]` blocks.
- **Before**: 3 blank lines between statements, spaces on empty lines, trailing spaces
- **After**: Max 1 blank line, clean whitespace throughout

### Rule 6 — No blank line after closing `}` or end of if/class blocks
- **php-cs-fixer rules**: `no_blank_lines_after_class_opening`, `no_blank_lines_after_phpdoc`, `class_attributes_separation` (method: one, property: none), `function_declaration` (closure_function_spacing: none, closure_fn_spacing: none)
- **What it does**: Removes blank lines right after `class Foo {`. Removes blank lines between a docblock and its declaration. Enforces exactly one blank line between methods. Removes blank lines between consecutive property declarations.
- **Before**: Blank line after `class Foo {`, blank line after `/** docblock */`
- **After**: Code immediately follows class opening brace and docblocks

### Rule 7 — Space before `{` and before `()`
- **php-cs-fixer rules**: `single_space_around_construct` with a full list of PHP constructs
- **What it does**: Ensures a single space after every PHP keyword before a `(` or `{`. Covers: `if`, `else`, `elseif`, `for`, `foreach`, `while`, `do`, `switch`, `match`, `catch`, `finally`, `function`, `class`, `interface`, `trait`, `enum`, `return`, `throw`, `new`, `echo`, `print`, `use`, `static`, `abstract`, `extends`, `implements`, `instanceof`, etc.
- **Before**: `if($x){`, `foreach($items as $i){`, `function foo(){`
- **After**: `if ( $x ) {`, `foreach ( $items as $i ) {`, `function foo() {`

---

## extension.js — Key Implementation Details

- **Command ID**: `phpSelectionLinter.lint`
- **Keybinding**: `ctrl+shift+l` / `cmd+shift+l`, only active `when: editorTextFocus && editorLangId == php && editorHasSelection`
- **Binary resolution**: First checks `<workspaceRoot>/vendor/bin/php-cs-fixer` (local Composer install), falls back to global `php-cs-fixer`
- **Config resolution**: Looks for `<workspaceRoot>/.php-cs-fixer.php`. If not found, uses hardcoded inline JSON rules via `--rules='...'`
- **Error handling**: php-cs-fixer exits with code 1 when it makes changes (not an error). Only shows an error if `stderr` contains actual error text that doesn't include "Fixed"/"fixed"
- **The inline fallback rules** in `extension.js` must always mirror the rules in `config/.php-cs-fixer.php` — both files must be kept in sync when adding/removing rules

---

## package.json (Extension Manifest)

```json
{
  "name": "php-selection-linter",
  "displayName": "PHP Selection Linter",
  "version": "1.0.0",
  "publisher": "local",
  "engines": { "vscode": "^1.75.0" },
  "activationEvents": ["onLanguage:php"],
  "main": "./extension.js",
  "contributes": {
    "commands": [{ "command": "phpSelectionLinter.lint", "title": "PHP: Lint Selected Block" }],
    "keybindings": [{
      "command": "phpSelectionLinter.lint",
      "key": "ctrl+shift+l",
      "mac": "cmd+shift+l",
      "when": "editorTextFocus && editorLangId == php && editorHasSelection"
    }]
  }
}
```

---

## Important Constraints & Gotchas

1. **Both files must stay in sync**: When adding a new rule, it must be added to BOTH `config/.php-cs-fixer.php` AND the `inlineRules` object in `extension.js`. The inline rules are the fallback when `.php-cs-fixer.php` is not present in the user's project root.

2. **php-cs-fixer exit codes**: It exits `0` when no changes were made, `1` when changes were made, `2` on error. The `try/catch` in `extension.js` must not treat exit code `1` as an error.

3. **The `<?php` wrapper**: The extension wraps selected code with `<?php\n` before writing to the temp file, because php-cs-fixer requires valid PHP file syntax. It is stripped before replacing the selection. This means selected code that is mid-function or mid-class is handled correctly.

4. **`--allow-risky=yes`**: Required flag because some rules (like `no_unused_imports`) are considered "risky" by php-cs-fixer.

5. **`vscode-settings.json`**: Currently only sets `editor.formatOnSave: false` for PHP files. This intentionally disables any other formatter so that only the manual `Ctrl+Shift+L` trigger is used.

6. **Keybinding conflict**: `Ctrl+Shift+L` is VS Code's default "Select All Occurrences" shortcut. The extension's `when` clause (`editorHasSelection && editorLangId == php`) means it only overrides the default in PHP files when text is already selected.

7. **`no_spaces_after_function_name: true`** (Rule 5): This removes the space between a function name and its `(`. e.g. `foo ()` → `foo()`. This conflicts slightly with Rule 7's spacing intent but only applies to function *calls*, not declarations.

---

## How to Resume / Make Changes

When you want to update this project, paste this entire file as your first message, then say something like:

- "Add a new rule: ..." → update `config/.php-cs-fixer.php` and `inlineRules` in `extension.js`, bump version in `package.json`, update `install.sh` banner rules list and `README.md` table
- "Change the keybinding to ..." → update `package.json` `keybindings` section
- "Add support for blade files" → remove `->notName('*.blade.php')` from finder, note caveats
- "Make the installer work on Windows" → update `install.sh` with PowerShell alternatives or add `install.ps1`
- "Bump the extension version" → update `version` in `package.json`
- "Add a new file to the zip" → create the file, add it to the `zip` command exclusions if needed
- After any changes, always rebuild the zip: `cd /home/claude && zip -r /mnt/user-data/outputs/php-selection-linter.zip php-selection-linter --exclude "php-selection-linter/.git/*"`
