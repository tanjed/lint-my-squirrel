const vscode = require('vscode');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');

// Prettier PHP formatting options
const prettierOptions = {
    parser: 'php',
    plugin: '@prettier/plugin-php',
    printWidth: 120,
    tabWidth: 4,
    useTabs: false,
    singleQuote: true,
    trailingComma: 'all',
    braceStyle: 'psr-2',
    phpVersion: '8.1',
};

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
        const needsTag = !selectedText.trimStart().startsWith('<?php');
        const wrapped = needsTag ? `<?php\n${selectedText}` : selectedText;

        // Write selection to a temp file
        const tmpFile = path.join(os.tmpdir(), `php_lint_${Date.now()}.php`);
        fs.writeFileSync(tmpFile, wrapped, 'utf8');

        try {
            // Get the extension's node_modules path
            const extensionPath = context.extensionPath;
            const nodeModulesPath = path.join(extensionPath, 'node_modules');

            // Run prettier using node
            const optionsJson = JSON.stringify(prettierOptions).replace(/"/g, '\\"');
            const script = `
                const prettier = require('prettier');
                const phpPlugin = require('@prettier/plugin-php');
                const fs = require('fs');
                const filePath = process.argv[2];
                const options = ${JSON.stringify(prettierOptions)};
                const input = fs.readFileSync(filePath, 'utf8');
                prettier.format(input, {
                    ...options,
                    plugins: [phpPlugin],
                }).then(result => {
                    fs.writeFileSync(filePath, result, 'utf8');
                }).catch(err => {
                    console.error(err.message);
                    process.exit(1);
                });
            `;

            execSync(`node -e '${script.replace(/'/g, "'\"'\"'")}' "${tmpFile}"`, {
                stdio: 'pipe',
                cwd: extensionPath,
                env: { ...process.env, NODE_PATH: nodeModulesPath }
            });
        } catch (err) {
            const stderr = err.stderr?.toString() || '';
            if (stderr) {
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
