#!/bin/bash
# Threads テキスト投稿スクリプト
# 使い方: bash post-text.sh <下書きファイルのパス>

set -e

# 環境変数読み込み
if [ ! -f ~/.threads-env ]; then
  echo "❌ ~/.threads-env が見つかりません"
  exit 1
fi
source ~/.threads-env

# データディレクトリ (env未設定なら従来パスにフォールバック)
: "${THREADS_BOT_DIR:=$HOME/threads-bot}"

# 引数チェック
if [ -z "$1" ]; then
  echo "使い方: $0 <下書きファイルパス>"
  echo "例: $0 \"$THREADS_BOT_DIR/drafts/2026-05-08-1030-社内SE.md\""
  exit 1
fi

DRAFT_FILE="$1"

if [ ! -f "$DRAFT_FILE" ]; then
  echo "❌ ファイルが見つかりません: $DRAFT_FILE"
  exit 1
fi

# 本文を読み込み (Markdownのフロントマターを除外)
POST_TEXT=$(awk '/^---$/{flag=!flag; next} !flag' "$DRAFT_FILE" | sed '/^$/d' | head -c 4900)

if [ -z "$POST_TEXT" ]; then
  echo "❌ 本文が空です"
  exit 1
fi

echo "============================="
echo "投稿内容プレビュー:"
echo "============================="
echo "$POST_TEXT"
echo "============================="
echo "文字数: $(echo -n "$POST_TEXT" | wc -m)"
echo ""

# Step 1: コンテナ作成
echo "📝 コンテナ作成中..."
RES=$(curl -s -X POST \
  "https://graph.threads.net/v1.0/${THREADS_USER_ID}/threads" \
  -d "media_type=TEXT" \
  --data-urlencode "text=${POST_TEXT}" \
  -d "access_token=${THREADS_ACCESS_TOKEN}")

CREATION_ID=$(echo "$RES" | jq -r '.id // empty')

if [ -z "$CREATION_ID" ]; then
  echo "❌ コンテナ作成失敗"
  echo "Response: $RES"
  mkdir -p "$THREADS_BOT_DIR/logs"
  echo "{\"timestamp\":\"$(date -Iseconds)\",\"phase\":\"create\",\"error\":$RES}" >> "$THREADS_BOT_DIR/logs/errors.jsonl"
  exit 1
fi

echo "✅ CREATION_ID: $CREATION_ID"

# Step 2: 待機
echo "⏳ 5秒待機..."
sleep 5

# Step 3: 公開
echo "🚀 公開中..."
PUBLISH_RES=$(curl -s -X POST \
  "https://graph.threads.net/v1.0/${THREADS_USER_ID}/threads_publish" \
  -d "creation_id=${CREATION_ID}" \
  -d "access_token=${THREADS_ACCESS_TOKEN}")

THREAD_ID=$(echo "$PUBLISH_RES" | jq -r '.id // empty')

if [ -z "$THREAD_ID" ]; then
  echo "❌ 公開失敗"
  echo "Response: $PUBLISH_RES"
  mkdir -p "$THREADS_BOT_DIR/logs"
  echo "{\"timestamp\":\"$(date -Iseconds)\",\"phase\":\"publish\",\"creation_id\":\"$CREATION_ID\",\"error\":$PUBLISH_RES}" >> "$THREADS_BOT_DIR/logs/errors.jsonl"
  exit 1
fi

echo ""
echo "🎉 投稿完了!"
echo "Thread ID: $THREAD_ID"
echo "URL: https://www.threads.net/@you_white_tensyoku/post/$THREAD_ID"

# 下書きをpostedに移動
mkdir -p "$THREADS_BOT_DIR/posted"
POSTED_FILE="$THREADS_BOT_DIR/posted/$(basename "$DRAFT_FILE")"
mv "$DRAFT_FILE" "$POSTED_FILE"
echo "📁 下書きを移動: $POSTED_FILE"

# ログ記録
mkdir -p "$THREADS_BOT_DIR/logs"
LOG_TEXT=$(echo "$POST_TEXT" | LC_ALL=C tr '\n' ' ' | head -c 200)
echo "{\"timestamp\":\"$(date -Iseconds)\",\"thread_id\":\"$THREAD_ID\",\"creation_id\":\"$CREATION_ID\",\"text_preview\":\"$LOG_TEXT\",\"draft_file\":\"$POSTED_FILE\"}" >> "$THREADS_BOT_DIR/logs/posts.jsonl"
echo "📝 ログ記録完了"
