---
reveal: true
title: サーバープログラマのための microk8s のすすめ
date: "2019-10-10T00:00:00.000+09:00"
#template: "post"
draft: false
# slug: "slug"
category: "Tech"
tags:
  - "Tech"
description: "サーバープログラマに microk8s で開発/テストするように勧める記事"
socialImage: "/media/42-line-bible.jpg"
---

# &lt;サーバーソフトウェア開発者への microk8s のすすめ>
2019-10-10

===
dai   <!-- .element: class="right" -->

2019-10-10 <!-- .element: class="right" -->

もともとは社内向けに書いたもの。

reveal.js で書いたけれどうまく gatsby に乗らないのでスライド構造は脳内補完してください。

---

## 環境差で動かない問題

- ビルド環境の違い
- 実行環境の違い
- 設定漏れ

>>>

### ビルド環境

- ビルドオプションが違う
- IDE 依存しまくり

>>>

### 実行環境

- ライブラリバージョンが違う
- 依存プログラムを入れ忘れた
- OS バージョンが違う

>>>

### 設定

- アプリ設定
- 謎の儀式が必要
- OS 設定が必要
  - ulimit
  - ディレクトリ構成


>>>

開発したソフトウェアの実行方法は  
開発側が知っている

ビルド/デプロイ要件を明示するのは  
第一に開発側の責務

---

## 対策

- ドキュメント化
- 同等環境
- コード化
- イメージ化

>>>

### ドキュメント化

遺漏なく書くの大変

-> 読んで把握するのも大変

-> 運用現場で改善できない


>>>

### 本番同等環境でテスト

- コストがかかる
- 同等を維持するために設定変更不可
- 開発時のテストには使えない


>>>

### 構築/デプロイのコード化

古代はシェルスクリプト。  
近年は構成管理ツール。 <!-- .element: class="left" -->

- プロジェクト毎に採用ツールが違うので大変
- クラウド時代になって要件が変わった
- クラウド用構成管理ツールも出てきたが...

Note:
  要件. Immutable Infra で更新が不要に。
  クラウドの API との連携
  そもそもコンテナ

>>>

### 実行環境のイメージ化

古代は稼動ディスク丸ごとイメージ化。  
近年は仮想化。コンテナ方式がデファクト。<!-- .element: class="left" -->

- immutable infrastructure
- クラウド、マイクロサービスと相性良い


---

## コンテナによる解決

- ビルド環境の違い  
  ->  コンテナはどこでビルドしても同じ

- 実行環境の違い  
  ->  コンテナ内は同じ環境

- 設定漏れ  
  ->  コンテナ内で設定済み

---

## クラスタの課題

- コンテナ間通信の設定

- コンテナのデプロイ

- 外部サービスとの連携

ops の課題ではあるが、  
ops の選ぶツールに合わせる必要がある

>>>

## コンテナ オーケストレーション

- docker compose / swarm
- 色々
- kubernetes

>>>

### docker compose / swarm
- docker 語が気持ち悪い
- network や storage が不安定  
  (Mac で使えないとか)
- compose はホスト一台で本番には使えない。
- swarm はマルチホストだけど、スケジューリング程度。

>>>

### kubernetes
- コンテナ運用以上のクラスタ構築ツール
- 各クラウドが対応
- 多数の運用ツール
- デファクトスタンダード

>>>

### dev としては

k8s を想定しておけば当分いけそう

k8s 運用を想定して環境問題対策を磨く


---

## k8s & コンテナによる devops プロセス

- 手元の k8s で開発/テスト
- CI 環境の k8s でテスト
- 統合環境の k8s で統合テスト
- 本番環境の k8s へデプロイ

>>>

### dev としては

- コンテナイメージの作成
- 手元の k8s 構築/運用
- k8s デプロイ定義

---

## コンテナイメージの作成

環境差異を無くすため、  
テスト環境から本番環境まで同一イメージ

>>>

### 環境差異

イメージ外部から指定できるように

- ファイル(kubernetes ConfigMap)
- 環境変数
- 起動オプション

>>>

### 初期化処理

- entrypoint スクリプト
  条件分岐のリッチな起動スクリプト
- init container (kubernetes)
  初期化処理は別 container に分離

>>>
### イメージ構築

- Dockerfile
- ansible container
- ほか

Dockerfile は分かりにくいので他にあれば移行したい

---

## 手元の k8s

- minikube  
- microk8s
- k3s  
- kind

>>>

### minikube

仮想マシン Linux 上でシングルノードの k8s を動かす

- 重いような気がする
- 構築がやや大変

>>>

### microk8s

シングルノードで k8s クラスタを運用するためのパッケージ

- 汎用の minikube と違い、シングル前提で設定簡略化
- snap 一発でインストール
- container registry も付いてる

>>>

### k3s + k3d

k3s:
- IoT など低性能ホストで動かすための k8s サブセット
- シングルバイナリでクラスタ起動
- ホストは linux 専

k3d: 
- k3s をマルチノード対応にする

>>>

### kind

docker container 上で kubernetes を動かす。

kubernetes のテスト目的で、開発に便利なツールは備えていない

>>>

### kubeadm

kubernetes クラスタを構築するための便利ツール

---

## microk8s 構築

### docker.io

```
$ sudo apt-get install docker.io
$ sudo addgroup --system docker
$ sudo adduser $USER docker
```

>>>

### microk8s

```
$ sudo snap install microk8s --classic
$ sudo iptables -P FORWARD ACCEPT
$ microk8s.enable registry dns storage
$ microk8s.start
```

kubectl は専用のやつを使う

```
$ microk8s.kubectl apply -f my-cluster-manifesto.yaml
```

>>>

### container registry

localhost:32000 で動いているので、イメージもそこへ push.
マニフェストでそれを指定する。

```
$ docker build . -t localhost:32000/myimage:latest
$ docker push localhost:32000/myimage:latest
```

---
## kubernetes 操作

操作は kubectl.

```
$ kubectl -n &lt;namespace> get &lt;type>
$ kubectl -n &lt;namespace> logs [-f] &lt;pod> [container]
$ kubectl -n &lt;namespace> apply -f &lt;manifesto.yaml>
$ kubectl -n &lt;namespace> delete -f &lt;manifesto.yaml>
$ kubectl -n &lt;namespace> exec [-it] &lt;pod> [-c container] -- &lt;command>
```

>>>

### リソースとマニフェスト

まずはこの辺から
                            
- Pod  
  コンテナホスト。コンテナは複数可。
- Deployment  
  pod のワークロードを管理。スケーリングとか。
- Service  
  pod への静的なエンドポイント。
- Ingress  
  外部から Service への疎通。

---

End. <!-- .element: class="right" -->

# &lt;/ 開発者のための microk8s>

