const vscode = require('vscode');
const http = require('http');

/**
 * ACP Phase 3: Enhanced UX & Observability
 * Implements: Inline Completions, Streaming Chat, and AND-TRACE Headers.
 */

let modelCache = [];

function activate(context) {
    console.log('Antigravity Control Plane (ACP) Extension Active');

    // 1. Dynamic Model Discovery
    fetchModels();

    // 2. Inline Completion Provider (antigravity-fast)
    const completionProvider = vscode.languages.registerInlineCompletionItemProvider(
        { pattern: '**' },
        {
            provideInlineCompletionItems: async (document, position, context, token) => {
                // 300ms Debounce logic
                await new Promise(resolve => setTimeout(resolve, 300));
                if (token.isCancellationRequested) return;

                const textBefore = document.getText(
                    new vscode.Range(new vscode.Position(Math.max(0, position.line - 5), 0), position)
                );

                try {
                    const response = await callACPProxy('antigravity-fast', textBefore);
                    return [new vscode.InlineCompletionItem(response)];
                } catch (err) {
                    console.error('ACP Completion Error:', err);
                    return [];
                }
            }
        }
    );

    // 3. Streaming Chat Command (antigravity-smart)
    const chatCommand = vscode.commands.registerCommand('ask.antigravity', async () => {
        const panel = vscode.window.createWebviewPanel(
            'acpChat',
            'Antigravity Chat',
            vscode.ViewColumn.Two,
            { enableScripts: true }
        );

        panel.webview.html = getChatHtml();

        panel.webview.onDidReceiveMessage(async (message) => {
            if (message.command === 'sendPrompt') {
                await handleStreamingChat(message.text, panel);
            }
        });
    });

    context.subscriptions.push(completionProvider, chatCommand);
}

/**
 * Standardized Tracing (AND-TRACE)
 * Injects tracing headers for PostgreSQL logging.
 */
async function callACPProxy(modelAlias, prompt, stream = false) {
    const traceId = `trace-${Math.random().toString(36).substring(2, 11)}`;
    const sessionId = vscode.env.sessionId;

    return new Promise((resolve, reject) => {
        const reqData = JSON.stringify({
            model: modelAlias,
            messages: [{ role: 'user', content: prompt }],
            stream: stream
        });

        const options = {
            hostname: 'localhost',
            port: 8000,
            path: '/v1/chat/completions',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer sk-antigravity-admin', // Master Key
                'X-AND-TRACE': traceId,
                'X-AND-SESSION': sessionId
            }
        };

        const req = http.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => { data += chunk; });
            res.on('end', () => {
                try {
                    const json = JSON.parse(data);
                    resolve(json.choices[0].message.content);
                } catch (e) { reject(e); }
            });
        });

        req.on('error', reject);
        req.write(reqData);
        req.end();
    });
}

/**
 * Implements Streaming UI updates for the Webview
 */
async function handleStreamingChat(prompt, panel) {
    const traceId = `trace-chat-${Date.now()}`;
    const options = {
        hostname: 'localhost',
        port: 8000,
        path: '/v1/chat/completions',
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer sk-antigravity-admin',
            'X-AND-TRACE': traceId,
            'X-AND-SESSION': vscode.env.sessionId
        }
    };

    const req = http.request(options, (res) => {
        res.on('data', (chunk) => {
            // Process SSE (Server-Sent Events) chunks
            const lines = chunk.toString().split('\n');
            for (const line of lines) {
                if (line.startsWith('data: ')) {
                    try {
                        const data = JSON.parse(line.slice(6));
                        const content = data.choices[0]?.delta?.content || '';
                        panel.webview.postMessage({ command: 'contentChunk', text: content });
                    } catch (e) { /* End of stream */ }
                }
            }
        });
    });

    req.write(JSON.stringify({
        model: 'antigravity-smart',
        messages: [{ role: 'user', content: prompt }],
        stream: true
    }));
    req.end();
}

async function fetchModels() {
    try {
        const response = await new Promise((resolve, reject) => {
            http.get('http://localhost:8000/v1/models', (res) => {
                let data = '';
                res.on('data', d => data += d);
                res.on('end', () => resolve(JSON.parse(data)));
            }).on('error', reject);
        });
        modelCache = response.data.map(m => m.id);
        console.log('ACP Discovered Models:', modelCache);
    } catch (err) {
        console.error('ACP Discovery Failed:', err);
    }
}

function getChatHtml() {
    return `<!DOCTYPE html>
    <html>
    <body style="padding: 20px; font-family: sans-serif;">
        <h3>Antigravity Smart Chat</h3>
        <div id="chat" style="background: #1e1e1e; padding: 10px; min-height: 200px; margin-bottom: 10px; border-radius: 4px;"></div>
        <input type="text" id="input" style="width: 80%; background: #333; color: white; border: none; padding: 5px;" placeholder="Enter prompt...">
        <button onclick="send()" style="padding: 5px 10px; cursor: pointer;">Send</button>

        <script>
            const vscode = acquireVsCodeApi();
            const chatDiv = document.getElementById('chat');
            const input = document.getElementById('input');

            function send() {
                const text = input.value;
                chatDiv.innerHTML += '<p><b>You:</b> ' + text + '</p>';
                vscode.postMessage({ command: 'sendPrompt', text: text });
                input.value = '';
            }

            window.addEventListener('message', event => {
                if (event.data.command === 'contentChunk') {
                    chatDiv.innerHTML += event.data.text;
                }
            });
        </script>
    </body>
    </html>`;
}

function deactivate() {}

module.exports = { activate, deactivate };
