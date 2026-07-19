import subprocess, os, re, threading

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

def clean(s): return re.sub(r'\x1B\[[0-?]*[ -/]*[@-~]', '', s)

def run_bg(cmd, *args, callback=None, env=None):
    def target():
        full = [os.path.join(BASE_DIR, "knight"), cmd] + list(args)
        try:
            r = subprocess.run(full, capture_output=True, text=True, timeout=60, cwd=BASE_DIR, env=env)
            out = clean(r.stdout + r.stderr)
        except Exception as e: out = f"Error: {e}"
        if callback: callback(out)
    threading.Thread(target=target, daemon=True).start()

def load_locale(lang):
    loc = {}
    path = os.path.join(BASE_DIR, "core", "locale", f"{lang}.conf")
    if os.path.exists(path):
        with open(path) as f:
            for line in f:
                if '=' in line:
                    k, v = line.strip().split('=', 1)
                    loc[k.strip()] = v.strip().strip('"')
    return loc

def current_lang():
    try:
        with open(os.path.join(BASE_DIR, "knight.conf")) as f:
            for line in f:
                if line.startswith("KNIGHT_LANG="): return line.split('=',1)[1].strip()
    except: pass
    return "en"

def update_config(key, value):
    conf = os.path.join(BASE_DIR, "knight.conf")
    lines = []
    with open(conf) as f:
        for line in f:
            if line.startswith(f"{key}="): line = f"{key}={value}\n"
            lines.append(line)
    with open(conf, "w") as f: f.writelines(lines)

def get_package_dirs():
    bases = [os.path.join(BASE_DIR, "packages")]
    remotes_dir = os.path.join(BASE_DIR, "var", "remotes")
    if os.path.exists(remotes_dir):
        for d in os.listdir(remotes_dir):
            path = os.path.join(remotes_dir, d)
            if os.path.isdir(path): bases.append(path)
    return bases

def get_installed_packages():
    installed = []
    path = os.path.join(BASE_DIR, "var", "installed.list")
    if os.path.exists(path):
        with open(path) as f:
            for line in f:
                name = line.strip().split()[0]
                if name: installed.append(name)
    return installed

def get_available_packages():
    packages = []
    for base in get_package_dirs():
        if os.path.exists(base):
            for d in os.listdir(base):
                if os.path.isfile(os.path.join(base, d, "package.conf")): packages.append(d)
    return sorted(set(packages))

def refresh_package_cache():
    threading.Thread(target=lambda: subprocess.run(
        [os.path.join(BASE_DIR, "knight"), "list"], capture_output=True, cwd=BASE_DIR), daemon=True).start()
