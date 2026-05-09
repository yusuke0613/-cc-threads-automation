# Threads API リファレンス

## 認証

- 長期トークン: 60日有効
- リフレッシュ: 24時間後〜60日以内に可能

## 投稿エンドポイント

- コンテナ作成: POST /v1.0/{user-id}/threads
- 公開: POST /v1.0/{user-id}/threads_publish
- 削除: DELETE /v1.0/{thread-id}

## 検索エンドポイント

- /v1.0/keyword_search
- パラメータ: q, search_type (TOP/RECENT), search_mode (KEYWORD/TAG), media_type, since, until, limit, author_username

## レート制限

- 投稿: 24h で 250投稿
- 検索: 24h で 2200クエリ
- ハッシュタグ: 1投稿に1つ

## media_type

- TEXT
- IMAGE (image_url パラメータ必須)
- VIDEO (video_url パラメータ必須)
- CAROUSEL (children パラメータでアイテムIDをカンマ区切り)

## カルーセル子要素

is_carousel_item=true で IMAGE/VIDEO コンテナを作成 → CAROUSELコンテナにまとめる

## ツリー投稿

reply_to_id=<親投稿ID> をコンテナ作成時に渡す
