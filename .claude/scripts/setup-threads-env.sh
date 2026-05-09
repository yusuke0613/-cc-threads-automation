#!/bin/bash
# SessionStart hook: GitHub Secrets経由の環境変数から ~/.threads-env を生成する
# GitHub Actions では secrets.* が環境変数として渡される

set -e

# すでに存在する場合はスキップ
if [ -f ~/.threads-env ]; then
  exit 0
fi

# 必須環境変数チェック
if [ -z "$THREADS_ACCESS_TOKEN" ] || [ -z "$THREADS_USER_ID" ]; then
  echo "[setup-threads-env] THREADS_ACCESS_TOKEN / THREADS_USER_ID が未設定です。スキップします。" >&2
  exit 0
fi

cat > ~/.threads-env << EOF
export THREADS_ACCESS_TOKEN="${THREADS_ACCESS_TOKEN}"
export THREADS_USER_ID="${THREADS_USER_ID}"
export THREADS_APP_ID="${THREADS_APP_ID:-}"
export THREADS_APP_SECRET="${THREADS_APP_SECRET:-}"
export THREADS_TOKEN_ISSUED_AT="${THREADS_TOKEN_ISSUED_AT:-}"
export THREADS_BOT_DIR="${THREADS_BOT_DIR:-$(pwd)/threads-bot}"
EOF

chmod 600 ~/.threads-env
echo "[setup-threads-env] ~/.threads-env を生成しました"
