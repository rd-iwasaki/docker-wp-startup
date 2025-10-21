#!/bin/bash

set -euo pipefail

# --- 1. 必要なファイルをGitHubから直接ダウンロード ---

echo "▶ 必要なファイルをダウンロードしています..."
REPO_URL="https://raw.githubusercontent.com/rd-iwasaki/docker-wp-startup/main"


# ダウンロード先のディレクトリを作成
mkdir -p public

# ファイルのリスト
declare -a FILES=(
    ".env.example"
    "docker-compose.yml"
    "public/"
)

# 各ファイルをダウンロード
for file in "${FILES[@]}"
do
    if [ ! -f "$file" ]; then
        curl -fsSL -o "$file" "${REPO_URL}/$file"
    fi
done
echo "✅ ファイルのダウンロードが完了しました。"