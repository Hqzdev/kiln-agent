#!/bin/zsh -l
# Двойной клик — ставит зависимости (один раз) и запускает лендинг на http://localhost:3000
cd "$(dirname "$0")"
if ! command -v npm >/dev/null 2>&1; then
  echo "Node.js не найден. Поставь его: brew install node  — и запусти этот файл ещё раз."
  read -k 1
  exit 1
fi
if [ ! -d node_modules ]; then
  echo "→ Ставлю зависимости (один раз, ~30 сек)…"
  npm install --no-audit --no-fund || { echo "npm install упал"; read -k 1; exit 1; }
fi
(sleep 5; open "http://localhost:3000") &
echo "→ Blot landing: http://localhost:3000  (Ctrl+C чтобы остановить)"
npm run dev
