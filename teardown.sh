#!/bin/bash

set -euo pipefail

# 色付け用の変数
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}▶ WordPress環境のクリーンアップを開始します...${NC}"

# .envファイルが存在するか確認
if [ ! -f .env ]; then
    echo -e "${RED}❌ .env ファイルが見つかりません。プロジェクトのルートディレクトリで実行してください。${NC}"
    exit 1
fi

# Docker Composeコマンドのチェック
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
elif docker-compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
else
    echo -e "${RED}❌ Docker Composeが見つかりません。Docker Desktopをインストールまたは更新してください。${NC}"
    exit 1
fi

echo "--------------------------------------------------"
echo -e "${RED}警告: これにより、Dockerコンテナとデータベースのデータが完全に削除されます。${NC}"
read -p "よろしいですか？ (y/N): " -n 1 -r < /dev/tty
echo ""
echo "--------------------------------------------------"

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}▶ コンテナとボリュームを削除しています...${NC}"
    # 存在するコンテナのみを対象とするため、エラーを無視する
    ${DOCKER_COMPOSE_CMD} down -v 2>/dev/null || true

    echo -e "${GREEN}▶ 生成されたファイルを削除しています...${NC}"
    rm -f php/uploads.ini

    echo -e "${GREEN}✅ クリーンアップが完了しました。${NC}"
else
    echo "キャンセルしました。"
fi