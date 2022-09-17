---
title: swagger-codegen-typescript-koa2
date: "2018-12-05T00:00:00.000+09:00"
#template: "post"
draft: false
# slug: "slug"
category: "Tech"
tags:
  - "Tech"
description: Swagger から TypeScript Koa2 のサーバースケルトンコードを作成するツールを作ったので紹介。
#socialImage: "/media/42-line-bible.jpg"
---
2018-12-05

# はじめに

 - swagger からサーバーコードを生成したい
 - TypeScript 用
 - ルーティングは生成コードでやってほしい。プログラマはマナーにそって関数を定義するだけにしたい。
 - HTTP の入出力チェックをしてほしい
 - TypeScript なので、きちんと入出力の型を定義してほしい。
   ついでに実装関数はその型を扱う形にしてほしい。

というものが欲しかったのですが、探しても見つからないので作りました。


# 使い方
## インストール

```
$ npm install --save swagger-codegen-typescript-koa2
```

## edit swagger

swagger を書きます。バージョンは 2 です。


```
swagger: '2.0'
info:
  version: '1.0.0'
  title: swagger test
schemes:
  - http
consumes:
  - application/json
produces:
  - application/json
paths:
  /hello/{user_id}:
    get:
      summary: get user
      operationId: get_user
      description: |
        get user
      parameters:
        - in: path
          required: true
          name: user_id
          type: integer
          description: user_id
      responses:
        '200':
          description: OK
          schema:
            type: object
            properties:
              user_id:
                type: integer
              hello:
                type: string
        '400':
          description: Error
          schema:
            $ref: '#/definitions/ErrorResponse'
definitions:
  ErrorResponse:
    type: object
    required:
      - code
      - name
      - message
    properties:
      code:
        type: integer
      name:
        type: string
      message:
        type: string
```

## dtsgenerator
今は definition などの型は生成しないので、dtsgenerator 使います。
2.0 は出力形式が変わったようですが未対応です。1.2 を使います。

-n は空文字、出力ファイル名は swagger.d.ts です。

```console
$ npx dtsgenerator@1.2.0 -n "" -o swagger.d.ts < swagger.yaml
```

## run codegen
次に swagger-codegen-typescript-koa2.  
コマンドは、第一引数に swagger ファイル、第二引数に出力ファイルです。

```console
$ npx swagger-codegen-typescript-koa2 swagger.yaml dist/swagger/codegen.ts

```

codegen.ts が作られたのでちょっと見てみます:

### operationId -> namespace

```TypeScript
export namespace get_user {
```

operationId の名前空間が作られます。

### type Reqeust

```TypeScript
  export type Request = {
    user_id: number;
  }
```

parameters の内容に対応した型 Request が作られます。
API 呼び出しのパラメータは in:body も in:path も validation されてこの型のインスタンスに入れられます。

type:string, format:date とかは string で来ます。
そのうち Date で来るようにしたいです。


### Response

```TypeScript
  export type Response200 = {
user_id?: string
hello?: string
};
  export type Response400 = {
error_code?: number
};
  export type Response = {
    status: number;
    body: Response200 | Response400;
  };
```

responses の応答ステータス毎に ResponseXXX な型が定義されます。

さらに、それらを合成した型を body に持つ Response 型が作られます。

### Handler

```TypeScript
  export interface Handler {
    (req:Request, ctx:KoaRouter.IRouterContext): Promise<Response>;
  };
```

上で見た Request を受けつけ Response を返す関数型が定義されます。
プログラマはこの関数を実装します。

### Router

```TypeScript
export interface Routes {
  get_user?: get_user.Handler;
}
export class Router extends KoaRouter {
  swagger: Routes = {};
}

export function setup(app:Koa, swagger_filepath:string, routes_dirpath:string): Router {
  ...
}
```

セットアップ用の関数と型です。
あとで見ます。

## 実装

まず必要なライブラリのインストール

```console
$ npm install --save koa koa-router koa-cors koa-bodyparser swagger2-koa bignumber
$ npm install --save-dev ts-node @types/koa-cors @types/koa-router
```


サーバーを書きます。

```console
$ cat index.ts
```

### import

```TypeScript:index.ts
import * as Koa from 'koa';
import * as bodyParser from 'koa-bodyparser';
import * as koaCors from 'koa-cors';
import * as koaRouter from 'koa-router';
import * as api from './codegen';
```

さっき生成した codegen.ts を import します。


### Handler

上で見た Handler 関数を実装します。
function 文ではなく、arrow で定義した関数を変数に入れる形にすると入出力の型を補完してくれます。

```TypeScript:index.ts
const get_user:api.get_user.Handler = async (req, ctx) => {
    let res200: api.get_user.Response200 | undefined;
    let res400: api.get_user.Response400 | undefined;

    if (req.user_id === 20070830) {
        res200 = { user_id: req.user_id, hello: 'hello Miku' }
    } else if (req.user_id === 20071227) {
        res200 = { user_id: req.user_id, hello: 'hello Rin' }
    } else {
        res400 = { code: 404, name:'not found', message: 'not found' };
        return { status:400, body:res400! };
    }
    return { status:200, body:res200! };
}
```

### Koa 構築とハンドラ登録


```TypeScript:index.ts
function main() {
    const app = new Koa();
    app.use(koaCors());
    app.use(bodyParser());

    const router = api.setup(app, './swagger.yaml', '');
    router.swagger.get_user = get_user;

    app.listen(3000, () => { console.log('listen on 3000')});
}
```

api.setup は上で見た、自動生成コードのセットアップ関数です。  
第一引数に Koa インスタンス、第二引数に swagger ファイルを指定します。第三引数は使わないので空文字列で。  
swagger ファイルを渡してるのがイマイチですが、これは validation を他のライブラリを用いているためです。そのうち codegen の掃き出すコードに入れたいです。

得られた Router オブジェクトの swagger.get_user 変数に先程作った get_user 関数を代入します。  
要するに swagger.get_user は `GET users/{user_id}` で呼ばれる関数の置き場所です。
型指定してあるので、api.Handler でないなら tsc で弾かれます。

そして最後に listen.


## 起動

```console
$ ts-node index.ts
koa deprecated Support for generators will be removed in v3. See the documentation for examples of how to convert old middleware https://github.com/koajs/koa/blob/master/docs/migration.md index.ts:24:9
listen on 3000
```

```console
$ curl 'http://localhost:3000/hello/20070830'; echo
{"user_id":20070830,"hello":"hello Miku"}
 
$ curl 'http://localhost:3000/hello/20071227'; echo
{"user_id":20071227,"hello":"hello Rin"}
 
$ curl 'http://localhost:3000/hello/20060217'; echo
{"code":404,"name":"not found","message":"not found"}
```

user_id は integer でした。型エラーにすると...

```console
$ curl 'http://localhost:3000/hello/rin'; echo
{"code":"SWAGGER_REQUEST_VALIDATION_FAILED","errors":[{"actual":"rin","expected":{"type":"integer"},"where":"path"}]}
```

とエラーになります。


# まとめ

swagger2 から TypeScript 用のサーバー用のスタブコードを生成するツール作りました。
ad-hoc な作りですが、とりあえず使えると思います。

swagger driven な開発で、TypeScript でサーバー書く機会がありましたら使ってみてください。

## URLs

- npm
  https://www.npmjs.com/package/swagger-codegen-typescript-koa2
- github  
  https://github.com/dai1975/swagger-codegen-typescript-koa2
