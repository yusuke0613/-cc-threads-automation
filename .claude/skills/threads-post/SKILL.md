---
name: threads-post
description: Threadsでバズる投稿のリサーチから本文生成、投稿までを半自動化する。社内SE転職領域の20-30代ITエンジニア向けコンテンツに特化。「バズ投稿を調べて」「Threadsに投稿」「下書き作って」「Threadsの最近のトレンド」などと言われたら起動。
---

# Threads投稿スキル (you_white_tensyoku運用)

## このスキルの役割

社内SE転職領域のThreadsアカウント @you_white_tensyoku の運用を支援する。
リサーチ→本文生成→確認→投稿の半自動フロー。

## 環境変数

実行前に必ず読み込む:
`source ~/.threads-env`

データディレクトリは `$THREADS_BOT_DIR` で参照する (デフォルト: `/Users/satouyuusuke/Library/Mobile Documents/com~apple~CloudDocs/cc/threads-automation/threads-bot`)。スクリプト/SKILL内のパス記述はこの変数経由で統一。

## ワークフロー: 4つのモード

### モード1: バズ投稿リサーチ

ユーザーが「○○のバズ投稿調べて」「最近のトレンド見て」と言ったら起動。
→ `bash ~/.claude/skills/threads-post/scripts/research.sh "キーワード"`
→ 結果は $THREADS_BOT_DIR/research/YYYY-MM-DD-keyword.json に保存
→ JSONを読んで人気投稿の傾向 (構成、文体、フックの作り方) を分析してユーザーに報告

### モード2: 下書き生成

ユーザーが「テーマ○○で下書き作って」と言ったら起動。

1. 必要ならリサーチ結果を参考にする
2. 下記の「コンテンツ生成ガイドライン」に従って本文を生成
3. $THREADS_BOT_DIR/drafts/YYYY-MM-DD-HHMM-keyword.md に保存
4. ユーザーに本文を表示して確認を求める

### モード3: 投稿実行

ユーザーが下書きを見て「これで投稿して」「OK」と言ったら起動。
→ `bash ~/.claude/skills/threads-post/scripts/post-text.sh <下書きファイルパス>`
→ 成功したら下書きファイルは $THREADS_BOT_DIR/posted/ に移動

### モード4: トークン管理

- 「トークン状態」 → `bash ~/.claude/skills/threads-post/scripts/check-token.sh`
- 「トークン更新」 → `bash ~/.claude/skills/threads-post/scripts/refresh-token.sh`

## 重要なルール (絶対に守る)

1. **生成→確認→投稿の順序を厳守**。「生成して投稿」と言われても、必ず一度本文を出して確認を取る
2. **ハッシュタグは1つだけ**。Threads APIの制限
3. **500文字以内**を目安にする (絶対上限ではないが伸びすぎ注意)
4. 生成したコンテンツは必ず $THREADS_BOT_DIR/drafts/ に保存してからユーザーに見せる
5. 投稿後は $THREADS_BOT_DIR/logs/posts.jsonl にログが追記される
6. トークンが残り7日以下なら自動リフレッシュを提案する

## コンテンツ生成ガイドライン

### ターゲット

20-30代の日本のITエンジニア (SES/SIer所属、転職検討層、子育て世代も含む)

### トーン

- 共感+データドリブン
- 煽らない、過度な誇張しない
- 当事者経験を匂わせる (「自分も○○だった」系)
- 結論を冒頭で示す (Threadsはタイムライン消費型)

### 構成パターン

- A. 共感→転換→提案型: 「〜で消耗してませんか?」→「実は〜」→「具体的には〜」
- B. データ提示型: 「〜のデータを見ると〜」
- C. 比較型: 「SES vs 社内SE」
- D. チェックリスト型: 「こんな会社は危険5選」
- E. ロードマップ型: 「未経験から社内SEまでの道のり」

### NGワード

- 「絶対」「必ず」(誇大広告該当の恐れ)
- 競合企業の悪口
- 個人を特定可能な批判

### よく使うハッシュタグ (1つだけ選ぶ)

- #社内SE
- #IT転職
- #ホワイト企業
- #SES辛い
- #エンジニア転職

## ファイル構成

$THREADS_BOT_DIR/
├── drafts/ # 下書き .md (未投稿)
├── posted/ # 投稿済み .md
├── research/ # リサーチ結果 .json
└── logs/
├── posts.jsonl # 投稿ログ
└── errors.jsonl # エラーログ

## トラブルシューティング

- `threads_basic permission` → トークン期限切れ。check-token.sh実行
- `Media not ready` → sleep秒数を増やす
- `Rate limit exceeded` → 24時間で250投稿超過。翌日まで待つ
- `Invalid creation_id` → コンテナ作成→公開の間隔が長すぎ (1時間以内)

## 参照

- API詳細: references/api-reference.md
- テンプレート集: references/content-templates.md
