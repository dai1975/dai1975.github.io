---
title: gatsby から mkdocs へ移行
date: "2021-08-13T18:26:00.000+09:00"
draft: false
# slug: "slug"
category: "Tech"
tags:
  - "Tech"
---
# gatsby から mkdocs へ移行

以前の gatsby 環境は依存ライブラリが壊れててビルドできなくなっていた。

とりあえず Gatsby の更新をしてみたのだが、katex がなんかうまく動かない。
頑張ってもよいのだが、数ヶ月ペースにはちょっと更新が早すぎるかなぁ。

それに gatsby も v3 になって、static page generator から static が抜け落ちているのも気になる。
そもそもの要求として、単に markdown からブラウザで見れる静的ページを作るだけでよい。

と、色々探したところ mkdocs が良い感じぽいので移る。

# mkdocs

```
$ pip install mkdocs
$ python -m mkdocs new <dir>
$ cd <dir>
$ python -m mkdocs serve
$ firefox http://localhost:8000/
```

記事は gatsby + katex をそのままコピーして数式が表示できた。
冒頭の設定部分の template が悪さをするのでコメントアウト。

## katex

```
$ pip install markdown-katex
$ touch macros.tex
```

さらに mkdocs.yml を編集し、

``` yaml
markdown_extensions:
  - markdown_katex:
      no_inline_svg: True
      insert_fonts_css: True
      macro-file: macros.tex
```

数式はブロックなら ```` ```math ```` から ```` ``` ```` の間に、インラインなら `` $` `` と `` `$ `` の間に書く。

```math
\begin{aligned}
 R &= g^{\frac{1}{k}} \\
 r &= H'(R) \\
 s &= k(H(m) + xr) \\
\end{aligned}
```

どうも数式入るとかなり遅くなっちゃうな。

## deploy

mkdocs gh-deploy で github pages にデプロイしてくれる。
デフォルトだと gh-pages ブランチの / 以下。
ここを表示するように setting を変えておく。

