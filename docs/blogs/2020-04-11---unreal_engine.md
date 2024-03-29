---
title: UE4 C++ (VSCode) セットアップ
date: "2020-04-09T00:00:00.000+09:00"
#template: "post"
draft: false
# slug: "slug"
category: "Tech"
tags:
  - "Tech"
  - "UE4"
description: Unreal Engine 4 の C++ 開発環境のセットアップ
---

# はじめに
一月に肺炎やってから、FF14 だ在宅勤務だと忙しく創作脳にならなかった。
ようやく落ちついてきたので趣味プロを再開したい。

Bitcoin のツールもやらなきゃだが、ちょっと新しいのやりたい気分。
前々から心のやりたい事リストに載っていた 3D を棚卸し。

というわけで Unreal Engine やってみよう。
できればゲーム作れればいいけども、当面の目標は 3D モデル動かすところかな。
VR ヘッドセットや LookingGlass がもったいない。

# C++ Project
ブループリントは昔ちょっとチュートリアルだけやったことがある。
あれはあれで素晴しいが、数式とかループとかはやはりコードで書けた方が効率良さそうな感じ。

コーディングのチュートリアルはこれかな https://docs.unrealengine.com/ja/Programming/QuickStart/index.html
UE4 と割と独立している感じ。
UE4 側でクラス作成を指示すると C++ のスケルトンと VisualStudio のプロジェクトファイルが作られ、
VS 側で普通にエディットしてビルドすると、UE4 側で使えるようになるようだ。
VS Code でも連携できるみたい。

## UnrealBuildTool
より詳細なビルドプロセスの説明のドキュメントがあった:
https://docs.unrealengine.com/ja/Programming/BuildTools/UnrealBuildTool/index.html

UE4 の各モジュールは build.cs ファイルを持ち、ここにビルド方法が書かれている。
また、.sln や .vcproj ファイルを作成する GenerateProjectFiles.bat がある。
これらをまとめて、UnrealBuildTool と呼ぶようだ。

https://docs.unrealengine.com/ja/Programming/UnrealBuildSystem/ProjectFileGenerator/index.html
UE4 外で変更した場合は GenerateProjectFiles.bat を呼ぶ必要があるそうだ。
逆に言えば、GenerateProjectFiles.bat を呼べば UE4 外で変更してもいいってことだな。

下の方の FAQ を見ると、ビルド時には自動的にソースを探してくるからプロジェクトファイルの更新は不要みたい。必要なのは UE4 エディタに反映させるためかな?
もしかして、VC コンパイル環境さえあれば、ソースコードの編集は Emacs でやっても問題ないのかな。
まぁデバッガとか付いてるし VSCode でよいか。

