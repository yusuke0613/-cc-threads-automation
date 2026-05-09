#!/bin/bash
# トークン有効性チェック
set -e
source ~/.threads-env

echo "🔐 トークン状態確認"
echo ""

# /me を叩いて有効性を確認
RES=$(curl -s "https://graph.threads.net/v1.0/me?fields=id,username&access_token=${THREADS_ACCESS_TOKEN}")

if echo "$RES" | jq -e '.error' > /dev/null 2>&1; then
  echo "❌ トークン無効"
  echo "$RES" | jq
  exit 1
fi

USERNAME=$(echo "$RES" | jq -r '.username')
USER_ID=$(echo "$RES" | jq -r '.id')

echo "✅ 有効"
echo "   Username: @$USERNAME"
echo "   User ID: $USER_ID"

# 発行日からの経過日数
if [ -n "$THREADS_TOKEN_ISSUED_AT" ]; then
  ISSUED_EPOCH=$(date -d "$THREADS_TOKEN_ISSUED_AT" +%s 2>/dev/null || gdate -d "$THREADS_TOKEN_ISSUED_AT" +%s)
  NOW_EPOCH=$(date +%s)
  ELAPSED_DAYS=$(( (NOW_EPOCH - ISSUED_EPOCH) / 86400 ))
  REMAINING_DAYS=$(( 60 - ELAPSED_DAYS ))
  
  echo "   発行日: $THREADS_TOKEN_ISSUED_AT"
  echo "   経過: ${ELAPSED_DAYS}日"
  echo "   残り: ${REMAINING_DAYS}日"
  
  if [ $REMAINING_DAYS -lt 7 ]; then
    echo ""
    echo "⚠️  期限が近いです!リフレッシュを推奨"
    echo "   bash ~/.claude/skills/threads-post/scripts/refresh-token.sh"
  fi
fi