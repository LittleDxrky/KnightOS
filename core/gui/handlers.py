import tkinter as tk
from tkinter import messagebox
import ttkbootstrap as ttk
from helpers import *
from widgets import AnimatedTab
import os

def doctor(self): self.run_with_progress("doctor")
def fix_all(self): self.run_with_progress("doctor", "--fix")

def logs(self):
    p = os.path.join(BASE_DIR, "core", "logs", "knight.log")
    self.display_in_tab("Logs", open(p).read() if os.path.exists(p) else self._("MSG_LOG_NOT_FOUND"))

def show_help(self):
    text = self._("MSG_HELP_TEXT")
    if text == "MSG_HELP_TEXT": text = "Help content not available."
    self.display_in_tab("Help", text)

def pkg_op(self, op):
    from dialogs import combo_dialog
    if op == "remove":
        pkgs = sorted(get_installed_packages())
        if not pkgs: messagebox.showinfo("Remove", self._("MSG_NO_INSTALLED_PKGS")); return
    else: pkgs = get_available_packages()
    combo_dialog(self, f"{op} package", f"{self._('MSG_SELECT_PKG')} {op}:", pkgs,
                 lambda pkg: self.run_with_progress(op, pkg))

def run_pkg(self):
    from dialogs import combo_dialog
    pkgs = sorted(get_installed_packages())
    if not pkgs: messagebox.showinfo("Run", self._("MSG_NO_INSTALLED_PKGS")); return
    combo_dialog(self, "Run package", "Select installed package to run:", pkgs,
                 lambda pkg: self.run_with_progress("bash", pkg) if any(
                     os.path.isfile(os.path.join(b, pkg, "run.sh")) for b in get_package_dirs()
                 ) else self.run_with_progress("info", pkg))

def _submenu(self, title, actions):
    from dialogs import submenu
    submenu(self, title, actions)

def open_packages(self):
    _submenu(self, self._("MSG_SHELL_PACKAGES"), [
        (self._("MSG_SHELL_PKG_LIST"), lambda: self.run_with_progress("list")),
        (self._("MSG_SHELL_PKG_INSTALL"), lambda: pkg_op(self, "install")),
        (self._("MSG_SHELL_PKG_REMOVE"), lambda: pkg_op(self, "remove")),
        (self._("MSG_SHELL_PKG_INFO"), lambda: pkg_op(self, "info")),
        ("▶️ Run Package", lambda: run_pkg(self))
    ])

def open_remote(self):
    from dialogs import combo_dialog, input_dialog, list_remote_names, submenu
    _submenu(self, "Remote Repositories", [
        ("List remotes", lambda: self.run_with_progress("remote", "list")),
        ("Add remote", lambda: input_dialog(self, "Add remote repository", "Name:", "Git URL:", "Add",
                                            lambda n,u: self.run_with_progress("remote","add",n,u), two_fields=True)),
        ("Remove remote", lambda: combo_dialog(self, "Remove remote", "Remote name:", list_remote_names(self),
                                               lambda n: self.run_with_progress("remote","remove",n))),
        ("Update remote", lambda: combo_dialog(self, "Update remote", "Remote name (empty = all):", [""]+list_remote_names(self),
                                               lambda n: self.run_with_progress("remote","update",n) if n else self.run_with_progress("remote","update")))
    ])

def open_scan(self):
    from dialogs import input_dialog
    input_dialog(self, "Scan Remote URL", "Enter Git URL to scan for packages:", "Scan",
                 lambda url: self.run_with_progress("parse", url))

def open_benchmark(self):
    from dialogs import submenu
    _submenu(self, self._("MSG_SHELL_BENCHMARK"), [
        (self._("MSG_SHELL_BASELINE"), lambda: self.run_with_progress("monitor", "baseline")),
        (self._("MSG_SHELL_COMPARE"), lambda: self.run_with_progress("monitor", "compare")),
        (self._("MSG_SHELL_HISTORY"), lambda: self.run_with_progress("monitor", "history")),
        (self._("MSG_SHELL_SHOW_BASELINE"), lambda: self.run_with_progress("monitor", "show"))
    ])