[VS拡張](https://docs.unrealengine.com/ja/Programming/Development/VisualStudioSetup/UnrealVS/index.html) を使えば、メニューやショートカットキーなどから GenerateProjectFiles.bat を呼べるみたい。

## Visual Studio
コンパイラは VS の Build Tools が必要。
VS 入れると付いてくるので VS を入れよう。

UE4.22 移行は VS2017 が対応バージョンらしい。
2019 でも動くんじゃないかなというわけで VS2019 入れる。
「C++ によるデスクトップ開発」「C++ によるゲーム開発」
「C++ によるゲーム開発」の中の UE インストーラとか UE android IDE も入れとく。

個別のコンポーネントから C# コンパイラ...は既にチェックされていた。

## Visual Studio Code
エディタは VSCode で。
インストールして、拡張を。
 - C/C++ 
 - C#
 - VSCode icons
 - Git Lens
 - Git History
 - Bracket Pair Colorizer
 - Settings Sync
 - REST Client
 - Bookmarks
 - Japanese Language Pack
 - Path Autocomplete
 - GitHub Pull Requests
 - Output Colorizer
 - Log File Hightlighter
 - Bash Debug
 - Awesome Emacs Keymap
 - vscode-emacs-tab
   keybinding.json の修正が必要 (Ctrl+Shilf+P -> "key" -> キーボードショートカットを開く(JSON))
   { "key": "tab", "command": "emacs-tab.reindentCurrentLine", "when": "editorTextFocus" }
   VSCode の再起動が必要。
 - EditorConfig
 - GenerateEditorConfig
 
render whitespace -> boundary
insert spaces -> true
tab completion -> on
tab size -> 3

UE4 プロジェクトを開いて編集メニューから使うエディタの指定をする。
一般 -> ソースコード -> ソースコードエディタを Visual Studio Code.
UE 再起動しろと出てくるので再起動する。

## .NET Core SDK
VSCode 開いてると入れろと出てくるので入れる。

## UE C++ チュートリアル

早速チュートリアルでも。
新規プロジェクトのゲーム、テンプレートは Blank.
プロジェクト設定から、C++、デスクトップ、ハイエンド、スターターコンテンツ有り、レイトレ無効。
名前を入れてプロジェクト作成。

// プロジェクトが開いたら、上に書いたようにソースコードエディタを VSCode にしておく。

ファイルメニューから、新規 C++ クラス、親は Actor で、名前は FloatingActor.
するとコンパイルが始まり、完了すると VSCode が開く。

UE4 で「Visual Studio Code Project を更新」しておくと、VSCode 上で include path など設定されるようだ。

チュートリアルに従って .cpp, .h ファイルを編集。

なんか不完全クラスとか言われる。クラス定義が見つからないみたいだ。
最近の UE でヘッダの構成が変わったらしく、

```c++
  #include <Runtime/Engine/Classes/Components/StaticMeshComponent.h>
  #include <Runtime/CoreUObject/Public/UObject/ConstructorHelpers.h>
```

が必要。
まとめて include してくれる include ファイルは無いんかな。

VSCode のデバッグ実行。あとはエラーを無視して続けると UE4 Editor に行くらしいのだが、exe の生成に失敗した。

UE4 の方だとコンパイルはできる。`?_?`
さらにコンテンツブラウザから FloatingActor を見つけてパースペクティブビューへドロップ。
詳細から位置を (-180, 0, 180) へ変更。
プレイすると、上下しつつ回転する...しないな。


## ビルドエラー "ERROR: no target name was specified"
Code からビルドすると、

 1. launch.json
 2. tasks.json
 3. UE_4.24/Engine/Build/BatchFiles/Build.bat
 4. UE_4.24/Engine/Binaries/DotNET/UnrealBuildTool.exe

と実行されるようである。
UnrealBuildTool.exe で、`ERROR: No target name was specified on the command-line.` と出ている。
この時の起動引数は `Test Win64 Development "d:/dai/Documents/Unreal Projects/Test/Test.uproject' -waitmutex` のようだ。

コマンドラインのヘルプが無いので正しくは分からんが、特に問題なさそうな感じ。
上でヘッダが変わったみたくコマンドライン引数が変わった可能性もあるが、それならググれば出てくるよなぁ。

ソースを見る。
https://github.com/EpicGames/UnrealEngine/blob/6c20d9831a968ad3cb156442bebb41a883e62152/Engine/Source/Programs/UnrealBuildTool/Configuration/TargetDescriptor.cs
のようだ。

```C#
	// Otherwise assume they are target names
	TargetNames.AddRange(InlineArguments);
```

ここに来る前に、

```C#
	if(UnrealTargetPlatform.TryParse(InlineArguments[0], out ParsedPlatform)) {
      ...
      continue;
    }
```

と、platform と configuration の定義名として判定を試み、成功したらそこで抜けちゃうみたい。
今は Test という名前のプロジェクト。
configuration に有りそうである。

MyTest という名前で作り直したら通った。
コード本体部分も TEST_API マクロが MYTEST_API になってたりと微妙に違ってるので、.cpp のコピーはしない方がよい。

またコンパイル失敗。
今度は構成を `MyTest(Development)` ではなく `MyTestEditor(Development)` を選んだら成功した。

しかし移動も回転もしない。
よく見たらチュートリアルの最後で Tick() の実装があった。
これを書いて実行したら浮遊回転した。

とりあえずok.

## ソースコード

FloatingActor.h
``` C++
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "FloatingActor.generated.h"

UCLASS()
class MYTEST_API AFloatingActor : public AActor
{
   GENERATED_BODY()

public:
   // Sets default values for this actor's properties
   AFloatingActor();
   UPROPERTY(VisibleAnywhere)
   UStaticMeshComponent* VisualMesh;

protected:
   // Called when the game starts or when spawned
   virtual void BeginPlay() override;

public:
   // Called every frame
   virtual void Tick(float DeltaTime) override;
};
```

FloatingActor.cpp
``` C++
#include "./FloatingActor.h"
#include <Runtime/Engine/Classes/Components/StaticMeshComponent.h>
#include <Runtime/CoreUObject/Public/UObject/ConstructorHelpers.h>


// Sets default values
AFloatingActor::AFloatingActor()
{
   // Set this actor to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
   PrimaryActorTick.bCanEverTick = true;
   VisualMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Mesh"));

   VisualMesh->SetupAttachment(RootComponent);

   static ConstructorHelpers::FObjectFinder<UStaticMesh> CubeVisualAsset(TEXT("/Game/StarterContent/Shapes/Shape_Cube.Shape_Cube"));

   if (CubeVisualAsset.Succeeded())
   {
      VisualMesh->SetStaticMesh(CubeVisualAsset.Object);
      VisualMesh->SetRelativeLocation(FVector(0.0f, 0.0f, 0.0f));
   }
}

// Called when the game starts or when spawned
void AFloatingActor::BeginPlay()
{
   Super::BeginPlay();
}

// Called every frame
void AFloatingActor::Tick(float DeltaTime)
{
   Super::Tick(DeltaTime);

   FVector NewLocation = GetActorLocation();

   FRotator NewRotation = GetActorRotation();
   float RunningTime = GetGameTimeSinceCreation();
   float DeltaHeight = (FMath::Sin(RunningTime + DeltaTime) - FMath::Sin(RunningTime));
   NewLocation.Z += DeltaHeight * 20.0f;       //Scale our height by a factor of 20
   float DeltaRotation = DeltaTime * 20.0f;    //Rotate by 20 degrees per second
   NewRotation.Yaw += DeltaRotation;
   SetActorLocationAndRotation(NewLocation, NewRotation);
}
```
