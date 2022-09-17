---
title: 秘匿スマートコントラクト
date: "2022-09-17T00:00:00.000+09:00"
#template: "post"
draft: false
# slug: "slug"
category: "Tech"
tags:
  - "Tech"
  - "Blockchain"
description: "秘匿スマートコントラクト"
#socialImage: "/media/42-line-bible.jpg"
---
# 秘匿スマートコントラクト
2022-09-17

一般的にパブリックチェーンにデータを書くと誰でも見れてしまう。
スマートコントラクトベースで鍵を掛けても、ブロックチェーンのトランザクションデータを見るとバレる。

一方、情報を秘匿したいケースは色々ある。

 - 個人情報
 - 営業秘密
 - フロントランニング対策

というわけで、データを秘匿できるスマートコントラクト技術について調べる。
なお、調査は2022年6月時点のもの。

---
# チェーン
## HyperLedger Fabric

* Channel 機能
チャンネル毎の個別の台帳。
参加してる組織以外からは見えない。

* Private Data 機能
台帳外の DB に保存し、Peer 同士で直接交換する。
台帳には Private Data の Hash が格納される。

* Private Chaincode
トランザクションおよびデータを暗号化した状態で実行する。
まだ本体に取り込まれていない。

Trusted Execution Environment(TEE) を利用。intel cpu なら SGX.
C/C++ で記述。

計算は秘密にできても、結果を保存するストレージは秘密にならんような。
それも暗号化した結果を保存するのかな。

---
## ZeroChain
LaynerX の人が開発したやつ。
アカウント型ブロックチェーンへ適用とのことだが、残高計算だけでスマコンではないようだ。

2019年から更新されてないや。

---
## Secret Network (SCRT)
- https://scrt.network
- https://github.com/scrtlabs/SecretNetwork 387star. Rust.

2016年開始、2020年ローンチ。
Cosmos で動くセキュリティスマートコントラクト。
コントラクトは TEE 内で実行、暗号化したデータをストレージに格納。

アクセス制御はスマコン内でやる。
msg の署名で認証。

query の場合は msg が無いので、パラメータで署名なり受けとる。


---
## Oasis Network (ROSE)
- https://oasisprotocol.org/
- https://github.com/oasisprotocol/oasis-core 254star. Golang.

a16z.
1000tps のコンセンサス担当の Layer1 と、コントラクトを動かす 2ndレイヤー(ParaTime という)

暗号化したストレージに秘密鍵ベースで権限管理できるクラウドサービスぽいやつ。

秘匿スマコンも開発中だけどまだ。

2022-09 追記: 最近日本のブロックチェーンゲームでよく採用されてる。秘匿より速度目当てぽいが。

---
## Aleo
- https://www.aleo.org/
- https://github.com/AleoHQ/aleo 99Star. Rust.

a16z. ソフトバンク。

独自チェーンに独自言語。
端末上にデータを置き、ゼロ知識証明でチェーンに載せるらしい。

なんか計算するだけでデータストアとかは範囲外のような?


---
## Phala Network (PHA)
- https://www.phala.network/
- https://github.com/Phala-Network 273star, Rust.

Web3 Foundation.

TEE の p2p computing.

Kusama 上で稼動中。
Kusama は Polkadot の実験チェーンだが、無くなったりはしないようだ。

---
## Automata Network (ATA)
- https://ata.network
- https://github.com/automata-network 80star, Rust.

Ethereum の Layer2. 2021年11月稼動。
Avalanche, Polygon の協力で開発。
"Privacy middleware for dApps on Web3"

マルチチェーンで使えるセキュリティミドルウェアを提供する感じ。
たぶんミドルウェアはコントラクトから呼べるのだろう。もしくは Web サービスから?
何にせよミドルウェアの充実が必要だが、まだまだ開発中。

---
## Horizen
- https://horizen.io

ZK-snarks.

---
## Dero
- https://dero.io

準同型


---
# 追記

まとめ記事発見。
この記事には未反映。

https://medium.com/hashkey-group/privacy-networks-the-future-of-smart-contract-platforms-315d9fdf7cef

