---
title: Rust のネットワークライブラリ/フレームワーク
date: "2016-10-15T00:00:00.000+09:00"
#template: "post"
draft: false
# slug: "slug"
category: "Tech"
tags:
  - "Tech"
  - "Rust"
description: Rust のネットワークライブラリ/フレームワークを調査してまとめた。
#socialImage: "/media/42-line-bible.jpg"
---
# 注意
2016年秋ごろの調査なので最新状況は違ってます

# 動機
なんか色々あるけどよく分からんので crates.io をサーベイ。

最新版の日付と総ダウンロード数も合わせてリストアップ。
~~echo サーバー作るときの典型的設計も軽く付記。~~
echo じゃなくて、単純にサーバー側で出力するだけのコード。

## [std::net](https://doc.rust-lang.org/std/net/)
BSD socket API 同等。select 系は無さげ。

```
   let mut buf = [0u8; 1024];
   loop {
      match conn.read(&mut buf[0..]) {
         Ok(0) => {
            println!("read: closed");
            return Ok(());
         }
         Ok(n) => {
            println!("recv[{}]: {}", n, std::str::from_utf8(&buf[0..n]).unwrap());
         }
         Err(e) => {
            match e.kind() {
               std::io::ErrorKind::WouldBlock => (),
               _ => return Err(format!("read: {}", e)),
            }
         }
      }
      std::thread::sleep(sleeptime);
   }
```
古典的。

## [net2](https://crates.io/crates/net2) 2016-07-16(0.2.26) 236,294
std::net のラッパ。

bind とか reuse_address とかを連結して書けるだけ？
listen/connect した後は net の TcpListener や TcpStream になる。

```
  net2::TcpBuilder::new_v4()
    .and_then(|t| {t.reuse_address(true)})
    .and_then(|t| {t.bind(addr)}
    .and_then(|t| {t.listen(backlog)})
```
Rust だとエラー不確定状態のモナド繋げるよりは try! で一処理ずつチェックかけるスタイルだし、
ネットワークプログラミングのキモは接続した後の処理であるから、bind/listen のとこだけスタイル変えられてもどうでもいい感じである。

## [mio](https://crates.io/crates/mio) 2016-09-02(0.6.0) 131,570
軽量のノンブロッキングI/Oライブラリ。
net2 に依存。
epoll な感じのイベントループで書く。

```
   let poller = mio::Poll::new().unwrap();
   let token_id  = 0;
   let mut conn: mio::tcp::TcpStream = ...;
   poller.register(&conn, mio::Token(token_id), mio::Ready::readable(), mio::PollOpt::edge()).unwrap();

   let mut buf = [0u8; 1024];
   let mut events = mio::Events::with_capacity(1024);
   loop {
      poller.poll(&mut events, None).unwrap();
      for ev in events.iter() {
         match ev.token() {
            mio::Token(id) if id == token_id => {
               match conn.read(&mut buf[0..]) {
                  Ok(0) => {
                     println!("read: closed");
                     return Ok(());
                  }
                  Ok(n) => {
                     println!("recv[{}]: {}", n, std::str::from_utf8(&buf[0..n]).unwrap());
                  }
                  Err(e) => {
                     return Err(format!("read: {}", e));
                  }
               }
            }
            mio::Token(_) => (),
         }
      }
   }
```
受信イベント判定のちに read するから、wouldblock は起きない、と。
この書き方のメリットや限界は select/epoll 系そのまんまですな。

あと実際は listener も poller に突っ込むよろし。

# mio 依存
## [rotor](https://crates.io/crates/rotor) 2016-05-21(0.6.3) 18,705
StateMachine らしいが…どういう構造なのかさっぱり分からんｗ
dns, redis, http なんかの実装もあるので、それなりのフレームワークにはなっているんだろうけども。
rotor-stream ってので、プロトコルが書けるみたい。

