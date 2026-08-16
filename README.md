# MouseMovePS

Windows上で、一定間隔ごとに小さなマウス移動イベントを送信する PowerShell スクリプトです。

マウスポインターをランダムな方向へわずかに移動し、短時間後に逆方向へ同じ量だけ移動させることで、カーソル位置をほぼ変えずに Windows へマウス入力イベントを送信します。

マウス入力には Windows API の `SendInput` を使用しています。

## Features

* `SendInput` による相対マウス移動イベントの送信
* 一定間隔での自動実行
* 8方向からランダムに移動方向を選択
* マウス移動量を設定可能
* 1回の発動あたりの繰り返し回数を設定可能
* 移動後、逆方向へ戻すまでの待機時間を設定可能
* `GetLastInputInfo` による Windows アイドル時間の確認
* デバッグ表示の ON / OFF 切り替え
* タスクトレイ常駐
* タスクトレイメニューから停止可能
* `MouseMove.ps1` をもう一度実行することで停止可能
* Mutex による多重起動防止
* `MouseMove.ico` の自動読み込み
* アイコン未配置時は Windows 標準アイコンを使用

---

## Requirements

* Windows
* PowerShell
* Windows Forms が利用できる環境

以下の Windows API を使用しています。

* `SendInput`
* `GetLastInputInfo`

Windows固有のAPIを使用しているため、macOSやLinuxには対応していません。

---

## Installation

リポジトリをダウンロードまたはクローンし、`MouseMove.ps1` を任意のフォルダーに配置します。

最小構成は以下のとおりです。

```text
MouseMovePS/
└── MouseMove.ps1
```

カスタムアイコンを使用する場合は、同じフォルダーに `MouseMove.ico` を配置します。

```text
MouseMovePS/
├── MouseMove.ps1
└── MouseMove.ico
```

---

## Usage

PowerShellから `MouseMove.ps1` を実行します。

```powershell
.\MouseMove.ps1
```

起動するとタスクトレイにアイコンが表示され、マウス移動処理が開始されます。

---

## Stop

MouseMovePS は2通りの方法で停止できます。

### タスクトレイから停止

タスクトレイのアイコンを右クリックし、

```text
停止
```

を選択します。

### `MouseMove.ps1` をもう一度実行

すでに MouseMovePS が動作している状態で、

```powershell
.\MouseMove.ps1
```

をもう一度実行すると、新しいインスタンスを開始する代わりに、動作中のインスタンスへ停止要求を送信します。

```text
1回目の実行 → ON
2回目の実行 → OFF
```

---

## Configuration

設定項目は `MouseMove.ps1` の先頭にまとめています。

デフォルト設定は以下のとおりです。

```powershell
# マウス移動を発動1回当たり何回繰り返すか
$MoveRepeatCount = 1

# 1回の移動後、元に戻すまでの待機時間（ミリ秒）
$MoveReturnDelayMs = 8

# 次の発動までの待機時間（秒）
$MainIntervalSeconds = 60

# 1回あたりの移動量（ピクセル）
$MovePixels = 1

# デバッグ表示
$DebugEnabled = $false
```

### `$MoveRepeatCount`

1回の発動につき、マウスの往復移動を何回行うか指定します。

```powershell
$MoveRepeatCount = 1
```

デフォルトは `1` 回です。

### `$MoveReturnDelayMs`

マウスを移動してから、逆方向へ同じ量だけ移動するまでの待機時間です。

```powershell
$MoveReturnDelayMs = 8
```

単位はミリ秒です。デフォルトは `8 ms` です。

参考として、120 Hz表示の1フレームは約 `8.33 ms` です。

> Windows はリアルタイムOSではないため、実際の処理タイミングが厳密に指定値と一致することを保証するものではありません。

### `$MainIntervalSeconds`

1回の発動処理が終了してから、次の発動まで待機する時間です。

```powershell
$MainIntervalSeconds = 60
```

単位は秒です。デフォルトは `60秒` です。

### `$MovePixels`

1回のマウス入力で移動させる量です。

```powershell
$MovePixels = 1
```

デフォルトは `1 px` です。

### `$DebugEnabled`

Windows が認識しているアイドル時間をコンソールに表示するか指定します。

無効：

```powershell
$DebugEnabled = $false
```

有効：

