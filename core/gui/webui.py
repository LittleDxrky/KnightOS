#!/usr/bin/env python3
"""
KnightOS Web UI – версия с JSON API.
"""

import http.server, subprocess, os, json, urllib.parse, webbrowser, base64

os.environ['NO_AT_BRIDGE'] = '1'

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PORT = 8080
sudo_password = None

HTML = r"""<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KnightOS Control Panel</title>
    <style>
        :root {
            --bg: #1e1e1e; --pnl: #2d2d2d; --fg: #d4d4d4; --ac: #375a7f;
            --ok: #4caf50; --wn: #ff9800; --fl: #f44336; --in: #2196f3;
            --cbg: #1a1a1a; --btn-fg: #fff; --input-bg: #1a1a1a; --input-fg: #d4d4d4;
            --section-border: #555; --btn-hover: #4a6fa5;
            --font-family: 'Consolas', monospace; --font-size: 24px;
            --shadow: 0 4px 15px rgba(0,0,0,0.5);
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: var(--font-family); font-size: var(--font-size);
            background: var(--bg); color: var(--fg);
            display: flex; height: 100vh; overflow: hidden;
        }
        .dashboard { display: flex; width: 100%; height: 100%; }
        .panel { display: flex; flex-direction: column; }
        .panel-header {
            padding: 12px 20px; background: var(--pnl); font-weight: bold;
            font-size: 1.2em; color: #ccc; border-bottom: 1px solid #444;
            cursor: grab; user-select: none; letter-spacing: 1px;
            display: flex; align-items: center; gap: 10px;
        }
        .panel-header:active { cursor: grabbing; }
        .panel-body { flex: 1; overflow-y: auto; padding: 20px; background: var(--pnl); }
        #sidebar { width: 300px; min-width: 220px; background: var(--pnl); box-shadow: var(--shadow); border-right: 1px solid #444; order: 0; }
        #sidebar .panel-body { display: flex; flex-direction: column; gap: 25px; }
        .group-title {
            font-size: 0.7em; text-transform: uppercase; color: #aaa;
            margin-bottom: 10px; padding-bottom: 5px;
            border-bottom: 1px solid #3a3a3a; letter-spacing: 1.5px;
        }
        .sidebar-btn {
            display: block; width: 100%; margin: 6px 0; padding: 12px 15px;
            border: none; border-radius: 8px; background: var(--ac);
            color: var(--btn-fg); cursor: pointer; font-size: 0.9em;
            text-align: left; transition: all 0.2s; box-shadow: 0 2px 8px rgba(0,0,0,0.3);
        }
        .sidebar-btn:hover {
            background: var(--btn-hover); transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.5);
        }
        .sidebar select, .sidebar input {
            width: 100%; margin: 8px 0; padding: 12px;
            background: var(--input-bg); border: 1px solid #555; border-radius: 8px;
            color: var(--input-fg); font: 0.8em 'Consolas', monospace; outline: none;
        }
        #main-panel { flex: 1; background: var(--bg); box-shadow: var(--shadow); order: 1; }
        #main-panel .panel-body { background: var(--bg); display: flex; flex-direction: column; }
        .console {
            flex: 1; background: var(--cbg); border-radius: 10px; padding: 20px;
            overflow-y: auto; font: 1em 'Consolas', monospace; line-height: 1.6;
            white-space: pre-wrap; border: 1px solid #444;
            box-shadow: inset 0 0 20px rgba(0,0,0,0.5); margin-bottom: 15px;
        }
        .ok { color: var(--ok); font-weight: 700; } .warn { color: var(--wn); font-weight: 700; }
        .fail { color: var(--fl); font-weight: 700; } .info { color: var(--in); font-weight: 700; }
        .section { color: #ccc; font-weight: 700; border-bottom: 1px solid var(--section-border); margin: 12px 0 6px; padding-bottom: 4px; }
        .input-area { display: flex; margin-top: auto; }
        .input-area input {
            flex: 1; padding: 14px; background: var(--cbg); border: 1px solid #555;
            border-radius: 10px 0 0 10px; color: var(--fg); font: 1em 'Consolas', monospace; outline: none;
        }
        .input-area button {
            padding: 14px 24px; background: var(--ac); color: var(--btn-fg); border: none;
            border-radius: 0 10px 10px 0; cursor: pointer; font-size: 1em; transition: background 0.2s;
        }
        .input-area button:hover { background: var(--btn-hover); }
        .status { font-size: 0.7em; color: #aaa; margin-top: 10px; }
        .modal {
            display: none; position: fixed; z-index: 100; left: 0; top: 0;
            width: 100%; height: 100%; background: rgba(0,0,0,0.7);
        }
        .modal-content {
            background: var(--pnl); margin: 5% auto; padding: 25px; border-radius: 12px;
            width: 420px; color: var(--fg); font-size: 0.9em; box-shadow: 0 10px 40px rgba(0,0,0,0.8);
        }
        .modal-content h2 { margin-top: 0; }
        .modal-content label { display: block; margin: 12px 0 6px; }
        .modal-content input[type=range] { width: 100%; }
        .modal-content select {
            width: 100%; padding: 10px; background: var(--input-bg); color: var(--input-fg);
            border: 1px solid #555; border-radius: 6px;
        }
        .modal-content button {
            margin-top: 20px; padding: 12px 24px; background: var(--ac); color: #fff;
            border: none; border-radius: 8px; cursor: pointer; font-size: 1em;
        }
    </style>
</head>
<body>
<div class="dashboard" id="dashboard">
    <div class="panel" id="sidebar" draggable="true">
        <div class="panel-header">⚔️ KnightOS</div>
        <div class="panel-body">
            <div class="group">
                <div class="group-title">System</div>
                <button class="sidebar-btn" onclick="run('doctor')">🩺 Doctor</button>
                <button class="sidebar-btn" onclick="run('fix-all')">🛠️ Fix All</button>
            </div>
            <div class="group">
                <div class="group-title">Packages</div>
                <button class="sidebar-btn" onclick="run('list')">📋 List</button>
                <button class="sidebar-btn" onclick="loadPackages()">📦 Browse</button>
            </div>
            <div class="group">
                <div class="group-title">Repositories</div>
                <button class="sidebar-btn" onclick="run('remote list')">🌍 Remote List</button>
                <button class="sidebar-btn" onclick="run('parse')">🔍 Scan URL</button>
            </div>
            <div class="group">
                <div class="group-title">Info & Settings</div>
                <button class="sidebar-btn" onclick="run('help')">❓ Help</button>
                <button class="sidebar-btn" onclick="openSettings()">⚙️ Settings</button>
            </div>
            <input type="password" id="sudopass" placeholder="Sudo password">
            <button class="sidebar-btn" onclick="sendSudo()">🔑 SEND SUDO</button>
            <select id="themeSelect" onchange="setTheme(this.value)">
                <option value="darkly">Darkly</option><option value="cyborg">Cyborg</option>
                <option value="superhero">Dracula</option><option value="vapor">Synthwave</option>
                <option value="solar">Solarized Dark</option><option value="flatly">Nord</option>
                <option value="cosmo">One Dark</option><option value="journal">Gruvbox Dark</option>
                <option value="litera">Tokyo Night</option><option value="lumen">GitHub Dark</option>
                <option value="minty">Monokai</option><option value="pulse">Material Dark</option>
                <option value="sandstone">Forest</option><option value="united">Sunset</option>
                <option value="yeti">Ice</option>
            </select>
            <div class="status" id="st"></div>
        </div>
    </div>
    <div class="panel" id="main-panel" draggable="true">
        <div class="panel-header">Console</div>
        <div class="panel-body">
            <div class="console" id="console"></div>
            <div class="input-area">
                <input id="commandInput" placeholder="Команда, например: doctor" onkeypress="if(event.key==='Enter')executeCommand()">
                <button onclick="executeCommand()">▶</button>
            </div>
        </div>
    </div>
</div>
<div id="settingsModal" class="modal">
    <div class="modal-content">
        <h2>⚙️ Settings</h2>
        <label>Font family:</label>
        <select id="fontFamily" onchange="updateFontSettings()">
            <option value="'Consolas', monospace">Consolas</option>
            <option value="'UnifrakturMaguntia', cursive">Gothic</option>
            <option value="custom">Load custom...</option>
        </select>
        <label>Font size: <span id="sizeValue">24px</span></label>
        <input type="range" id="fontSize" min="12" max="48" value="24" oninput="updateFontSettings()">
        <label>Custom font file (.ttf/.woff2):</label>
        <input type="file" id="customFontFile" accept=".ttf,.woff2" onchange="loadCustomFont()">
        <button onclick="closeSettings()">Close</button>
    </div>
</div>
<script src="themes.js"></script>
<script>
    const consoleEl = document.getElementById('console');
    const statusEl = document.getElementById('st');
    const cmdInput = document.getElementById('commandInput');
    let sudoPass = localStorage.getItem('knight_sudo') || '';
    document.getElementById('sudopass').value = sudoPass;

    function sendSudo() {
        sudoPass = document.getElementById('sudopass').value;
        localStorage.setItem('knight_sudo', sudoPass);
        fetch('/api/setpass', { method:'POST', headers:{'X-Sudo-Pass':btoa(sudoPass)} })
        .then(r => r.json())
        .then(d => appendToConsole('🔑 ' + (d.status || 'Sudo password active'), false));
        statusEl.textContent = 'Sudo password is active';
    }

    function setTheme(name) {
        const t = KNIGHT_THEMES[name] || KNIGHT_THEMES.darkly;
        const root = document.documentElement;
        for (const [key, value] of Object.entries(t)) {
            root.style.setProperty('--' + key.replace(/([A-Z])/g, '-$1').toLowerCase(), value);
        }
        localStorage.setItem('knight_theme', name);
    }
    setTheme(localStorage.getItem('knight_theme') || 'darkly');

    function typeWriter(text, element, delay = 6) {
        const words = text.split(/(\s+)/); let i = 0;
        function next() {
            if (i < words.length) {
                const span = document.createElement('span');
                span.textContent = words[i]; element.appendChild(span);
                i++; setTimeout(next, delay);
            } else {
                element.appendChild(document.createTextNode('\n'));
                element.scrollTop = element.scrollHeight;
            }
        }
        next();
    }

    function appendToConsole(text, animate = true) {
        if (animate) typeWriter(text, consoleEl);
        else { consoleEl.textContent += text + '\n'; consoleEl.scrollTop = consoleEl.scrollHeight; }
    }

    function clearConsole() { consoleEl.innerHTML = ''; }

    async function apiCall(cmd, pkg = null) {
        let url = '/api/' + cmd;
        if (pkg) url += '/' + pkg;
        const headers = {};
        if (sudoPass) headers['X-Sudo-Pass'] = btoa(sudoPass);
        const r = await fetch(url, { headers });
        return await r.json();
    }

    async function run(command) {
        clearConsole();
        statusEl.textContent = 'Выполняется ' + command + '...';
        appendToConsole('> ' + command + '\n', false);
        try {
            const data = await apiCall(command);
            if (data.output) {
                appendToConsole(data.output);
            } else if (data.status === 'ok') {
                appendToConsole('[OK] ' + data.message);
            } else if (data.status === 'error') {
                appendToConsole('[FAIL] ' + data.message);
            } else {
                appendToConsole(JSON.stringify(data, null, 2));
            }
            statusEl.textContent = 'Готово';
        } catch (e) {
            appendToConsole('Ошибка: ' + e.message, false);
            statusEl.textContent = 'Ошибка';
        }
    }

    async function executeCommand() {
        const command = cmdInput.value.trim(); if (!command) return;
        cmdInput.value = '';
        if (command.startsWith('install ') || command.startsWith('remove ')) {
            const [action, pkg] = command.split(' ');
            if (pkg) {
                clearConsole();
                statusEl.textContent = action + ' ' + pkg + '...';
                appendToConsole('> ' + command + '\n', false);
                const data = await apiCall(action, pkg);
                if (data.output) {
                    appendToConsole(data.output);
                } else if (data.status === 'ok') {
                    appendToConsole('[OK] ' + data.message);
                } else if (data.status === 'error') {
                    appendToConsole('[FAIL] ' + data.message);
                }
                statusEl.textContent = 'Готово';
                return;
            }
        }
        run(command);
    }

    async function loadPackages() {
        clearConsole();
        statusEl.textContent = 'Загрузка пакетов...';
        try {
            const data = await apiCall('packages');
            let list = 'Доступные пакеты:\n';
            data.packages.forEach(p => list += `  ${p.name} - ${p.desc || ''}\n`);
            appendToConsole(list);
            statusEl.textContent = 'Готово';
        } catch (e) { appendToConsole('Ошибка', false); }
    }

    const panels = document.querySelectorAll('.panel');
    let draggedItem = null;
    panels.forEach(panel => {
        panel.addEventListener('dragstart', function(e) {
            draggedItem = this;
            e.dataTransfer.effectAllowed = 'move';
            e.dataTransfer.setData('text/plain', '');
            this.style.opacity = '0.4';
        });
        panel.addEventListener('dragend', function(e) {
            this.style.opacity = '1';
            panels.forEach(p => p.style.border = 'none');
            draggedItem = null;
            savePanelOrder();
        });
        panel.addEventListener('dragover', function(e) { e.preventDefault(); e.dataTransfer.dropEffect = 'move'; });
        panel.addEventListener('dragenter', function(e) {
            e.preventDefault();
            if (this !== draggedItem) this.style.border = '2px dashed var(--ac)';
        });
        panel.addEventListener('dragleave', function(e) { this.style.border = 'none'; });
        panel.addEventListener('drop', function(e) {
            e.preventDefault();
            if (this !== draggedItem) {
                const parent = this.parentNode;
                const children = [...parent.children];
                const from = children.indexOf(draggedItem);
                const to = children.indexOf(this);
                if (from < to) parent.insertBefore(draggedItem, this.nextSibling);
                else parent.insertBefore(draggedItem, this);
            }
        });
    });
    function savePanelOrder() {
        const order = [...document.querySelectorAll('.panel')].map(p => p.id);
        localStorage.setItem('panel_order', JSON.stringify(order));
    }
    function restorePanelOrder() {
        const order = JSON.parse(localStorage.getItem('panel_order'));
        if (order) {
            const dashboard = document.getElementById('dashboard');
            order.forEach(id => {
                const panel = document.getElementById(id);
                if (panel) dashboard.appendChild(panel);
            });
        }
    }
    restorePanelOrder();

    function openSettings() { document.getElementById('settingsModal').style.display = 'block'; }
    function closeSettings() { document.getElementById('settingsModal').style.display = 'none'; }
    function updateFontSettings() {
        const family = document.getElementById('fontFamily').value;
        const size = document.getElementById('fontSize').value + 'px';
        document.getElementById('sizeValue').textContent = size;
        const root = document.documentElement;
        root.style.setProperty('--font-family', family === 'custom' ? (localStorage.getItem('custom_font_family') || family) : family);
        root.style.setProperty('--font-size', size);
        localStorage.setItem('font_family', family); localStorage.setItem('font_size', size);
    }
    function loadFontSettings() {
        const family = localStorage.getItem('font_family') || "'Consolas', monospace";
        const size = localStorage.getItem('font_size') || '24px';
        document.getElementById('fontFamily').value = family;
        document.getElementById('fontSize').value = parseInt(size);
        document.getElementById('sizeValue').textContent = size;
        const root = document.documentElement;
        root.style.setProperty('--font-family', family); root.style.setProperty('--font-size', size);
        if (localStorage.getItem('custom_font_family') && family === 'custom') {
            root.style.setProperty('--font-family', localStorage.getItem('custom_font_family'));
        }
    }
    async function loadCustomFont() {
        const file = document.getElementById('customFontFile').files[0]; if (!file) return;
        const reader = new FileReader();
        reader.onload = function(e) {
            const fontName = 'custom_' + Date.now();
            const style = document.createElement('style');
            style.textContent = `@font-face { font-family: '${fontName}'; src: url(${e.target.result}); }`;
            document.head.appendChild(style);
            localStorage.setItem('custom_font_family', `'${fontName}'`);
            document.getElementById('fontFamily').value = 'custom';
            updateFontSettings();
        };
        reader.readAsDataURL(file);
    }
    window.onload = function() {
        loadFontSettings();
        appendToConsole('Добро пожаловать в KnightOS Web UI.\nВведите пароль sudo и нажмите SEND SUDO.');
    };
</script>
</body>
</html>
"""

