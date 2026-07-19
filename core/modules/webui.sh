#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$BASE_DIR"
echo "Запуск веб-интерфейса KnightOS на http://localhost:8080"
echo "Нажмите Ctrl+C для остановки."
python3 core/gui/webui.py
