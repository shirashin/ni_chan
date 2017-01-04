# 2ch.netデータ取得用ライブラリ

## 機能

* ff2ch.syoboi.jpからスレッドを検索
* 2ch.netからポストを取得

## ディレクトリ構成

```
├── Gemfile
├── Gemfile.lock
├── README.md           # このファイル
├── lib
│   └── ni_chan.rb      # ライブラリ本体
└── sample.rb           # サンプルプログラム
```

## 使い方

rubyとかbundlerはインストール整っている前提

### スレッドの一覧を取得
thread = NiChan::Search.new(keyword)

### スレッドの投稿を取得
thread = NiChan::Thread.new(url)

```
  bundle install
  bundle exec ruby sample.rb ほげほげ
```


