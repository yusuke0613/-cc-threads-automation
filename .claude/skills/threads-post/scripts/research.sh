#!/bin/bash
# Threads キーワード検索スクリプト
# 使い方: bash research.sh "キーワード" [TOP|RECENT]

set -e

source ~/.threads-env

# データディレクトリ (env未設定なら従来パスにフォールバック)
: "${THREADS_BOT_DIR:=$HOME/threads-bot}"

if [ -z "$1" ]; then
  echo "使い方: $0 \"キーワード\" [TOP|RECENT]"
  exit 1
fi

KEYWORD="$1"
SEARCH_TYPE="${2:-TOP}"

DATE=$(date +%Y-%m-%d-%H%M)
SAFE_KEYWORD=$(echo "$KEYWORD" | tr ' ' '_' | tr '/' '_')
OUTPUT_FILE="$THREADS_BOT_DIR/research/${DATE}-${SAFE_KEYWORD}.json"

mkdir -p "$THREADS_BOT_DIR/research"

echo "🔍 検索中: $KEYWORD ($SEARCH_TYPE)"

RES=$(curl -s -G "https://graph.threads.net/v1.0/keyword_search" \
  --data-urlencode "q=${KEYWORD}" \
  --data-urlencode "search_type=${SEARCH_TYPE}" \
  --data-urlencode "fields=id,text,media_type,permalink,timestamp,username,has_replies,is_quote_post,is_reply" \
  --data-urlencode "limit=50" \
  --data-urlencode "access_token=${THREADS_ACCESS_TOKEN}")

# エラーチェック
if echo "$RES" | jq -e '.error' > /dev/null 2>&1; then
  echo "❌ 検索失敗"
  echo "$RES" | jq
  exit 1
fi

echo "$RES" > "$OUTPUT_FILE"

COUNT=$(echo "$RES" | jq '.data | length')
echo "✅ 取得件数: $COUNT"
echo "💾 保存先: $OUTPUT_FILE"

# サマリ表示
echo ""
echo "============================="
echo "TOP 5 投稿プレビュー:"
echo "============================="
echo "$RES" | jq -r '.data[0:5] | .[] | "📌 @\(.username) (\(.timestamp[0:10]))\n   \(.text[0:100])\n   \(.permalink)\n"'