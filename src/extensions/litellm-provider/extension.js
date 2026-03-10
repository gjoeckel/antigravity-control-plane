const vscode = require('vscode');
const http = require('http');

const ACP_URL = "http://localhost:8000/v1/chat/completions";
const ACP_MASTER_KEY = "sk-antigravity-admin";

async function queryACP(prompt) {
    return new Promise((resolve, reject) => {
        const data = JSON.stringify({
            model: "antigravity-smart",
            messages: [{ role: "user", content: prompt }]
        });

        const options = {
            hostname: 'localhost',
            port: 8000,
            path: '/v1/chat/completions',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${ACP_MASTER_KEY}`,
                'Content-Length': data.length
            }
        };

        const req = http.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => {
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    try {
                        const response = JSON.parse(body);
                        resolve(response.choices[0].message.content);
                    } catch (e) {
                        reject(new Error("Failed to parse response from ACP"));
                    }
                } else {
                    reject(new Error(`ACP Error: ${res.statusCode} - ${body}`));
                }
            });
        });

        req.on('error', (e) => reject(new Error(`Failed to connect to ACP: ${e.message}`)));
        req.write(data);
        req.end();
    });
}

function activate(context) {
    console.log('LiteLLM Provider (MVP) is now active');

    const disposable = vscode.commands.registerCommand('ask.antigravity', async () => {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showErrorMessage('No active editor found');
            return;
        }

        const selection = editor.selection;
        const text = editor.document.getText(selection);

        if (!text) {
          vscode.window.showInformationMessage('Please select some text first');
          return;
        }

        vscode.window.withProgress({
            location: vscode.ProgressLocation.Notification,
            title: "Asking Antigravity Control Plane...",
            cancellable: false
        }, async (progress) => {
            try {
                const result = await queryACP(text);
                
                // Show result in a new webview or output channel?
                // For MVP, just show in a message box, but long responses might be cut off.
                const panel = vscode.window.createWebviewPanel(
                  'antigravityResponse',
                  'Antigravity ACP Response',
                  vscode.ViewColumn.Beside,
                  {}
                );
                panel.webview.html = `<html><body><pre>${result}</pre></body></html>`;
                
            } catch (error) {
                vscode.window.showErrorMessage(error.message);
            }
        });
    });

    context.subscriptions.push(disposable);
}

function deactivate() {}

module.exports = {
    activate,
    deactivate
};
