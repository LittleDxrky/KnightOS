const KNIGHT_THEMES = {
  darkly:    {bg:"#1e1e1e",pnl:"#2d2d2d",fg:"#d4d4d4",ac:"#375a7f",cbg:"#1a1a1a",btnFg:"#fff",inputBg:"#1a1a1a",inputFg:"#d4d4d4",sectionBorder:"#555",btnHover:"#4a6fa5",ok:"#4caf50",wn:"#ff9800",fl:"#f44336",in:"#2196f3"},
  cyborg:   {bg:"#060606",pnl:"#1a1a1a",fg:"#0c0",ac:"#444",cbg:"#000",btnFg:"#0c0",inputBg:"#000",inputFg:"#0c0",sectionBorder:"#333",btnHover:"#666",ok:"#0c0",wn:"#cc0",fl:"#c00",in:"#0cf"},
  // Темы по референсам с затемнёнными кнопками (ac ~34% яркости)
  superhero:{bg:"#282a36",pnl:"#1e1f29",fg:"#f8f8f2",ac:"#6272a4",cbg:"#21222c",btnFg:"#fff",inputBg:"#21222c",inputFg:"#f8f8f2",sectionBorder:"#44475a",btnHover:"#44475a",ok:"#50fa7b",wn:"#ffb86c",fl:"#ff5555",in:"#8be9fd"},
  vapor:    {bg:"#1a0033",pnl:"#2d004d",fg:"#ff66cc",ac:"#005577",cbg:"#0d001a",btnFg:"#fff",inputBg:"#0d001a",inputFg:"#ff66cc",sectionBorder:"#6600cc",btnHover:"#004466",ok:"#00ff88",wn:"#ffcc00",fl:"#ff3366",in:"#00ccff"},
  solar:    {bg:"#002b36",pnl:"#073642",fg:"#839496",ac:"#586e75",cbg:"#00161c",btnFg:"#fff",inputBg:"#00161c",inputFg:"#839496",sectionBorder:"#586e75",btnHover:"#657b83",ok:"#859900",wn:"#b58900",fl:"#dc322f",in:"#268bd2"},
  flatly:   {bg:"#2e3440",pnl:"#3b4252",fg:"#eceff4",ac:"#4c566a",cbg:"#242933",btnFg:"#fff",inputBg:"#242933",inputFg:"#eceff4",sectionBorder:"#4c566a",btnHover:"#434c5e",ok:"#a3be8c",wn:"#ebcb8b",fl:"#bf616a",in:"#5e81ac"},
  cosmo:    {bg:"#282c34",pnl:"#21252b",fg:"#abb2bf",ac:"#4b5263",cbg:"#1c1f24",btnFg:"#fff",inputBg:"#1c1f24",inputFg:"#abb2bf",sectionBorder:"#3e4452",btnHover:"#3e4452",ok:"#98c379",wn:"#e5c07b",fl:"#e06c75",in:"#61afef"},
  journal:  {bg:"#282828",pnl:"#1d2021",fg:"#ebdbb2",ac:"#5c4020",cbg:"#1b1b1b",btnFg:"#fff",inputBg:"#1b1b1b",inputFg:"#ebdbb2",sectionBorder:"#504945",btnHover:"#504945",ok:"#b8bb26",wn:"#fabd2f",fl:"#fb4934",in:"#83a598"},
  litera:   {bg:"#1a1b26",pnl:"#16161e",fg:"#c0caf5",ac:"#3b4261",cbg:"#13141c",btnFg:"#fff",inputBg:"#13141c",inputFg:"#c0caf5",sectionBorder:"#3b4261",btnHover:"#4b5a8a",ok:"#9ece6a",wn:"#e0af68",fl:"#f7768e",in:"#7dcfff"},
  lumen:    {bg:"#24292e",pnl:"#1b1f23",fg:"#e1e4e8",ac:"#4b3a3a",cbg:"#161a1d",btnFg:"#fff",inputBg:"#161a1d",inputFg:"#e1e4e8",sectionBorder:"#444d56",btnHover:"#444d56",ok:"#34d058",wn:"#ffea7f",fl:"#d73a49",in:"#79b8ff"},
  minty:    {bg:"#272822",pnl:"#1e1f1c",fg:"#f8f8f2",ac:"#5a7a1e",cbg:"#1d1e1b",btnFg:"#fff",inputBg:"#1d1e1b",inputFg:"#f8f8f2",sectionBorder:"#49483e",btnHover:"#4a6a0e",ok:"#a6e22e",wn:"#f4bf75",fl:"#f92672",in:"#66d9ef"},
  pulse:    {bg:"#212121",pnl:"#181818",fg:"#eeffff",ac:"#6b4a7a",cbg:"#161616",btnFg:"#fff",inputBg:"#161616",inputFg:"#eeffff",sectionBorder:"#303030",btnHover:"#5a3a6a",ok:"#c3e88d",wn:"#ffcb6b",fl:"#f07178",in:"#82aaff"},
  sandstone:{bg:"#2e4a2e",pnl:"#1e361e",fg:"#d4edc9",ac:"#3a4a1a",cbg:"#1a2e1a",btnFg:"#fff",inputBg:"#1a2e1a",inputFg:"#d4edc9",sectionBorder:"#4a6b4a",btnHover:"#2a3a10",ok:"#8bc34a",wn:"#ffeb3b",fl:"#e53935",in:"#29b6f6"},
  united:   {bg:"#4a1a1a",pnl:"#3a1010",fg:"#ffccaa",ac:"#8a3a1a",cbg:"#2a0a0a",btnFg:"#fff",inputBg:"#2a0a0a",inputFg:"#ffccaa",sectionBorder:"#6b3a3a",btnHover:"#6a2a10",ok:"#8bc34a",wn:"#ffc107",fl:"#f44336",in:"#03a9f4"},
  yeti:     {bg:"#e0f2fe",pnl:"#bae6fd",fg:"#0c4a6e",ac:"#014a6e",cbg:"#f0f9ff",btnFg:"#fff",inputBg:"#f0f9ff",inputFg:"#0c4a6e",sectionBorder:"#7dd3fc",btnHover:"#013a5a",ok:"#16a34a",wn:"#d97706",fl:"#dc2626",in:"#2563eb"}
};
