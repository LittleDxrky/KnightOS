import tkinter as tk
from tkinter import ttk
import math, random

WORD_COLORS = ["#ff9999","#99ff99","#9999ff","#ffff99","#ff99ff","#99ffff","#ffcc99","#ccff99",
               "#ffb3ba","#baffc9","#bae1ff","#ffffba","#ffb3ff","#baffff","#ffd9ba","#d9ffba"]

KEYWORD_COLORS = {
    "OK":"#00ff00","WARN":"#ffff00","FAIL":"#ff4444","ERROR":"#ff0000","INFO":"#00bfff",
    "UP":"#00ff00","DOWN":"#ff4444","FIX?":"#ffaa00","Recommended":"#00bfff","Fixes":"#00bfff",
    "Doctor":"#00bfff","Checks":"#ffffff","Warnings":"#ffff00","Errors":"#ff4444"
}

class AnimatedTab(tk.Frame):
    def __init__(self, parent, title, on_close=None, fast_mode=False, word_delay=150):
        super().__init__(parent)
        self.title = title; self.on_close = on_close; self.running = True
        self.fast_mode = fast_mode; self.word_delay = word_delay; self.angle = 0
        self.canvas = tk.Canvas(self, width=400, height=80, bg='#2d2d2d', highlightthickness=0)
        self.canvas.pack(pady=20)
        self.label = ttk.Label(self, text=f"Running {title}...", font=('Arial', 10))
        self.label.pack()
        self.after_id = self.after(50, self._animate)

    def _animate(self):
        if not self.running: return
        self.canvas.delete("all"); x, y = 200, 40
        for i in range(8):
            a = self.angle + i * math.pi / 4
            dx, dy = math.cos(a)*15, math.sin(a)*15
            self.canvas.create_oval(x+dx-4, y+dy-4, x+dx+4, y+dy+4, fill='#ffffff', outline='')
        self.angle += 0.2
        self.after_id = self.after(50, self._animate)

    def stop(self, result_text):
        self.running = False; self.after_cancel(self.after_id)
        self.canvas.destroy(); self.label.destroy()
        self.text = tk.Text(self, wrap=tk.WORD, font=('Consolas', 10), bg='#2d2d2d', fg='#d4d4d4', state='disabled')
        self.text.pack(fill=tk.BOTH, expand=True)
        self.close_btn = ttk.Button(self, text="Close", command=self.close)
        self.close_btn.pack(pady=5)
        if self.fast_mode:
            self.text.configure(state='normal'); self.text.insert(tk.END, result_text); self.text.configure(state='disabled')
        else:
            self._lines = result_text.splitlines(); self._line_index = 0; self._type_next_line()

    def _type_next_line(self):
        if self._line_index < len(self._lines):
            line = self._lines[self._line_index]; self._words = line.split(' '); self._word_index = 0
            self._current_line_start = self.text.index(tk.INSERT); self.text.configure(state='normal')
            self._type_next_word()
        else: self.text.configure(state='disabled')

    def _type_next_word(self):
        if self._word_index < len(self._words):
            word = self._words[self._word_index]
            upper = word.upper().replace(":","").replace(".","").replace(",","")
            color = KEYWORD_COLORS.get(upper, random.choice(WORD_COLORS))
            tag = f"w_{self._line_index}_{self._word_index}"
            self.text.tag_configure(tag, foreground=color)
            self.text.insert(tk.END, word + (" " if self._word_index < len(self._words)-1 else ""), tag)
            if upper not in KEYWORD_COLORS:
                self.after(200, lambda t=tag: self.text.tag_remove(t, f"{self._current_line_start}", f"{self._current_line_start} lineend"))
            self._word_index += 1; self.text.see(tk.END); self.after(self.word_delay, self._type_next_word)
        else:
            self.text.insert(tk.END, '\n'); self.text.see(tk.END); self._line_index += 1
            self.after(self.word_delay, self._type_next_line)

    def close(self):
        if self.on_close: self.on_close(self)
        self.destroy()
