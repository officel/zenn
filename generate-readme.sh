#!/usr/bin/env bash
set -euo pipefail

# JSON 初期化
jq -n '[]' > articles.json

# articles 以下の Markdown のみ処理
while IFS= read -r file; do
  filename=$(basename "$file")
  date_prefix=""
  if [[ "$filename" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})_ ]]; then
    date_prefix="${BASH_REMATCH[1]}"
  fi

  # frontmatter title 抽出
  title=$(awk '
    BEGIN { in_frontmatter=0; title="" }
    /^---$/ { in_frontmatter = !in_frontmatter; next }
    in_frontmatter && /^title:/ {
      sub(/^title:[ \t]*/, ""); title=$0
      gsub(/^["'\'' ]+|["'\'' ]+$/,"",title)
      exit
    }
    END { print title }
  ' "$file")

  [ -z "$title" ] && title="${filename%.*}"

  year=""
  if [[ "$filename" =~ ^([0-9]{4})-[0-9]{2}-[0-9]{2}_ ]]; then
    year="${BASH_REMATCH[1]}"
  fi

  jq --arg path "$file" --arg title "$title" --arg date "$date_prefix" --arg year "$year" \
    '. + [{"path":$path,"title":$title,"date":$date,"year":$year}]' articles.json \
    > articles.tmp.json
  mv articles.tmp.json articles.json
done < <(find articles -type f -name '*.md')

# 日付順に降順ソート
jq 'sort_by(.date) | reverse' articles.json > articles.sorted.json

# gomplate で README.md 生成
gomplate -d articles=articles.sorted.json -f README.tmpl -o README.md

rm articles.json articles.sorted.json
