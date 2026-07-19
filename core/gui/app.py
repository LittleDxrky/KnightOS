import tkinter as tk
from tkinter import messagebox, scrolledtext, simpledialog
import ttkbootstrap as ttk
from helpers import *
from themes import THEMES, load_theme, apply_theme
from handlers import *
from dialogs import browse_sources
from widgets import AnimatedTab

class KnightApp:
    _TRANS_MAP = {
        "Doctor":"MSG_DOCTOR_TITLE","Checks":"MSG_CHECKS","OK":"MSG_OK_LABEL",
        "Warnings":"MSG_WARNINGS","Errors":"MSG_ERRORS","Free RAM":"MSG_FREE_RAM",
        "Bluetooth":"MSG_BLUETOOTH","CPU Driver":"MSG_CPU_DRIVER","Governor":"MSG_GOVERNOR",
        "Turbo Boost":"MSG_TURBO_BOOST","NVIDIA Driver":"MSG_NVIDIA_DRIVER",
        "IO Scheduler":"MSG_IO_SCHEDULER","Kernel":"MSG_KERNEL",
        "TCP Congestion":"MSG_TCP_CONGESTION","Network Buffers":"MSG_NETWORK_BUFFERS",
        "Service":"MSG_SERVICE","Swappiness":"MSG_SWAPPINESS",
        "Cache Pressure":"MSG_CACHE_PRESSURE","Transparent Huge Pages":"MSG_THP"
    }

    def __init__(self, root):
        self.root = root
        self.lang = current_lang(); self.locale = load_locale(self.lang)
        self.theme = "darkly"; self.sudo_password = None
        self.fast_mode = False; self.word_delay = 150
        load_theme(self); self.main_frame = None
        self.create_main_ui()
        self.root.after(500, self.ask_sudo)
        self.root.protocol("WM_DELETE_WINDOW", root.quit)

    apply_theme = apply_theme
    load_theme = load_theme

    def _(self, key): return self.locale.get(key, key)

    def ask_sudo(self):
        if self.sudo_password: return self.sudo_password
        pwd = simpledialog.askstring("Sudo", "Enter sudo password:", show='*', parent=self.root)
        if pwd:
            self.sudo_password = pwd; refresh_package_cache()
        return pwd

    def translate_output(self, text):
        for eng, loc_key in self._TRANS_MAP.items():
            loc = self._(loc_key)
            if loc != loc_key: text = text.replace(eng, loc)
        title = self._("MSG_DOCTOR_TITLE")
        return text.replace("========== Doctor ==========", f"========== {title} ==========")

    def display_in_tab(self, title, text):
        self._close_dup(title)
        tab = AnimatedTab(self.notebook, title, on_close=lambda t: self.notebook.forget(t),
                          fast_mode=self.fast_mode, word_delay=self.word_delay)
        self.notebook.add(tab, text=title); self.notebook.select(tab)
        tab.stop(text)

    def _close_dup(self, title):
        for tab_id in self.notebook.tabs():
            tab = self.notebook.nametowidget(tab_id)
            if isinstance(tab, AnimatedTab) and tab.title == title: tab.close(); break

    def run_with_progress(self, cmd, *args):
        if not self.sudo_password:
            if not self.ask_sudo(): messagebox.showwarning("Sudo", "Password required."); return
        title = f"{cmd} {' '.join(args)}"
        self._close_dup(title)
        tab = AnimatedTab(self.notebook, title, on_close=lambda t: self.notebook.forget(t),
                          fast_mode=self.fast_mode, word_delay=self.word_delay)
        self.notebook.add(tab, text=title); self.notebook.select(tab)
        self.root.config(cursor="watch")
        def cb(res):
            tab.stop(self.translate_output(res)); self.root.config(cursor="")
        env = os.environ.copy(); env["KNIGHT_SUDO_PASS"] = self.sudo_password
        run_bg(cmd, *args, callback=lambda out: self.root.after(0, cb, out), env=env)

    def clear_main(self):
        if self.main_frame: self.main_frame.destroy()
        self.main_frame = ttk.Frame(self.root)
        self.main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

    def create_main_ui(self):
        self.clear_main(); self.apply_theme()
        left = ttk.Frame(self.main_frame, width=250)
        left.pack(side=tk.LEFT, fill=tk.Y, padx=(0,10)); left.pack_propagate(False)

        ttk.Label(left, text=self._("MSG_MAIN_TITLE"), font=("Arial",12,"bold"), style="Highlight.TLabel").pack(pady=5)
        ttk.Separator(left, orient="horizontal").pack(fill=tk.X, pady=5)

        actions = [
            (self._("MSG_DOCTOR_BTN"), lambda: doctor(self), "primary"),
            ("🛠️ Fix All", lambda: fix_all(self), "success"),
            (self._("MSG_SHELL_PACKAGES"), lambda: open_packages(self), "info"),
            (self._("MSG_SHELL_BENCHMARK"), lambda: open_benchmark(self), "secondary"),
            ("🌍 Remote", lambda: open_remote(self), "secondary"),
            ("🔍 Scan URL", lambda: open_scan(self), "secondary"),
            ("📚 Browse Sources", lambda: browse_sources(self), "secondary"),
            (self._("MSG_LOGS_BTN"), lambda: logs(self), "secondary"),
            (self._("MSG_HELP_BTN"), lambda: show_help(self), "secondary"),
            ("⚙️ Settings", self.open_settings, "secondary")
        ]
        self.buttons = []
        for text, cmd, style in actions:
            btn = ttk.Button(left, text=text, command=cmd, bootstyle=style, style="Highlight.TButton", width=25)
            btn.pack(pady=2, padx=5, fill=tk.X)
            btn.bind("<Return>", lambda e,c=cmd: c()); btn.bind("<space>", lambda e,c=cmd: c())
            self.buttons.append(btn)

        def focus_next(event):
            cur = self.root.focus_get()
            if cur in self.buttons:
                idx = self.buttons.index(cur)
                self.buttons[(idx+1)%len(self.buttons)].focus_set()
            return "break"
        def focus_prev(event):
            cur = self.root.focus_get()
            if cur in self.buttons:
                idx = self.buttons.index(cur)
                self.buttons[(idx-1)%len(self.buttons)].focus_set()
            return "break"
        for btn in self.buttons: btn.bind("<Down>", focus_next); btn.bind("<Up>", focus_prev)

        bottom = ttk.Frame(left); bottom.pack(side=tk.BOTTOM, fill=tk.X, pady=5)
        ttk.Label(bottom, text=self._("MSG_THEME_BTN")+":").pack(anchor='w')
        self.theme_var = tk.StringVar(value=self.theme)
        ttk.Combobox(bottom, textvariable=self.theme_var, values=list(THEMES.keys()), state="readonly", width=22).pack(fill=tk.X, pady=2)
        ttk.Button(bottom, text=self._("MSG_LANG_BTN"), command=self.toggle_lang, bootstyle="outline-secondary").pack(fill=tk.X, pady=2)
        ttk.Button(bottom, text=self._("MSG_QUIT_BTN"), command=self.root.quit, bootstyle="outline-danger").pack(fill=tk.X, pady=5)

        right = ttk.Frame(self.main_frame); right.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True)
        self.notebook = ttk.Notebook(right); self.notebook.pack(fill=tk.BOTH, expand=True)
        self.out_frame = ttk.Frame(self.notebook); self.notebook.add(self.out_frame, text="Output")
        self.out = scrolledtext.ScrolledText(self.out_frame, wrap=tk.WORD, font=("Consolas",10), state="disabled", relief="solid", borderwidth=2)
        self.out.pack(fill=tk.BOTH, expand=True)
        self.copy_btn = tk.Button(right, text=self._("MSG_COPY_BTN"), command=self.copy_out)
        self.copy_btn.pack(pady=(5,0), anchor='se')
        self.apply_theme()

    def copy_out(self):
        self.root.clipboard_clear(); self.root.clipboard_append(self.out.get(1.0, tk.END))
        messagebox.showinfo(self._("MSG_COPY_SUCCESS"), self._("MSG_COPY_SUCCESS"))

    def open_settings(self):
        dlg = tk.Toplevel(self.root); dlg.title(self._("MSG_SETTINGS_TITLE")); dlg.geometry("400x250")
        c = self.root.style.colors; dlg.configure(bg=c.bg)
        self.fast_var = tk.BooleanVar(value=self.fast_mode)
        ttk.Checkbutton(dlg, text=self._("MSG_FAST_MODE"), variable=self.fast_var).pack(pady=10, anchor='w', padx=20)
        ttk.Label(dlg, text=self._("MSG_ANIM_SPEED")).pack(anchor='w', padx=20)
        self.speed_var = tk.IntVar(value=self.word_delay)
        ttk.Scale(dlg, from_=50, to=300, variable=self.speed_var, orient=tk.HORIZONTAL).pack(fill=tk.X, padx=20)
        ttk.Button(dlg, text=self._("MSG_RESET_SUDO"), command=lambda: (setattr(self,'sudo_password',None), messagebox.showinfo(self._("MSG_SETTINGS_TITLE"), self._("MSG_SUDO_RESET")))).pack(pady=10)
        def apply():
            self.fast_mode = self.fast_var.get(); self.word_delay = self.speed_var.get(); dlg.destroy()
            messagebox.showinfo(self._("MSG_SETTINGS_TITLE"), self._("MSG_SETTINGS_SAVED"))
        ttk.Button(dlg, text=self._("MSG_APPLY"), command=apply, bootstyle="success").pack(pady=10)

    def toggle_lang(self):
        new = "ru" if self.lang == "en" else "en"
        update_config("KNIGHT_LANG", new); self.lang = new; self.locale = load_locale(self.lang)
        self.refresh_ui()

    def refresh_ui(self):
        if self.main_frame: self.main_frame.destroy()
        self.create_main_ui()
