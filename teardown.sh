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

echo "--------------------------------------------------"
echo -e "${YELLOW}警告: これにより、Dockerコンテナとデータベースのデータが完全に削除されます。${NC}"
read -p "よろしいですか？ (y/N): " -n 1 -r < /dev/tty
echo "--------------------------------------------------"

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}▶ コンテナとボリュームを削除しています...${NC}"
    docker-compose down -v

    echo -e "${GREEN}▶ 生成されたファイルを削除しています...${NC}"
    rm -f php/uploads.ini

    echo -e "${GREEN}✅ クリーンアップが完了しました。${NC}"
else
    echo "キャンセルしました。"
fi