1. データベースの作成
CREATE DATABASE memos;

2. テーブルの作成
CREATE TABLE memosdata (
  id UUID PRIMARY KEY NOT NULL,
  title VARCHAR(30) NOT NULL,
  memo_desc VARCHAR(200) NOT NULL,
  created_at TIMESTAMP NOT NULL
);

3. テーブルを操作するロールを作成
CREATE ROLE 名前;
ALTER ROLE 名前 LOGIN;
ALTER ROLE 名前 PASSWORD'パスワード';
GRANT ALL ON テーブル名 TO ロール名;