## [tokio-core](https://crates.io/crates/tokio-core) 2016-09-10(0.1.0) 3,214
イベントループと future によるリアクティブスタイルの API
future は同じ作者の [future](https://crates.io/crates/futures) crates を使っている。この future で mio を直に使った HTTP サーバーはかなり良いパフォーマンスを出している( https://aturon.github.io/blog/2016/08/11/futures/ )

tokio はこの future を使って [finagle みたいなフレームワークを作る](https://medium.com/@carllerche/announcing-tokio-df6bb4ddb34#.6t8gcc2ap) プロジェクトで、tokio-core が mio と future を組み合わせた部分のようだ。
tokio-service には finagle の Service ぽいクラスがある。
Finagle はいいぞ。

```
pub fn main() -> Result<(), String> {
   let addr = try!(std::net::SocketAddr::from_str("127.0.0.1:10000").map_err(|e| format!("parse: {}", e)));

   let mut core = tokio_core::reactor::Core::new().unwrap();
   let handle = core.handle();
   
   let listener = tokio_core::net::TcpListener::bind(&addr, &handle).unwrap();

   let r = listener.incoming().for_each(move |(conn,_addr)| {
      let buf  = vec![0u8; 1024]; // tokio_core::io::read requires AsMut
      let iter = futures::stream::iter(std::iter::repeat(()).map(Ok::<(), std::io::Error>));
      let f = iter.fold((conn,buf), |(conn,buf), _| { // use iter and fold to move ownership of buf to closure
         tokio_core::io::read(conn, buf).and_then(|(r,t,size)| {
            if size == 0 {
               println!("closed");
               Err(std::io::Error::new(std::io::ErrorKind::BrokenPipe, "closed"))
            } else {
               println!("recv[{}]: {}", size, std::str::from_utf8(&t[0..size]).unwrap());
               Ok((r,t))
            }
         })
      });
      handle.spawn(f.then(|_| Ok(())));
      Ok(())
   });
   core.run(r).unwrap();
   Ok(())
}
```
read ループが無限イテレータの fold になるのが一寸戸惑う。
これだけならコルーチンの方が分かりやすいが、別の I/O と組み合わせるようになると future の威力が出てきそうだ。

## [mioco](https://crates.io/crates/mioco) 2016-08-22(0.8.1) 3,753
コルーチンスタイルの API.
コルーチンは coio 作者の [context-rs](https://github.com/zonyitoo/context-rs)

```
pub fn main() -> Result<(), String> {
   mioco::start(|| -> Result<(), String> {
      let listener: mioco::tcp::TcpListener = try!(bind());

      loop {
         let mut conn: mioco::tcp::TcpStream = try!(listener.accept().map_err(|e| format!("accept: {}", e)));

         mioco::spawn(move || -> Result<(), String> {
            let mut buf = [0u8; 1024];
            loop {
               match conn.read(&mut buf[0..]) {
                  Ok(0) => {
                     println!("read: closed");
                     return Ok(());
                  }
                  Ok(n) => {
                     println!("recv[{}]: {}", n, std::str::from_utf8(&buf[0..n]).unwrap());
                  }
                  Err(e) => {
                     return Err(format!("read: {}", e));
                  }
               }
            }
         });
      }
   }).unwrap()
}
```
mioco 使うネットワーク処理の全体を mioco::start で括る。
mioco::spawn は Rust のスレッドと同じ書き方だが、グリーンスレッドで実行されるのであろう。
接続毎コルーチンなので見通しが良い。mio のサンプルコードは接続一つだけだけど、こちらは複数対応できている。

一般に接続毎のOSスレッド方式は、

 - Pros: 接続毎にコンテキストをクリアしなくていいので、バッファ処理が楽
 - Cons: 接続数(=スレッド数)増加にともなう性能劣化

という特徴があるが、グリーンスレッドであれば欠点が無く利点だけ享受できるはず。
誰か C10K でスループット試してみて;-)

## [event](https://crates.io/crates/event) 2015-01-05(0.2.1) 1,384
マルチスレッドのイベントループ。

## [aio](https://crates.io/crates/aio) 2015-01-05(0.0.1) 666
ノンブロッキングI/O らしい。
名前は非同期I/Oぽいが?

## [asio](https://crates.io/crates/asio) 2016-05-05(0.1.0) 240
非同期I/O

## [futures-mio](https://crates.io/crates/futures-mio) 2016-08-01(0.1.0) 112
futures と mio 組み合わせたやつで、tokio に発展的に解消したのであろう。同じ作者だし。

## [coio-rs](https://github.com/zonyitoo/coio-rs)
コルーチンスタイル。
コルーチンは同作者の [context-rs](https://github.com/zonyitoo/context-rs)

```
pub fn main() -> Result<(), String> {
   coio::Scheduler::new().with_workers(4).run(|| {
      let listener = coio::net::TcpListener::bind("127.0.0.1:10000").unwrap();

      loop {
         let (mut conn, _addr) = try!(listener.accept().map_err(|e| format!("accept: {}", e)));

         coio::spawn(move || {
            let mut buf = [0u8; 1024];
            loop {
               match conn.read(&mut buf[0..]) {
                  Ok(0) => {
                     println!("read: closed");
                     break;
                  }
                  Ok(n) => {
                     println!("recv[{}]: {}", n, std::str::from_utf8(&buf[0..n]).unwrap());
                  }
                  Err(e) => {
                     println!("read: {}", e);
                     break;
                  }
               }
            }
         });
      }
   }).unwrap()
}
```
インターフェースは mioco とほとんど同じ。
コルーチンライブラリも同じ。

# まとめ
std::net, net2, mio のスタックはデファクトぽい。
mio の上に aio/future/coroutine/fsm スタイルなど色々な crate がある感じかな。

