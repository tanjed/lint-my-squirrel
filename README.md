# PHP Selection Linter

> Select PHP code -> press `Ctrl+Shift+L` -> it gets linted. Nothing else is touched.

**No PHP or Composer required!** Uses Prettier under the hood.

## Quick Install

```bash
git clone https://github.com/tanjed/lint-my-squirrel.git
cd lint-my-squirrel
bash install.sh
```

That's it. Reload VS Code and you're ready.

---

## Linting Rules

The extension uses Prettier with the PHP plugin. Here are all the formatting rules applied:

### Spacing & Braces

| Rule | Before | After |
|------|--------|-------|
| Space after keywords | `if($x){` | `if ($x) {` |
| Space in control structures | `foreach($arr as $item)` | `foreach ($arr as $item)` |
| Function call spacing | `foo ()` | `foo()` |
| Array spacing | `['a','b']` | `['a', 'b']` |
| Brace style (PSR-2) | `function foo() {` | `function foo()\n{` |
| Class brace | `class Foo {` | `class Foo\n{` |
| Closure brace | `function() {` | `function () {` |

### Quotes & Commas

| Rule | Before | After |
|------|--------|-------|
| Single quotes | `"hello"` | `'hello'` |
| Trailing commas | `['a', 'b']` | `['a', 'b',]` |
| Trailing commas in functions | `fn($a, $b)` | `fn($a, $b,)` |

### Arrays & Arguments

| Rule | Before | After |
|------|--------|-------|
| Array elements spacing | `[1,2,3]` | `[1, 2, 3]` |
| Long arrays (multi-line) | Inconsistent | Consistent indentation |
| Argument lists | `fn($a,$b,$c)` | `fn($a, $b, $c)` |

### Operators & Keywords

| Rule | Before | After |
|------|--------|-------|
| Binary operators | `$x+$y` | `$x + $y` |
| Arrow function | `fn($x)=>$x*2` | `fn ($x) => $x * 2` |
| Null coalescing | `$x??$y` | `$x ?? $y` |
| Type hints | `?string` | `?string` (preserved) |
| Union types | `string\|int` | `string \| int` |

### Line Formatting

| Rule | Before | After |
|------|--------|-------|
| Print width | Long lines | Wrapped at 120 chars |
| Indentation | Mixed tabs/spaces | 4 spaces |
| Semicolons | Missing or extra | Proper placement |
| Blank lines | Multiple empty lines | Single blank line |

### Imports & Namespace

| Rule | Before | After |
|------|--------|-------|
| Use statements | `use Foo\Bar;` | Consistent spacing |
| Namespace | `namespace Foo;` | Proper formatting |
| Grouped imports | `use Foo\{A, B};` | Consistent style |

### PHP Tags

| Rule | Before | After |
|------|--------|-------|
| Opening tag | `<?` | `<?php` |
| Closing tag removal | `?>\n` | Removed (if only PHP) |
| Short echo | `<?php echo $x; ?>` | `<?= $x ?>` |

---

## Configuration

The extension uses these Prettier options:

```javascript
{
    printWidth: 120,      // Line wrap at 120 chars
    tabWidth: 4,          // 4 spaces per indent
    useTabs: false,       // Use spaces, not tabs
    singleQuote: true,    // Prefer single quotes
    trailingComma: 'all', // Always add trailing commas
    braceStyle: 'psr-2',  // PSR-2 brace placement
    phpVersion: '8.1',    // Target PHP 8.1
}
```

## Usage

1. Open any `.php` file
2. Select a block of code
3. Press `Ctrl+Shift+L` (Mac: `Cmd+Shift+L`)

## Requirements

- **Node.js 18+**
- **VS Code** with `code` CLI in PATH

That's it! No PHP, no Composer, no Docker needed.

## Project structure

```
lint-my-squirrel/
├── install.sh                     ← run this once
└── php-selection-linter/
    ├── extension.js               ← VS Code extension
    ├── package.json
    └── node_modules/              ← prettier + plugin (installed)
```

## How it works

The extension uses [Prettier](https://prettier.io/) with [@prettier/plugin-php](https://github.com/prettier/plugin-php) to format PHP code. Everything is bundled in the extension - no external dependencies needed.
