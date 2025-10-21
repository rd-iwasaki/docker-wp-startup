#!/bin/bash

set -euo pipefail

# 色付け用の変数
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- 1. 必要なファイルをGitHubから直接ダウンロード ---

echo -e "${GREEN}▶ 必要なファイルをダウンロードしています...${NC}"
REPO_URL="https://raw.githubusercontent.com/rd-iwasaki/docker-wp-startup/main"

# ダウンロード先のディレクトリを作成
# docker-compose.ymlでマウントするWordPressのコアファイル用ディレクトリ
mkdir -p wordpress

# ファイルのリスト
declare -a FILES=(
    ".env.example"
    "docker-compose.yml"
)

# 各ファイルをダウンロード
for file in "${FILES[@]}"
do
    if [ ! -f "$file" ]; then
        # curl | bash 形式での実行時にも安定して動作するよう、リダイレクトで書き込む
        curl -fsSL "${REPO_URL}/$file" > "$file"
    fi
done
echo -e "${GREEN}✅ ファイルのダウンロードが完了しました。${NC}"
echo ""

# --- 2. 必要なツールのチェック ---
echo -e "${GREEN}▶ 必要なツールをチェックします...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Dockerが見つかりません。Docker Desktopをインストールしてください。${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Dockerがインストールされています。${NC}"
echo ""

# --- 3. .envファイルの作成 ---
if [ ! -f .env ]; then
    echo -e "${YELLOW}▶ .envファイルが見つかりません。コピーして作成します。${NC}"
    cp .env.example .env
    echo -e "${GREEN}✅ .envファイルを作成しました。${NC}"
    echo ""
    echo "--------------------------------------------------"
    echo -e "${YELLOW}次に、.env ファイルを編集して、使用するWordPressやPHPのバージョンを設定してください。${NC}"
    echo -e "特に ${YELLOW}PHP_VERSION${NC} は ${YELLOW}8.2${NC} のようにマイナーバージョンまでを指定してください。（例: 8.2.1 はNG）"
    echo "VSCodeなどのエディタで .env ファイルを開いて編集します。"
    echo "編集が終わったら、このターミナルに戻ってEnterキーを押してください..."
    echo "--------------------------------------------------"
    # パイプ経由の実行でもターミナルからの入力を待つために < /dev/tty を使用
    read -p "" < /dev/tty
fi

# --- 4. Dockerコンテナのビルドと起動 ---
echo -e "${GREEN}▶ Dockerコンテナをビルドし、起動します...${NC}"

# Dockerデーモンが起動しているか確認
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Dockerデーモンが起動していません。Docker Desktopを起動してから再度お試しください。${NC}"
    exit 1
fi

docker-compose up -d --build

# --- 5. 完了メッセージ ---
echo ""
echo -e "${GREEN}✅ 環境構築が完了しました！${NC}"

# .envファイルからポート番号を読み込んでURLを表示
WORDPRESS_PORT=$(grep WORDPRESS_PORT .env | cut -d '=' -f2)
echo "WordPressの初期設定画面にアクセスしてください: ${YELLOW}http://localhost:${WORDPRESS_PORT}${NC}"
echo ""