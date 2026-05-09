#!/bin/bash
# トークンリフレッシュ (60日延長)
set -e
source ~/.threads-env

echo "🔄 トークンリフレッシュ中..."

RES=$(curl -s "https://graph.threads.net/refresh_access_token?grant_type=th_refresh_token&access_token=${THREADS_ACCESS_TOKEN}")

NEW_TOKEN=$(echo "$RES" | jq -r '.access_token // empty')
EXPIRES_IN=$(echo "$RES" | jq -r '.expires_in // empty')

if [ -z "$NEW_TOKEN" ]; then
  echo "❌ リフレッシュ失敗"
  echo "$RES" | jq
  exit 1
fi

echo "✅ 新しいトークン取得"
echo "   有効期限: ${EXPIRES_IN}秒 (約 $((EXPIRES_IN / 86400))日)"

# ~/.threads-env を更新
TODAY=$(date +%Y-%m-%d)

# バックアップ
cp ~/.threads-env ~/.threads-env.bak

# トークン書き換え
sed -i.tmp "s|export THREADS_ACCESS_TOKEN=.*|export THREADS_ACCESS_TOKEN=\"$NEW_TOKEN\"|" ~/.threads-env
sed -i.tmp "s|export THREADS_TOKEN_ISSUED_AT=.*|export THREADS_TOKEN_ISSUED_AT=\"$TODAY\"|" ~/.threads-env
rm ~/.threads-env.tmp

echo "💾 ~/.threads-env を更新"
echo "💾 バックアップ: ~/.threads-env.bak"