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
    "plugins.txt"
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

# .envからポート番号を読み込み、使用中かチェック
source .env
if lsof -i -P -n | grep -q ":${WORDPRESS_PORT} (LISTEN)"; then
    echo -e "${RED}❌ エラー: ポート ${WORDPRESS_PORT} は既に使用されています。${NC}"
    echo -e "${YELLOW}他のプロセスを停止するか、.env ファイルの WORDPRESS_PORT を別の番号に変更してください。${NC}"
    exit 1
fi

docker-compose up -d --build

# --- 5. WordPressの初期設定とプラグインのインストール ---
echo ""
echo -e "${GREEN}▶ WordPressの初期設定とプラグインのインストールを行います...${NC}"

# .envから必要な変数を読み込む
source .env

# データベースが利用可能になるまで待機
echo "データベースの準備が整うまで待機しています..."
until docker-compose exec db mysqladmin ping -h"localhost" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
    echo -n "."
    sleep 2
done
echo -e "\n${GREEN}✅ データベースの準備が完了しました。${NC}"

# WordPressのコアファイルがボリュームにコピーされるまで待機
echo "WordPressのコアファイルが準備されるまで待機しています..."
until docker-compose exec wordpress test -f /var/www/html/wp-config-sample.php; do
    echo -n "."
    sleep 2
done
echo -e "\n${GREEN}✅ WordPressのコアファイルが準備されました。${NC}"

# wp-config.phpを作成
echo "wp-config.phpを作成しています..."
docker-compose exec wp-cli wp config create \
    --dbname="${MYSQL_DATABASE}" --dbuser="${MYSQL_USER}" --dbpass="${MYSQL_PASSWORD}" --dbhost="db:3306" \
    --allow-root

# SSL接続エラーを回避するために設定を追加
docker-compose exec wp-cli wp config set 'MYSQL_CLIENT_FLAGS' 0 --type=variable --anchor='$table_prefix' --allow-root

echo -e "${GREEN}✅ wp-config.phpが作成されました。${NC}"

# WordPressがインストール済みかチェック
if ! docker-compose exec wp-cli wp core is-installed --allow-root; then
    echo "WordPressをインストールします..."

    # サイト名、管理者情報を指定してインストール
    docker-compose exec wp-cli wp core install --url="http://localhost:${WORDPRESS_PORT}" --title="${WORDPRESS_SITE_TITLE}" --admin_user="${WORDPRESS_ADMIN_USER}" --admin_password="${WORDPRESS_ADMIN_PASSWORD}" --admin_email="${WORDPRESS_ADMIN_EMAIL}" --allow-root
else
    echo "WordPressは既にインストールされています。"
fi

# plugins.txtからプラグインをインストール
if [ -f "plugins.txt" ]; then
    echo "プラグインをインストール・有効化します..."
    # xargsを使って、ファイル内の各行を引数としてwp-cliに渡す
    # 空行は無視するように grep . を挟む
    grep . plugins.txt | xargs -I {} docker-compose exec wp-cli wp plugin install {} --activate --allow-root
fi

# --- 6. 完了メッセージ ---
echo ""
echo -e "${GREEN}✅ 環境構築が完了しました！${NC}"

# .envファイルからポート番号を読み込んでURLを表示
echo "WordPressサイトにアクセスしてください: ${YELLOW}http://localhost:${WORDPRESS_PORT}/wp-admin/${NC}"
echo "管理者ユーザー名: ${YELLOW}${WORDPRESS_ADMIN_USER}${NC}"
echo "管理者パスワード: ${YELLOW}${WORDPRESS_ADMIN_PASSWORD}${NC}"
echo ""