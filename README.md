# MemoApp
Sinatraで作成したメモアプリをローカルでお試しいただくことが可能です。
## How to use
1. 右上の Fork ボタンを押してください。
2. #{自分のアカウント名}/MemoApp が作成されます。
3. 作業PCの任意の作業ディレクトリにて `git clone` してください。

```
$ git clone https://github.com/自分のアカウント名/MemoApp.git
```
4. `bundle install` を実行してください。
  - pgがインストールできない場合は以下を実行後に再度`bundle install` を実行してください。

  ```
  bundle config build.pg --with-pg-config=<path to pg_config>
  ```

5. dbinit.mdの手順に従ってPostreSQLでデータベース、テーブル、ロールの作成を行ってください。
6. 5で作成したロールとパスワードをdatabase.ymlに設定してください。
7. `ruby memo_app.rb -p 4567` を実行してください。
8. http://localhost:4567/memos/ にアクセスするとメモアプリをお試しいただくことが可能です。
## 注意
- 新規メモを作成する場合、タイトルと内容は必須です。
- メモのタイトルは1文字以上30文字以内でご入力ください。
- メモの内容は1文字以上200文字以内ご入力ください。