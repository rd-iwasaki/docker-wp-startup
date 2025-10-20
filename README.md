# WordPress Local Development Starter Kit

Dockerを利用して、Mac上でWordPressのローカル開発環境を簡単に構築するためのスターターキットです。

## 動作要件

- macOS
- [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/)

## 使い方

1.  **リポジトリをクローン**

    ```bash
    git clone <このリポジトリのURL> my-wordpress-site
    cd my-wordpress-site
    ```

2.  **セットアップスクリプトを実行**

    ターミナルで以下のコマンドを実行します。

    ```bash
    bash setup.sh
    ```

3.  **`.env`ファイルを編集**

    スクリプトが一時停止し、`.env`ファイルの編集を促されます。エディタで`.env`ファイルを開き、WordPress, PHP, MySQLのバージョンなどを好みの設定に変更してください。

4.  **セットアップを再開**

    `.env`の編集が終わったら、ターミナルに戻って`Enter`キーを押してください。Dockerコンテナのビルドと起動が自動的に始まります。

5.  **アクセス**

    セットアップ完了後、ターミナルに表示されるURL（デフォルト: `http://localhost:8080`）にブラウザでアクセスすると、WordPressの初期設定画面が表示されます。