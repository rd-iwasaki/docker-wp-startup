#!/bin/bash

# 色付け用の変数
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

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