#!/bin/bash

# スクリプトがどのディレクトリで実行されても、スクリプト自身の場所を基準に動作するようにします。
# ただし、`curl ... | bash` や `bash -c "$(curl ...)"` のように実行された場合は、
# ユーザーがコマンドを実行したカレントディレクトリを基準とします。
SCRIPT_DIR="$(dirname "$0")"
if [ "$SCRIPT_DIR" = "/" ] || [ "$SCRIPT_DIR" = "." ]; then
  # $0 が 'bash' や '-' の場合 (curl経由実行時など)、カレントディレクトリを使用
  # 何もしない (既にカレントディレクトリで実行されているため)
  :
else
  cd "$SCRIPT_DIR"
fi

# 色付け用の変数
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# --- curl経由での実行に対応 ---
# 必要なファイルが存在しない場合、GitHubからダウンロードします。
REPO_RAW_URL="https://raw.githubusercontent.com/rd-iwasaki/docker-wp-startup/main"

if [ ! -f "docker-compose.yml" ]; then
  echo -e "${GREEN}docker-compose.yml をダウンロードします...${NC}"
  curl -fsSL -o docker-compose.yml "${REPO_RAW_URL}/docker-compose.yml"
fi

if [ ! -f ".env.example" ]; then
  echo -e "${GREEN}.env.example をダウンロードします...${NC}"
  curl -fsSL -o .env.example "${REPO_RAW_URL}/.env.example"
fi
# --- ここまで ---


# Dockerがインストールされているかチェック
if ! [ -x "$(command -v docker)" ]; then
  echo -e "${YELLOW}エラー: Dockerがインストールされていないようです。Docker Desktopをインストールしてください。${NC}" >&2
  exit 1
fi

# .envファイルが存在するかチェック
if [ ! -f .env ]; then
  echo -e "${YELLOW}.env ファイルが見つかりません。${NC}"
  echo -e "'.env.example' をコピーして '.env' を作成します。"
  cp .env.example .env
  echo -e "${GREEN}.env ファイルを作成しました。${NC}"
fi

echo "--------------------------------------------------"
echo -e "${YELLOW}次に、.env ファイルを編集して、使用するWordPressやPHPのバージョンを設定してください。${NC}"
echo "VSCodeなどのエディタで .env ファイルを開いて編集します。"
echo "編集が終わったら、このターミナルに戻ってEnterキーを押してください..."
echo "--------------------------------------------------"

# ユーザーがEnterキーを押すのを待つ
read -p ""

echo -e "${GREEN}設定を読み込み、環境構築を開始します...${NC}"

# .env ファイルを読み込んでDocker Composeを起動
docker-compose up -d --build

echo "--------------------------------------------------"
echo -e "${GREEN}環境構築が完了しました！${NC}"
echo ""
echo "WordPressサイトにアクセスしてください:"
echo -e "URL: ${YELLOW}http://localhost:$(grep WORDPRESS_PORT .env | cut -d '=' -f2)${NC}"
echo ""
echo "コンテナを停止するには 'docker-compose down' を実行してください。"
echo "--------------------------------------------------"