```powershell
$DebugEnabled = $true
```

デフォルトは無効です。

有効にすると、マウス入力の前後で次のような情報が表示されます。

```text
Idle: 60.123 sec
Idle: 0.008 sec
```

---

## Mouse movement

発動するたびに、X方向とY方向の移動方向をランダムに決定します。

```text
↖  ↑  ↗
←     →
↙  ↓  ↘
```

X方向・Y方向それぞれについて `-1`、`0`、`1` のいずれかをランダムに選択し、`$MovePixels` を掛けて実際の移動量を決定します。

ただし、

```text
X = 0
Y = 0
```

となる組み合わせは除外されるため、毎回いずれかの方向へマウス移動イベントが送信されます。

例えば、

```text
DX = 1
DY = 0
```

が選択された場合は、

```text
右へ1px
   ↓
指定時間待機
   ↓
左へ1px
```

という動作になります。

MouseMovePS は元の絶対座標を記録して強制的に戻すのではなく、最初の移動と逆方向へ同じ量の相対移動イベントを送信することで、スクリプト自身が加えた移動量を打ち消します。

---

## Why SendInput?

`System.Windows.Forms.Cursor.Position` を変更する方法でも、画面上のマウスポインターを移動させることはできます。

しかし、カーソル座標の変更と Windows のマウス入力イベントは同じものではありません。

MouseMovePS では Windows API の `SendInput` を使用し、相対マウス移動イベントを Windows へ送信しています。

---

## Idle time debug

MouseMovePS には、Windows が認識しているアイドル時間を確認するためのデバッグ機能があります。

Windows API の `GetLastInputInfo` を使用して、最後に入力が行われてからの経過時間を取得します。

`$DebugEnabled` を有効にすると、

```powershell
$DebugEnabled = $true
```

コンソールに次のように表示されます。

```text
Idle: 60.125 sec
Idle: 0.008 sec
```

これにより、`SendInput` 実行前後のアイドル時間を確認できます。

---

## Tray icon

MouseMovePS の起動中は、Windows のタスクトレイにアイコンが表示されます。

### Custom icon

`MouseMove.ps1` と同じフォルダーに、

```text
MouseMove.ico
```

を配置すると、自動的にそのアイコンを使用します。

```text
MouseMovePS/
├── MouseMove.ps1
└── MouseMove.ico
```

内部ではスクリプトのファイル名から `.ico` のファイル名を自動的に決定しています。

そのため、スクリプト名を変更した場合は `.ico` 側も同じベース名にしてください。

例：

```text
Test.ps1
Test.ico
```

対応する `.ico` ファイルが見つからない場合は、Windows 標準の Information アイコンを使用します。

---

## Multiple launch protection

MouseMovePS は名前付き `Mutex` を使用して多重起動を防止しています。

```powershell
$mutexName = "Local\MouseMoveToggle_Mutex"
```

すでに MouseMovePS が動作している場合、新しいインスタンスは通常のマウス移動処理を開始しません。

代わりに、名前付き `EventWaitHandle` を使用して既存のインスタンスへ停止要求を送信します。

```powershell
$stopEventName = "Local\MouseMoveToggle_StopEvent"
```

これにより、`MouseMove.ps1` を再実行することで ON / OFF を切り替えるような操作ができます。

---

## Stop responsiveness

待機処理には `EventWaitHandle.WaitOne()` を使用しています。

単純な長時間の `Start-Sleep` と異なり、待機中にも停止イベントを確認できます。

次回発動までの待機中は定期的に停止要求を確認します。

また、Windows Forms のイベントを処理するため、

```powershell
[System.Windows.Forms.Application]::DoEvents()
```

を実行しています。

これにより、メインループ動作中でもタスクトレイの右クリックメニューなどを操作できます。

---

## Notes

MouseMovePS は Windows にマウス移動イベントを送信する PowerShell スクリプトです。

特定のアプリケーションやサービスにおける在席状態・離席状態、画面ロック、スクリーンセーバー、スリープなどの挙動を保証するものではありません。

アプリケーションによっては独自の方法でユーザーの状態を判定している場合があります。

また、ミリ秒単位の待機時間は Windows のスケジューリングやシステム負荷によって前後する場合があります。

利用する環境の規則やセキュリティポリシーを確認したうえで使用してください。

---

## License

