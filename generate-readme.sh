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

  # front matter title 抽出
  title=$(awk '
    BEGIN { in_front_matter=0; title="" }
    /^---$/ { in_front_matter = !in_front_matter; next }
    in_front_matter && /^title:/ {
      sub(/^title:[ \t]*/, ""); title=$0
      gsub(/^["'\'' ]+|["'\'' ]+$/,"",title)
      exit
    }
    END { print title }
  ' "$file")

  [ -z "$title" ] && title="${filename%.*}"

  # front matter publication_name 抽出
  publication_name=$(awk '
    BEGIN { in_front_matter=0; publication_name="" }
    /^---$/ { in_front_matter = !in_front_matter; next }
    in_front_matter && /^publication_name:/ {
      sub(/^publication_name:[ \t]*/, ""); publication_name=$0
      gsub(/^["'\'' ]+|["'\'' ]+$/,"",publication_name)
      exit
    }
    END { print publication_name }
  ' "$file")

  [ -z "$publication_name" ] && publication_name="none"

  year=""
  if [[ "$filename" =~ ^([0-9]{4})-[0-9]{2}-[0-9]{2}_ ]]; then
    year="${BASH_REMATCH[1]}"
  fi

  jq --arg path     "$file" \
     --arg filename "$filename" \
     --arg title    "$title" \
     --arg date     "$date_prefix" \
     --arg year     "$year" \
     --arg pub_name "$publication_name" \
    '. + [{"path":$path,"filename":$filename,"title":$title,"date":$date,"year":$year,"publication_name":$pub_name}]' articles.json \
    > articles.tmp.json
  mv articles.tmp.json articles.json
done < <(find articles -type f -not -name '__*.md' -name '*.md')

# 日付順に降順ソート
jq 'sort_by(.date) | reverse' articles.json > articles.sorted.json

# gomplate で README.md 生成
gomplate -d articles=articles.sorted.json -f README.tmpl -o README.md

rm articles.json articles.sorted.json
