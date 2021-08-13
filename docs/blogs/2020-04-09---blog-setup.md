---
title: ブログ構築
date: "2020-04-09T18:26:00.000+09:00"
#template: "post"
draft: false
# slug: "slug"
category: "Tech"
tags:
  - "Tech"
description: "Gatsby + Netlify + Markdown のブログサイト構築"
socialImage: "/media/42-line-bible.jpg"
---

このブログの構築はじめ。

## 動機

Qiita で書いてたんだけども、最近の行動は合わなくなってきた。

 - https://www.itmedia.co.jp/news/articles/1912/26/news121.html
   テックコミュニティはブラックボックスには容赦無い批判を浴びせるものだが、
   そういう面倒臭い側面に真摯に向き合わずに上澄みだけ享受しようという感じを受けた。
 - https://www.itmedia.co.jp/news/articles/2003/26/news087.html
   個人情報ビジネス

というわけで引っ越す。

Markdown で書いているので Markdown が使いたい。
数式も。
という条件で漁る。

当初は GitHub Pages を試みたが、数式を使うのにひと手間かかるようだ。
サイトジェネレータ走らせるので、デプロイ前に確認するにはローカルに環境整えないとならない。
といってプラグインなどは制限されていて、自由にカスタマイズできるわけでもない。

お任せは諦めて、サイトジェネレータで静的ページ作ってデプロイするやり方にする。
[Gatsby](https://gatsbyjs.org) というのが、SPA ジェネレータ的なものらしい。面白そうである。
ホスティングは GitOps が簡単にできるらしい [Netlify](https://netlify.com) を使ってみる。

# 開発環境構築

## 1. github repository
リポジトル作っとく。

今回は gatsby-cli をローカルに入れる。
gatsby-cli を入れた node リポジトリの下に、gatsby 用の node リポジトリを作る。gatsby 用のところが git リポジトリ。

```
$ mkdir workdir; cd workdir
$ git clone git@github.com:dai1975/blog
```

## 2. Node.js

Node.js を入れる。バージョンは最近のなら問題なさげで、最新の 13.8.0 にする。
うちは anyenv 使ってるので、

```
$ nodenv install 13.8.0
$ nodenv local 13.8.0

$ node --version
v13.8.0

$ npm --version
6.13.6

$ npm init
package name: (workdir)
version: (1.0.0) 
description: 
entry point: (index.js) 
test command: 
git repository: 
keywords: 
author: 
license: (ISC) 
About to write to /home/dai/d/workdir/package.json:
Is this OK? (yes) 
```

## 3. Gastby

### gatsby-cli

``` shell
$ npm install gatsby-cli
```

`-g` でグローバルに入れれば gatsby コマンドが使える。
ローカルに入れたので、`npx gatsby` になる。以後 `gatsby` とのみ書くので注意。

### ボイラープレート

``` shell
$ gatsby new <site-name> [starter url]
```

と打つ。
スターターは https://www.gatsbyjs.org/starters/?v=2 に色々ある。

依存プラグインでも検索できる。
数式使えそうな gatsby-remark-katex ってのがあったから、これ依存してるやつで。

https://www.gatsbyjs.org/starters/alxshelepenok/gatsby-starter-lumen/ がよいな。
starter URL は https://github.com/alxshelepenok/gatsby-starter-lumen

```
$ gatsby new blog https://github.com/alxshelepenok/gatsby-starter-lumen
```

### dev server

```
$ gatsby develop
```

でローカル 8000 番にサービスする。

### production

```
$ gatsby build
```

で public/ に出力される。develop と違いファイルの最適化などされている。

public/ の確認したければ、`gatsby serve`

## 開発

### config.js
URL とかタイトルとかはここに書くようだ。
適当に編集して保存。

静的ファイルは static/ 以下に置き、public/ にコピーされるようである。
photo.jpg の名前を変えて /static/photo.jpg を消したらエラーになった。
決め打ちのファイル名などはあまり変更しない方がよさそうだ。

### content/posts/

ブログ記事はここに置くようだ。
先頭部分に yaml で設定を書ける。
設定の詳細はまた調べる。

デフォルトでいくつかファイルがあるので参考にして消す。
ファイル名が YYYY-DD-MM---title.md にいなってるけど命名規約なんだろうか。


### content/page/

時系列でない記事の置き場所かな。

## デプロイ

### Netlify
Netlify のサイトで "new site from git" を選択。

 1. GitHub を選択。リダイレクトされるのでアクセスを許可。
 2. リポジトリ選択。まず GitHub へ飛んでリポジトリへのアクセス許可。続いてリポジトリを選ぶ。
 3. ブランチを選択。Build command に "gatsby build", Publish directory に "public" を入力。
    gatsby のドキュメントでは "npm run build" になっている。gatsby build は production 用で最適化されるらしい。
    gatsby のボイラープレートに netlify.toml があり、こっちが使われるかもしれない

あとは master に push すれば自動的にデプロイされる。

# 数式
肝心かなめの数式。

インライン数式は `$...$` で括る(Qiita と同じ)。

複数行数式は Qiita では ```` ```math...``` ```` で括っていたが、KaTeX では `$$..$$` で括る。

複数行の桁揃えは `\begin{aligned}..\end{aligned}


