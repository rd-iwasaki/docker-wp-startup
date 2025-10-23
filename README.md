# WordPress Local Development Starter Kit

Dockerを利用して、Mac上でWordPressのローカル開発環境を簡単に構築するためのスターターキットです。

## 動作要件

- macOS
- [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/)

## 使い方

プロジェクト用のディレクトリを作成し、その中で以下のいずれかの方法でセットアップを実行します。

### 方法1: コマンド1つで簡単セットアップ（推奨）

ターミナルで以下のコマンドを実行するだけで、必要なファイルがダウンロードされ、セットアップが開始されます。
※{my-wordpress-site}はプロジェクトディレクトリ名に変更してください。

    ```bash
    mkdir my-wordpress-site && cd my-wordpress-site
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rd-iwasaki/docker-wp-startup/main/setup.sh)"
    ```

### 方法2: リポジトリをクローンしてセットアップ

手動でファイルを管理したい場合は、リポジトリをクローンしてからスクリプトを実行します。

    ```bash
    git clone https://github.com/rd-iwasaki/docker-wp-startup.git my-wordpress-site
    cd my-wordpress-site
    bash setup.sh
    ```

---

### セットアップ手順（共通）

上記いずれかの方法でセットアップを開始すると、以下の手順で進みます。

1.  **`.env`ファイルを編集**

    スクリプトが一時停止し、`.env`ファイルの編集を促されます。エディタで`.env`ファイルを開き、WordPress, PHP, MySQLのバージョンなどを好みの設定に変更してください。

2.  **セットアップを再開**

    `.env`の編集が終わったら、ターミナルに戻って`Enter`キーを押してください。Dockerコンテナのビルドと起動が自動的に始まります。

3.  **ログイン**

    セットアップが完了すると、ターミナルにWordPress管理画面のURL、管理者ユーザー名、パスワードが表示されます。
    表示された情報を使って、すぐにWordPressにログインできます。