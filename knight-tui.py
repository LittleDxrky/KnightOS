#!/usr/bin/env python3
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'core', 'gui'))
from app import KnightApp
import ttkbootstrap as ttk

if __name__ == "__main__":
    root = ttk.Window(themename="darkly")
    app = KnightApp(root)
    root.mainloop()