def run_knight_json(cmd, *args):
    """Выполнить команду KnightOS в JSON-режиме и вернуть словарь."""
    full = [os.path.join(BASE_DIR, "knight"), cmd, "--json"] + list(args)
    env = os.environ.copy()
    if sudo_password:
        env["KNIGHT_SUDO_PASS"] = sudo_password
    try:
        res = subprocess.run(full, capture_output=True, text=True, timeout=60, cwd=BASE_DIR, env=env)
        # Пробуем распарсить как JSON
        try:
            return json.loads(res.stdout.strip())
        except:
            # Если не JSON, возвращаем как текст
            return {"output": res.stdout + res.stderr}
    except subprocess.TimeoutExpired:
        return {"status": "error", "message": "Command timed out"}
    except Exception as e:
        return {"status": "error", "message": str(e)}

class KnightHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self): self._handle()
    def do_POST(self): self._handle()

    def _handle(self):
        p = urllib.parse.urlparse(self.path).path
        global sudo_password
        sudo_header = self.headers.get('X-Sudo-Pass')
        if sudo_header:
            try: sudo_password = base64.b64decode(sudo_header).decode('utf-8')
            except: pass

        if p in ('/', '/index.html'):
            self.send_response(200); self.send_header('Content-type','text/html;charset=utf-8'); self.end_headers()
            self.wfile.write(HTML.encode()); return
        if p == '/themes.js':
            try:
                with open(os.path.join(BASE_DIR, 'core', 'gui', 'themes.js'), 'rb') as f: data = f.read()
                self.send_response(200); self.send_header('Content-type','application/javascript'); self.end_headers(); self.wfile.write(data)
            except: self.send_response(404); self.end_headers()
            return
        if p == '/api/setpass':
            self.send_response(200); self.send_header('Content-type','application/json'); self.end_headers()
            self.wfile.write(json.dumps({"status":"Sudo password received"}).encode()); return
        if p.startswith('/api/'):
            parts = p[5:].split('/'); cmd = parts[0] if parts else ''
            if cmd == 'packages':
                pkgs = []
                for d in os.listdir(os.path.join(BASE_DIR, "packages")):
                    conf = os.path.join(BASE_DIR, "packages", d, "package.conf")
                    desc = ''
                    if os.path.isfile(conf):
                        with open(conf) as f:
                            for line in f:
                                if line.startswith('DESCRIPTION='): desc = line.split('=',1)[1].strip().strip('"'); break
                    pkgs.append({"name":d,"desc":desc})
                self._send_json({"packages":pkgs})
            elif cmd in ('install','remove') and len(parts) > 1:
                data = run_knight_json(cmd, parts[1])
                self._send_json(data)
            elif cmd in ('doctor','list','help','version','monitor','fix-all','remote','parse'):
                data = run_knight_json(cmd, *[p for p in parts[1:] if p])
                self._send_json(data)
            else: self._send_json({"error":"Unknown API"})
            return
        self.send_response(404); self.end_headers()

    def _send_json(self, data):
        self.send_response(200); self.send_header('Content-type','application/json'); self.end_headers()
        self.wfile.write(json.dumps(data, ensure_ascii=False).encode())
    def log_message(self, format, *args): pass

if __name__ == '__main__':
    httpd = http.server.HTTPServer(('', PORT), KnightHandler)
    print(f"KnightOS Web UI → http://localhost:{PORT}")
    try: subprocess.Popen(['xdg-open', f"http://localhost:{PORT}"], stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
    except: webbrowser.open(f"http://localhost:{PORT}")
    try: httpd.serve_forever()
    except KeyboardInterrupt: print("\nСтоп."); httpd.server_close()
