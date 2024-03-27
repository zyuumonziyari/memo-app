# memo-app
## memo-appの有益性
    シンプルなメモ機能が、あなたの意思決定を支える。

## DBの準備（PostgreSQL）
    メモアプリを使用する前に、メモを保存する為のDBを作成しよう。
* データベースの確立〜ログイン（PostgreSQのインストール後）
    1. ターミナルで下記コマンドを入力し、'memo_app'データベースを'postgres'ユーザー（所有者指定）で作成する。
    
        ```createdb memo_app -O postgres```
    2. psqlコマンドを使用してユーザー名'postgres'を指定し、ログインする。
    
         ```psql -U postgres memo_app```
* テーブルの作成
    1. 'memos'テーブルの作成する。
        ```postgres
        memo_app=# CREATE TABLE memos (
        id VARCHAR(36) DEFAULT gen_random_uuid() PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        content TEXT,
        created_at TIMESTAMP WITH TIME ZONE,
        updated_at TIMESTAMP WITH TIME ZONE
        );
        ```
    2. 作成したテーブルを確認する。
        ```postgres
        memo_app=# SELECT * FROM memos
        ;
         id | title | content | created_at | updated_at
        ----+-------+---------+------------+------------
        (0 行)
        ```

## memo-appを立ち上げる
    メモアプリはもう、あなたの目の前。ローカル環境で立ち上げてください。
1. 任意のディレクトリに移動
2. ```git clone https://github.com/zyuumonziyari/memo-app```
3. ```bundle install```
4. ```bundle exec ruby memo_app.rb```
5. " Listening on http://127.0.0.1:4567" にアクセス

## memo-appの使い方
    あと少し。
* memo-appにアクセス
    URLに以下アドレスを入力してトップページにアクセス
    http://127.0.0.1:4567

*  トップページの確認（作成したメモ一覧ができる）
*  メモの新規作成
    1. トップページにある追加リンクをクリックし、新規作成ページ（http://127.0.0.1:4567/new）へ遷移する。
    2. タイトル、内容をフォームに入力し、"保存する"ボタンをクリック。
    3. トップページへ遷移するので、作成したメモが表示されていることが確認できる。
* 作成したメモの編集
    1. トップページに表示されているメモのリンクをクリック。
    2. メモの詳細ページ（http://127.0.0.1:4567/:{メモid番号}）へ遷移する。
    3. メモ内容の下部に、"編集"リンクをクリック。
    4. タイトルと内容欄に任意の変更を行い、"変更する"ボタンをクリック。
    5. メモの詳細ページ（http://127.0.0.1:4567/:{メモid番号}）へ遷移するので、変更内容を確認できる。
* 作成したメモの削除
    1. トップページに表示されているメモのリンクをクリック。
    2. メモの詳細ページ（http://127.0.0.1:4567/:{メモid番号}）へ遷移する。
    3. メモ内容の下部に、"削除する"ボタンをクリック。
    4. トップページに遷移するので、該当のメモが削除されているか確認できる。

##### 最後まで読んでいただきありがとうございます。お待たせしました。思うままにご使用ください。 
## memo-appの開発・メンテナンス担当者
soichiro
