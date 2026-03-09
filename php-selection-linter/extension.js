const vscode = require('vscode');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');

function activate(context) {
    const cmd = vscode.commands.registerCommand('phpSelectionLinter.lint', async () => {
        const editor = vscode.window.activeTextEditor;
        if (!editor) return;

        const selection = editor.selection;
        if (selection.isEmpty) {
            vscode.window.showWarningMessage('PHP Linter: Select a block of code first.');
            return;
        }

        const selectedText = editor.document.getText(selection);
        const needsTag     = !selectedText.trimStart().startsWith('<?php');
        const wrapped      = needsTag ? `<?php\n${selectedText}` : selectedText;

        // Write selection to a temp file
        const tmpFile = path.join(os.tmpdir(), `php_lint_${Date.now()}.php`);
        fs.writeFileSync(tmpFile, wrapped, 'utf8');

        // Resolve php-cs-fixer binary
        const root   = vscode.workspace.workspaceFolders?.[0]?.uri?.fsPath || '';
        const local  = path.join(root, 'vendor', 'bin', 'php-cs-fixer');
        const binary = fs.existsSync(local) ? `"${local}"` : 'php-cs-fixer';

        // Resolve config file
        const configFile = path.join(root, '.php-cs-fixer.php');
        const hasConfig  = fs.existsSync(configFile);
        const inlineRules = {
            "trailing_comma_in_multiline":      { "elements": ["arrays","arguments","parameters"] },
            "no_trailing_comma_in_singleline":  true,
            "spaces_inside_parentheses":        { "space": "single" },
            "ordered_imports":                  { "sort_algorithm": "length" },
            "braces_position": {
                "functions_opening_brace":           "next_line_unless_newline_at_signature_end",
                "classes_opening_brace":             "next_line_unless_newline_at_signature_end",
                "anonymous_functions_opening_brace": "same_line",
                "control_structures_opening_brace":  "same_line"
            },
            "no_extra_blank_lines": {
                "tokens": ["extra","curly_brace_block","parenthesis_brace_block","square_brace_block","throw","use"]
            },
            "no_whitespace_in_blank_line":           true,
            "no_trailing_whitespace":                true,
            "no_blank_lines_after_class_opening":    true,
            "no_blank_lines_after_phpdoc":           true,
            "no_spaces_after_function_name":         true,
            "single_space_around_construct": {
                "constructs_followed_by_a_single_space": [
                    "abstract","as","break","case","catch","class","clone","const",
                    "continue","do","echo","else","elseif","enum","extends","finally",
                    "for","foreach","function","if","implements","include","include_once",
                    "interface","match","new","print","require","require_once","return",
                    "static","switch","throw","trait","try","use","while","yield"
                ]
            },
            "@PSR12":       true,
            "array_syntax": { "syntax": "short" },
            "single_quote": true
        };
        const configArg = hasConfig
            ? `--config="${configFile}"`
            : `--rules='${JSON.stringify(inlineRules)}'`;

        try {
            execSync(`${binary} fix "${tmpFile}" ${configArg} --allow-risky=yes`, { stdio: 'pipe' });
        } catch (err) {
            const stderr = err.stderr?.toString() || '';
            // php-cs-fixer exits 1 when it makes fixes — only fail on real errors
            if (stderr && !stderr.includes('Fixed') && !stderr.includes('fixed')) {
                vscode.window.showErrorMessage(`PHP Linter: ${stderr.split('\n')[0]}`);
                fs.unlinkSync(tmpFile);
                return;
            }
        }

        let fixed = fs.readFileSync(tmpFile, 'utf8');
        fs.unlinkSync(tmpFile);

        // Strip the <?php wrapper we added
        if (needsTag) fixed = fixed.replace(/^<\?php\r?\n/, '');

        await editor.edit(b => b.replace(selection, fixed));
        vscode.window.setStatusBarMessage('$(check) PHP block linted', 3000);
    });

    context.subscriptions.push(cmd);
}

function deactivate() {}
module.exports = { activate, deactivate };
