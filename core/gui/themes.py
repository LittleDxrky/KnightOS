import os

THEMES = {
    "darkly":    {"bg":"#1e1e1e","fg":"#c0c0c0","out_bg":"#2a2a2a","out_fg":"#b0b0b0","btn_bg":"#2c3e50","btn_fg":"white","entry_bg":"#2a2a2a","entry_fg":"white","highlight_bg":"#151515","highlight_fg":"#ffffff","highlight_border":"#2c3e50"},
    "superhero": {"bg":"#2b3e50","fg":"#d0d0d0","out_bg":"#405060","out_fg":"white","btn_bg":"#b05010","btn_fg":"white","entry_bg":"#405060","entry_fg":"white","highlight_bg":"#1a2a35","highlight_fg":"#ffffff","highlight_border":"#b05010"},
    "cyborg":    {"bg":"#060606","fg":"#00aa00","out_bg":"#1a1a1a","out_fg":"#00aa00","btn_bg":"#3a3a3a","btn_fg":"#00aa00","entry_bg":"#1a1a1a","entry_fg":"#00aa00","highlight_bg":"#000000","highlight_fg":"#00aa00","highlight_border":"#3a3a3a"},
    "vapor":     {"bg":"#2d1b69","fg":"#c0c0c0","out_bg":"#352a70","out_fg":"#c0c0c0","btn_bg":"#4a2f8a","btn_fg":"white","entry_bg":"#352a70","entry_fg":"white","highlight_bg":"#1b0f40","highlight_fg":"#ffffff","highlight_border":"#4a2f8a"},
    "solar":     {"bg":"#002b36","fg":"#8a9a9a","out_bg":"#003541","out_fg":"#8a9a9a","btn_bg":"#7a5a00","btn_fg":"white","entry_bg":"#003541","entry_fg":"#8a9a9a","highlight_bg":"#00161c","highlight_fg":"#ffffff","highlight_border":"#7a5a00"},
    "flatly":    {"bg":"#a0c0b0","fg":"#1e2b38","out_bg":"#c0d8d0","out_fg":"#1e2b38","btn_bg":"#0e5648","btn_fg":"white","entry_bg":"#d0e0d8","entry_fg":"#1e2b38","highlight_bg":"#8ab09a","highlight_fg":"#ffffff","highlight_border":"#0a3b2e"},
    "cosmo":     {"bg":"#a0b8d8","fg":"#1f2a36","out_bg":"#c0d0e8","out_fg":"#1f2a36","btn_bg":"#1a4078","btn_fg":"white","entry_bg":"#d0ddf0","entry_fg":"#1f2a36","highlight_bg":"#88a0c8","highlight_fg":"#ffffff","highlight_border":"#0d2850"},
    "journal":   {"bg":"#d4c8a0","fg":"#3a3e44","out_bg":"#e0d8c0","out_fg":"#3a3e44","btn_bg":"#6a4e00","btn_fg":"white","entry_bg":"#f0e8d0","entry_fg":"#3a3e44","highlight_bg":"#c0b088","highlight_fg":"#ffffff","highlight_border":"#3a2800"},
    "litera":    {"bg":"#98b8e0","fg":"#1d2632","out_bg":"#c0d0e8","out_fg":"#1d2632","btn_bg":"#204080","btn_fg":"white","entry_bg":"#d0ddf0","entry_fg":"#1d2632","highlight_bg":"#80a0d0","highlight_fg":"#ffffff","highlight_border":"#102850"},
    "lumen":     {"bg":"#80b8d8","fg":"#2e3236","out_bg":"#c0d8e8","out_fg":"#2e3236","btn_bg":"#0a4868","btn_fg":"white","entry_bg":"#d0e8f0","entry_fg":"#2e3236","highlight_bg":"#68a0c8","highlight_fg":"#ffffff","highlight_border":"#052838"},
    "minty":     {"bg":"#90c0b0","fg":"#2e3a34","out_bg":"#c0d8d0","out_fg":"#2e3a34","btn_bg":"#3a7060","btn_fg":"white","entry_bg":"#d0e8e0","entry_fg":"#2e3a34","highlight_bg":"#78b098","highlight_fg":"#ffffff","highlight_border":"#204838"},
    "pulse":     {"bg":"#9880c0","fg":"#26202e","out_bg":"#c0c8e0","out_fg":"#26202e","btn_bg":"#2c1850","btn_fg":"white","entry_bg":"#d0d0e8","entry_fg":"#26202e","highlight_bg":"#8068b0","highlight_fg":"#ffffff","highlight_border":"#140828"},
    "sandstone": {"bg":"#b8d098","fg":"#262a22","out_bg":"#d0e0c0","out_fg":"#262a22","btn_bg":"#507820","btn_fg":"white","entry_bg":"#e0f0d0","entry_fg":"#262a22","highlight_bg":"#a0c080","highlight_fg":"#ffffff","highlight_border":"#285010"},
    "united":    {"bg":"#e0a890","fg":"#241a14","out_bg":"#f0d0c0","out_fg":"#241a14","btn_bg":"#882810","btn_fg":"white","entry_bg":"#f0d8c8","entry_fg":"#241a14","highlight_bg":"#d09078","highlight_fg":"#ffffff","highlight_border":"#481408"},
    "yeti":      {"bg":"#80b8d8","fg":"#121a20","out_bg":"#c0d8e8","out_fg":"#121a20","btn_bg":"#004868","btn_fg":"white","entry_bg":"#d0e8f0","entry_fg":"#121a20","highlight_bg":"#68a0c8","highlight_fg":"#ffffff","highlight_border":"#002838"}
}

def load_theme(self):
    try:
        with open(os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), "knight.conf")) as f:
            for line in f:
                if line.startswith("THEME="):
                    name = line.split("=",1)[1].strip()
                    self.theme = {"dark":"darkly","light":"flatly"}.get(name, name)
    except: pass

def apply_theme(self, name=None):
    if name: self.theme = name
    c = THEMES.get(self.theme, THEMES["darkly"])
    self.root.style.theme_use(self.theme); self.root.configure(bg=c["bg"])
    style = self.root.style
    for w in ('TFrame','TLabel','TButton'): style.configure(w, background=c["bg"], foreground=c["fg"])
    style.configure('Highlight.TButton', background=c["highlight_bg"], foreground=c["highlight_fg"],
                    borderwidth=3, relief="solid", bordercolor=c.get("highlight_border",c["highlight_bg"]))
    style.configure('TButton', borderwidth=1, focusthickness=2, focuscolor=c["btn_fg"])
    style.map('TButton', background=[('active',c["btn_bg"]),('!active',c["btn_bg"])],
              foreground=[('active',c["btn_fg"]),('!active',c["btn_fg"])])
    style.configure('TEntry', fieldbackground=c["entry_bg"], foreground=c["entry_fg"])
    style.configure('TCombobox', fieldbackground=c["entry_bg"], foreground=c["entry_fg"])
    if hasattr(self,'out'): self.out.configure(bg=c["out_bg"], fg=c["out_fg"], insertbackground=c["fg"])
    if hasattr(self,'copy_btn'): self.copy_btn.configure(bg=c["out_bg"], fg=c["fg"])
