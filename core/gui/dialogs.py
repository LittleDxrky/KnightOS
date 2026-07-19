import tkinter as tk
from tkinter import messagebox
import ttkbootstrap as ttk
from helpers import *
import os

def combo_dialog(self, title, label, values, callback):
    dlg = tk.Toplevel(self.root)
    dlg.title(title)
    dlg.geometry("350x120")
    c = self.root.style.colors
    dlg.configure(bg=c.bg)
    ttk.Label(dlg, text=label).pack(pady=5)
    combo = ttk.Combobox(dlg, values=values, width=35)
    combo.pack(pady=5)
    combo.focus_set()
    combo.bind('<KeyRelease>', lambda e: combo.configure(values=[v for v in values if combo.get().lower() in v.lower()]))
    def on_ok():
        val = combo.get().strip()
        if val:
            dlg.destroy()
            callback(val)
        else:
            dlg.destroy()
    ttk.Button(dlg, text=self._("MSG_OK"), command=on_ok, bootstyle="primary").pack(pady=5)

def input_dialog(self, title, label1, label2_or_button, btn_text, callback, two_fields=False):
    dlg = tk.Toplevel(self.root)
    dlg.title(title)
    dlg.geometry("400x180" if two_fields else "450x150")
    c = self.root.style.colors
    dlg.configure(bg=c.bg)
    ttk.Label(dlg, text=label1).pack(pady=2)
    entry1 = ttk.Entry(dlg, width=40)
    entry1.pack(pady=2)
    entry2 = None
    if two_fields:
        ttk.Label(dlg, text=label2_or_button).pack(pady=2)
        entry2 = ttk.Entry(dlg, width=40)
        entry2.pack(pady=2)
    else:
        ttk.Label(dlg, text=label2_or_button).pack(pady=2)
    def submit():
        if two_fields:
            name = entry1.get().strip()
            url = entry2.get().strip()
            if name and url:
                dlg.destroy()
                callback(name, url)
        else:
            val = entry1.get().strip()
            if val:
                dlg.destroy()
                callback(val)
    ttk.Button(dlg, text=btn_text, command=submit, bootstyle="primary").pack(pady=10)

def show_fix_dialog(self, fixes):
    dlg = tk.Toplevel(self.root)
    dlg.title("Apply Fixes")
    dlg.geometry("500x300")
    c = self.root.style.colors
    dlg.configure(bg=c.bg)
    ttk.Label(dlg, text="Select fixes to apply:", font=("Arial", 11, "bold")).pack(pady=5)
    vars = []
    for desc in fixes:
        var = tk.BooleanVar(value=True)
        vars.append(var)
        ttk.Checkbutton(dlg, text=desc, variable=var).pack(anchor="w", padx=10, pady=2)
    def apply_selected():
        selected = [i for i, v in enumerate(vars) if v.get()]
        if not selected:
            dlg.destroy()
            return
        dlg.destroy()
        self.run_with_progress("doctor", "--fix")
        messagebox.showinfo("Fixes", "Selected fixes applied.")
    btn_frame = ttk.Frame(dlg)
    btn_frame.pack(pady=10)
    ttk.Button(btn_frame, text="Apply Selected", command=apply_selected, bootstyle="success").pack(side=tk.LEFT, padx=5)
    ttk.Button(btn_frame, text="Cancel", command=dlg.destroy, bootstyle="secondary").pack(side=tk.LEFT, padx=5)

def submenu(self, title, actions):
    sub = tk.Toplevel(self.root)
    sub.title(title)
    sub.geometry("300x" + str(70 + len(actions)*35))
    c = self.root.style.colors
    sub.configure(bg=c.bg)
    ttk.Label(sub, text=title, font=("Arial", 12, "bold")).pack(pady=10)
    for text, cmd in actions:
        ttk.Button(sub, text=text, command=cmd, width=25).pack(pady=3)
    ttk.Button(sub, text=self._("MSG_BACK"), command=sub.destroy, width=25, bootstyle="secondary").pack(pady=10)

def browse_sources(self):
    sources_url = "https://raw.githubusercontent.com/LittleDxrky/KnightOS/main/sources.list"
    local_path = os.path.join(BASE_DIR, "var", "remotes", "sources.list")
    try:
        import urllib.request
        urllib.request.urlretrieve(sources_url, local_path)
    except: pass
    if not os.path.exists(local_path):
        messagebox.showinfo("Browse Sources", "No sources available.")
        return
    entries = []
    with open(local_path) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "|" in line:
                parts = line.split("|")
                if len(parts) >= 3:
                    entries.append((parts[0], parts[1], parts[2]))
    if not entries:
        messagebox.showinfo("Browse Sources", "No sources available.")
        return
    dlg = tk.Toplevel(self.root)
    dlg.title("Browse Remote Repositories")
    dlg.geometry("650x350")
    c = self.root.style.colors
    dlg.configure(bg=c.bg)
    ttk.Label(dlg, text="Select a repository to add:", font=("Arial", 11, "bold")).pack(pady=5)
    frame = ttk.Frame(dlg)
    frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
    scrollbar = ttk.Scrollbar(frame)
    scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    listbox = tk.Listbox(frame, yscrollcommand=scrollbar.set, bg=c.bg, fg=c.fg, font=("Consolas", 9))
    for i, (name, url, desc) in enumerate(entries, 1):
        listbox.insert(tk.END, f"{i:2d}. {name} - {desc}")
    listbox.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
    scrollbar.config(command=listbox.yview)
    def add_selected():
        sel = listbox.curselection()
        if sel:
            name, url, _ = entries[sel[0]]
            dlg.destroy()
            self.run_with_progress("remote", "add", name, url)
    btn_frame = ttk.Frame(dlg)
    btn_frame.pack(pady=5)
    ttk.Button(btn_frame, text="Add Selected", command=add_selected, bootstyle="success").pack(side=tk.LEFT, padx=5)
    ttk.Button(btn_frame, text="Close", command=dlg.destroy, bootstyle="secondary").pack(side=tk.LEFT, padx=5)

def list_remote_names(self):
    remotes_dir = os.path.join(BASE_DIR, "var", "remotes")
    if os.path.exists(remotes_dir):
        return [d for d in os.listdir(remotes_dir) if os.path.isdir(os.path.join(remotes_dir, d))]
    return []
import tkinter.simpledialog

def ask_sudo_password(self):
    if hasattr(self, 'sudo_password') and self.sudo_password:
        return self.sudo_password
    password = tkinter.simpledialog.askstring(
        "Sudo Password",
        "Enter your sudo password:",
        show='*',
        parent=self.root
    )
    if password:
        self.sudo_password = password
    return password

import tkinter.simpledialog

def ask_sudo_password(self):
    if hasattr(self, 'sudo_password') and self.sudo_password:
        return self.sudo_password
    password = tkinter.simpledialog.askstring(
        "Sudo Password",
        "Enter your sudo password:",
        show='*',
        parent=self.root
    )
    if password:
        self.sudo_password = password
    return password
