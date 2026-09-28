# ============================================================
# 設定
# ============================================================

# マウス移動を発動1回当たり何回繰り返すか
#
# 1往復だけでもSendInputによるマウス入力イベントは発生するため、
# 不要な入力イベントを増やさないようデフォルトは1回とする
# Default: 1回
$MoveRepeatCount = 1

# 1回の移動後、元に戻すまでの待機時間（ミリ秒）
#
# 120Hz表示の1フレームは約8.33msなので、それより短い8msを使用する
# これにより、1ピクセル移動している状態をできるだけ短時間にし、
# カーソルの移動を視覚的に気付きにくくする
# Default: 8ms
$MoveReturnDelayMs = 8

# 次の発動までの待機時間（秒）
#
# 1分間隔を基準としてマウス入力を発生させる
# この時間は「前回の発動終了」から「次回の発動」までの待機時間
# Default: 60秒
$MainIntervalSeconds = 60

# 1回あたりの移動量（ピクセル）
#
# SendInputによる移動イベントを発生させつつ、
# カーソル位置の見た目への影響を最小限にするため1pxとする
# Default: 1px
$MovePixels = 1

# 停止要求およびスケジュール状態を確認する間隔（ミリ秒）
#
# 100ms = 0.1秒で、1秒間に約10回状態を確認する
# 停止操作やスケジュール切り替えに体感上ほぼ即時に反応しつつ、
# 数ms単位で監視する場合に比べて不要なCPUウェイクアップを抑えるため
# Default: 100ms
$ControlCheckIntervalMs = 100

# スケジュールで入力できる最大時間
#
# 約416日分に相当し、TimeSpan自体の技術的上限ではなく、
# GUIでの極端な誤入力を防ぐための上限
# 9999時間は4桁で入力できる実用上の上限として設定する
$ScheduleMaxHours = 9999

# スケジュールの「分」入力欄の最大値
#
# 60分以上は「1時間0分」のように時間側へ繰り上げて入力する
# 1時間未満の「分」の部分だけを入力するため0～59とする
$ScheduleMaxMinutes = 59

# ON通知でWindowsへ要求する表示時間（ミリ秒）
#
# 2000ms = 2秒
# 起動したことを確認できる程度の時間を確保しつつ、
# 長時間画面を占有しない値として設定する
# ※実際の表示時間はWindows側の通知設定等により異なる場合がある
# Default: 2000ms = 2秒
$OnNotificationDurationMs = 2000

# OFF通知でWindowsへ要求する表示時間（ミリ秒）
#
# 終了確認だけの短い通知なのでON通知より短くしている
# Default: 1500ms = 1.5秒
$OffNotificationDurationMs = 1500

# OFF通知を要求した後、NotifyIconを破棄するまで待つ時間
#
# ShowBalloonTip直後にNotifyIconを破棄すると、
# Windowsへ通知が渡る前に終了する可能性があるため、
# 通知処理を引き渡すための猶予時間として設定する
# この700msはWindowsが保証する時間ではなく、MouseMovePS側で設ける待機時間
# Default: 700ms
$NotificationDispatchWaitMs = 700

# OFF通知待機中にWindows Formsイベントを処理する間隔
#
# 700msの待機中にもUIイベントを処理しつつ、
# 過剰なループにならない間隔として設定する
# Default: 50ms = 1秒間に約20回
$NotificationPumpIntervalMs = 50

# 多重起動防止用のMutex名
# 同じ名前のMutexがすでに存在する場合は、このスクリプトがすでに起動していると判定する
$mutexName = "Local\MouseMoveToggle_Mutex"

# 実行中のスクリプトへ停止要求を送るためのイベント名
# 2回目の起動時にこのイベントをセットすることで、先に起動しているスクリプトを終了させる
$stopEventName = "Local\MouseMoveToggle_StopEvent"

# タスクトレイアイコンについて
# スクリプトと同名の.icoファイルが同じフォルダーにある場合はそれを使用する
# .icoファイルがない場合はWindows標準の情報アイコンを使用する

# デバッグ表示（発動前後のアイドルタイム表示）
# $true  : アイドルタイムをコンソールに表示
# $false : デバッグ表示を無効化
$DebugEnabled = $false

# ------------------------------------------------------------
# Default値
# ------------------------------------------------------------

# 1往復だけでもSendInputによるマウス入力イベントは発生するため1回
$DefaultMoveRepeatCount = 1

# 120Hz表示の1フレームは約8.33ms。
# それより短い待機要求値として8msを使用する
$DefaultMoveReturnDelayMs = 8

# マウス入力は1分間隔を基準とする
$DefaultMainIntervalSeconds = 60

# カーソル位置への視覚的影響を最小化するため1px
$DefaultMovePixels = 1

# 100ms = 0.1秒。
# 操作への応答性とCPU負荷のバランスから100msとする
$DefaultControlCheckIntervalMs = 100

# GUIで扱いやすい4桁の時間数を上限とする
# 約416日分
$DefaultScheduleMaxHours = 9999

# 「分」は1時間未満の部分なので0～59
$DefaultScheduleMaxMinutes = 59

# ON通知は確認しやすく長すぎない2秒
$DefaultOnNotificationDurationMs = 2000

# OFF通知は終了確認のみなので1.5秒
$DefaultOffNotificationDurationMs = 1500

# NotifyIconを破棄する前にWindowsへ通知を渡すための猶予時間
$DefaultNotificationDispatchWaitMs = 700

# OFF通知待機中のUIイベント処理を約20回/秒にする
$DefaultNotificationPumpIntervalMs = 50

# 多重起動防止に使用する名前
$DefaultMutexName = "Local\MouseMoveToggle_Mutex"

# 実行中インスタンスへの停止要求に使用する名前
$DefaultStopEventName = "Local\MouseMoveToggle_StopEvent"

# 通常時はデバッグ表示を行わない
$DefaultDebugEnabled = $false

# ============================================================
# 設定値検証
# ============================================================

# Default値へ戻した設定を記録する。
# 後で警告ダイアログへまとめて表示する。
$script:SettingWarnings = @()


function Resolve-IntegerSetting {

    param (
        [string]$Name,
        [object]$Value,
        [int]$DefaultValue,
        [int]$Minimum,
        [int]$Maximum
    )

    $parsedValue = 0

    # nullの場合もTryParseへ渡せるよう空文字として扱う
    if ($null -eq $Value) {
        $valueText = ""
    }
    else {
        $valueText = [string]$Value
    }


    # --------------------------------------------------------
    # 整数として解釈できるか確認
    # --------------------------------------------------------

    $isInteger =
        [int]::TryParse(
            $valueText,
            [ref]$parsedValue
        )


    # --------------------------------------------------------
    # 不正値の場合
    # --------------------------------------------------------

    if (
        (-not $isInteger) -or
        ($parsedValue -lt $Minimum) -or
        ($parsedValue -gt $Maximum)
    ) {

        $script:SettingWarnings +=
            "$Name の値 '$valueText' は不正です。" +
            " Default値 $DefaultValue を使用します。"

        return $DefaultValue
    }


    return $parsedValue
}


function Resolve-BooleanSetting {

    param (
        [string]$Name,
        [object]$Value,
        [bool]$DefaultValue
    )

    # PowerShellのBoolean値ならそのまま使用
    if ($Value -is [bool]) {
        return $Value
    }

    $parsedValue = $false

    if (
        [bool]::TryParse(
            [string]$Value,
            [ref]$parsedValue
        )
    ) {
        return $parsedValue
    }


    $script:SettingWarnings +=
        "$Name の値 '$Value' は不正です。" +
        " Default値 $DefaultValue を使用します。"

    return $DefaultValue
}


function Resolve-StringSetting {

    param (
        [string]$Name,
        [object]$Value,
        [string]$DefaultValue
    )

    if (
        $null -eq $Value -or
        [string]::IsNullOrWhiteSpace([string]$Value)
    ) {

        $script:SettingWarnings +=
            "$Name が空です。" +
            " Default値 '$DefaultValue' を使用します。"

        return $DefaultValue
    }

    return [string]$Value
}

function Resolve-WaitHandleNameSetting {

    param (
        [string]$Name,
        [string]$Value,
        [string]$DefaultValue
    )

    $isValid = $true
    $reason = ""

    # --------------------------------------------------------
    # 名前の長さ
    # --------------------------------------------------------
    #
    # Windowsの名前付き同期オブジェクト名は
    # MAX_PATH（260文字）を上限とする。

    if ($Value.Length -gt 260) {

        $isValid = $false
        $reason = "260文字を超えています。"
    }


    # --------------------------------------------------------
    # 名前空間とバックスラッシュ
    # --------------------------------------------------------
    #
    # '\' は名前空間指定用の予約文字。
    #
    # 使用できる形式:
    #
    #   Local\名前
    #   Global\名前
    #   名前
    #
    # Local\ または Global\ を使用した場合でも、
    # その後の名前部分に '\' を含めることはできない。

    elseif ($Value.Contains("\")) {

        if ($Value.StartsWith("Local\")) {

            $objectName = $Value.Substring(6)

            if (
                [string]::IsNullOrEmpty($objectName) -or
                $objectName.Contains("\")
            ) {
                $isValid = $false
                $reason = "Local\ の後の名前が不正です。"
            }
        }
        elseif ($Value.StartsWith("Global\")) {

            $objectName = $Value.Substring(7)

            if (
                [string]::IsNullOrEmpty($objectName) -or
                $objectName.Contains("\")
            ) {
                $isValid = $false
                $reason = "Global\ の後の名前が不正です。"
            }
        }
        else {

            $isValid = $false
            $reason =
                "バックスラッシュは Local\ または Global\ の名前空間指定にのみ使用できます。"
        }
    }


    # --------------------------------------------------------
    # 不正な場合
    # --------------------------------------------------------

    if (-not $isValid) {

        $script:SettingWarnings +=
            "$Name の値 '$Value' はWindowsの名前付き同期オブジェクト名として不正です。" +
            " $reason" +
            " Default値 '$DefaultValue' を使用します。"

        return $DefaultValue
    }


    return $Value
}

# ============================================================
# 各設定値を検証
# ============================================================

# 1回以上でなければマウス入力処理自体が実行されないため、
# 最小値は1とする。
$MoveRepeatCount =
    Resolve-IntegerSetting `
        -Name "MoveRepeatCount" `
        -Value $MoveRepeatCount `
        -DefaultValue $DefaultMoveRepeatCount `
        -Minimum 1 `
        -Maximum ([int]::MaxValue)

# 0msは「移動後すぐ戻す」という有効な指定なので許可する。
$MoveReturnDelayMs =
    Resolve-IntegerSetting `
        -Name "MoveReturnDelayMs" `
        -Value $MoveReturnDelayMs `
        -DefaultValue $DefaultMoveReturnDelayMs `
        -Minimum 0 `
        -Maximum ([int]::MaxValue)

# 0秒以下では待機せず連続して入力イベントを発生させるため、
# 最小値は1秒とする。
$MainIntervalSeconds =
    Resolve-IntegerSetting `
        -Name "MainIntervalSeconds" `
        -Value $MainIntervalSeconds `
        -DefaultValue $DefaultMainIntervalSeconds `
        -Minimum 1 `
        -Maximum ([int]::MaxValue)

# 0pxにするとDX/DYが必ず0となり、
# 移動方向決定のdo/whileから永久に抜けられなくなるため、
# 最小値は1pxとする。
$MovePixels =
    Resolve-IntegerSetting `
        -Name "MovePixels" `
        -Value $MovePixels `
        -DefaultValue $DefaultMovePixels `
        -Minimum 1 `
        -Maximum ([int]::MaxValue)

# Windows Forms TimerのIntervalは1ms以上である必要がある。
$ControlCheckIntervalMs =
    Resolve-IntegerSetting `
        -Name "ControlCheckIntervalMs" `
        -Value $ControlCheckIntervalMs `
        -DefaultValue $DefaultControlCheckIntervalMs `
        -Minimum 1 `
        -Maximum ([int]::MaxValue)


# スケジュールの「時間」上限は1以上とする。
# 99999よりも大きい値を異常値とし、Defaultの最大値へ強制的に戻す。
$ScheduleMaxHours =
    Resolve-IntegerSetting `
        -Name "ScheduleMaxHours" `
        -Value $ScheduleMaxHours `
        -DefaultValue $DefaultScheduleMaxHours `
        -Minimum 1 `
        -Maximum 99999

# 「分」は0～59という意味を持つため、それ以外はDefaultへ戻す。
$ScheduleMaxMinutes =
    Resolve-IntegerSetting `
        -Name "ScheduleMaxMinutes" `
        -Value $ScheduleMaxMinutes `
        -DefaultValue $DefaultScheduleMaxMinutes `
        -Minimum 0 `
        -Maximum 59

# ShowBalloonTipへ渡す表示時間。
# 0以下は意図しない通知動作を避けるためDefaultへ戻す。
$OnNotificationDurationMs =
    Resolve-IntegerSetting `
        -Name "OnNotificationDurationMs" `
        -Value $OnNotificationDurationMs `
        -DefaultValue $DefaultOnNotificationDurationMs `
        -Minimum 1 `
        -Maximum ([int]::MaxValue)

$OffNotificationDurationMs =
    Resolve-IntegerSetting `
        -Name "OffNotificationDurationMs" `
        -Value $OffNotificationDurationMs `
        -DefaultValue $DefaultOffNotificationDurationMs `
        -Minimum 1 `
        -Maximum ([int]::MaxValue)

# 0msは「通知引き渡し待機を行わない」という意味として有効なので許可する。
$NotificationDispatchWaitMs =
    Resolve-IntegerSetting `
        -Name "NotificationDispatchWaitMs" `
        -Value $NotificationDispatchWaitMs `
        -DefaultValue $DefaultNotificationDispatchWaitMs `
        -Minimum 0 `
        -Maximum ([int]::MaxValue)

# Start-Sleepの待機間隔。
# 0msだと高頻度ループになるため1ms以上とする。
$NotificationPumpIntervalMs =
    Resolve-IntegerSetting `
        -Name "NotificationPumpIntervalMs" `
        -Value $NotificationPumpIntervalMs `
        -DefaultValue $DefaultNotificationPumpIntervalMs `
        -Minimum 1 `
        -Maximum ([int]::MaxValue)

#   ------------------------------------------------------------
#   通知待機設定の相互検証
#   ------------------------------------------------------------
#
# NotificationDispatchWaitMs:
#   NotifyIconを破棄するまで全体として待つ時間
#
# NotificationPumpIntervalMs:
#   その待機中に1回Start-Sleepする時間
#
# PumpIntervalの方がDispatchWaitより大きい場合、
# 例えば
#
#   DispatchWait = 700ms
#   PumpInterval = 1000000ms
#
# とすると、本来約700msで終了する処理が
# 1回のStart-Sleepによって大幅に長引く。
#
# 2つの設定値に矛盾がある場合は、
# 一方だけをDefaultへ戻しても組み合わせが
# 正常になるとは限らないため、
# 両方を組み合わせとしてDefaultへ戻す。

if (
    $NotificationDispatchWaitMs -gt 0 -and
    $NotificationPumpIntervalMs -gt $NotificationDispatchWaitMs
) {

    $script:SettingWarnings +=
        "NotificationPumpIntervalMs ($NotificationPumpIntervalMs ms) が " +
        "NotificationDispatchWaitMs ($NotificationDispatchWaitMs ms) より長いため、" +
        "両方をDefault値へ戻します。" +
        " NotificationDispatchWaitMs = $DefaultNotificationDispatchWaitMs ms、" +
        "NotificationPumpIntervalMs = $DefaultNotificationPumpIntervalMs ms"

    $NotificationDispatchWaitMs =
        $DefaultNotificationDispatchWaitMs

    $NotificationPumpIntervalMs =
        $DefaultNotificationPumpIntervalMs
}

$DebugEnabled =
    Resolve-BooleanSetting `
        -Name "DebugEnabled" `
        -Value $DebugEnabled `
        -DefaultValue $DefaultDebugEnabled


$mutexName =
    Resolve-StringSetting `
        -Name "mutexName" `
        -Value $mutexName `
        -DefaultValue $DefaultMutexName

$stopEventName =
    Resolve-StringSetting `
        -Name "stopEventName" `
        -Value $stopEventName `
        -DefaultValue $DefaultStopEventName

# ------------------------------------------------------------
# 名前付き同期オブジェクト名の検証
# ------------------------------------------------------------
#
# mutexName / stopEventName がWindowsで使用できる
# 名前付き同期オブジェクト名の形式になっているか確認する。
#
# 不正な場合は、それぞれのDefault値へ戻す。

$mutexName =
    Resolve-WaitHandleNameSetting `
        -Name "mutexName" `
        -Value $mutexName `
        -DefaultValue $DefaultMutexName

$stopEventName =
    Resolve-WaitHandleNameSetting `
        -Name "stopEventName" `
        -Value $stopEventName `
        -DefaultValue $DefaultStopEventName

# Mutex名とStopEvent名は別々の名前付きオブジェクトとして使用する。
# 同一名の場合は競合する可能性があるため、両方をDefaultへ戻す。
# 大文字小文字を区別する比較を行うため、-ceqを使用する。
if ($mutexName -ceq $stopEventName) {

    $script:SettingWarnings +=
        "mutexName と stopEventName に同じ名前 '$mutexName' が設定されています。" +
        " Default値を使用します。"

    $mutexName = $DefaultMutexName
    $stopEventName = $DefaultStopEventName
}

# ============================================================
# スケジュール状態
# ============================================================

# スケジュール実行中か
$script:ScheduleEnabled = $false

# スケジュールによる一時停止中か
$script:SchedulePaused = $false

# スケジュールが最後まで完了したか
$script:ScheduleCompleted = $false

# スケジュール一覧
#
# 各ステップ:
# Delay  = 前のイベントからの待機時間
# Action = Pause / Resume / Stop
$script:ScheduleSteps = @()

# 現在待機しているステップ番号
$script:ScheduleIndex = 0

# 次のイベント実行予定時刻
$script:ScheduleNextAt = $null

# 現在開いているスケジュール設定画面
#
# モードレス表示した設定画面への参照を保持する。
# $nullの場合は設定画面が開いていないことを表す。
#
# 同じ設定画面が複数開かれることを防ぎ、
# すでに開いている場合は既存の画面を前面へ表示するために使用する。
$script:ScheduleForm = $null

# ============================================================
# 使用する.NETアセンブリ
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================================================
# アイドルタイム検出用API呼び出し
# ============================================================
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class IdleTime
{
    [StructLayout(LayoutKind.Sequential)]
    struct LASTINPUTINFO
    {
        public uint cbSize;
        public uint dwTime;
    }

    [DllImport("user32.dll")]
    static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

    public static double GetIdleSeconds()
    {
        LASTINPUTINFO lii = new LASTINPUTINFO();
        lii.cbSize = (uint)Marshal.SizeOf(lii);

        if (!GetLastInputInfo(ref lii))
            throw new Exception("GetLastInputInfo failed.");

        uint tickCount = unchecked((uint)Environment.TickCount);
        uint idleMilliseconds = tickCount - lii.dwTime;

        return idleMilliseconds / 1000.0;
    }
}
"@

# ============================================================
# マウス入力送信用 SendInput API
# ============================================================

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.ComponentModel;

public static class MouseInput
{
    [StructLayout(LayoutKind.Sequential)]
    struct INPUT
    {
        public uint type;
        public MOUSEINPUT mi;
    }

    [StructLayout(LayoutKind.Sequential)]
    struct MOUSEINPUT
    {
        public int dx;
        public int dy;
        public uint mouseData;
        public uint dwFlags;
        public uint time;
        public IntPtr dwExtraInfo;
    }

    const uint INPUT_MOUSE = 0;
    const uint MOUSEEVENTF_MOVE = 0x0001;

    [DllImport("user32.dll", SetLastError = true)]
    static extern uint SendInput(
        uint nInputs,
        INPUT[] pInputs,
        int cbSize
    );

    public static void Move(int dx, int dy)
    {
        INPUT input = new INPUT();

        input.type = INPUT_MOUSE;
        input.mi.dx = dx;
        input.mi.dy = dy;
        input.mi.mouseData = 0;
        input.mi.dwFlags = MOUSEEVENTF_MOVE;
        input.mi.time = 0;
        input.mi.dwExtraInfo = IntPtr.Zero;

        INPUT[] inputs = new INPUT[] { input };

        uint result = SendInput(
            1,
            inputs,
            Marshal.SizeOf(typeof(INPUT))
        );

        if (result == 0)
        {
            throw new Win32Exception(
                Marshal.GetLastWin32Error()
            );
        }
    }
}
"@

function Format-ScheduleDuration {

    param (
        [TimeSpan]$Duration
    )

    $hours = [math]::Floor($Duration.TotalHours)

    return "{0}:{1:00}:{2:00}" -f `
        $hours,
        $Duration.Minutes,
        $Duration.Seconds
}

function Get-ScheduleActionText {

    param (
        [string]$Action
    )

    switch ($Action) {

        "Pause"  { return "一時停止" }
        "Resume" { return "再開" }
        "Stop"   { return "終了" }

        default  { return $Action }
    }
}

function Test-MouseMoveSchedule {

    param (
        [object[]]$Steps
    )

    if (
        $null -eq $Steps -or
        $Steps.Count -eq 0
    ) {

        return [PSCustomObject]@{
            Valid   = $false
            Message = "スケジュールを1件以上設定してください。"
        }
    }

    # MouseMovePSは最初は動作中
    $state = "Running"

    for ($i = 0; $i -lt $Steps.Count; $i++) {

        $step = $Steps[$i]

        if ($step.Delay.TotalMilliseconds -lt 0) {

            return [PSCustomObject]@{
                Valid   = $false
                Message = "待機時間に負の値は設定できません。"
            }
        }

        switch ($step.Action) {

            "Pause" {

                if ($state -ne "Running") {

                    return [PSCustomObject]@{
                        Valid   = $false
                        Message = "ステップ $($i + 1): すでに一時停止中です。"
                    }
                }

                $state = "Paused"
            }


            "Resume" {

                if ($state -ne "Paused") {

                    return [PSCustomObject]@{
                        Valid   = $false
                        Message = "ステップ $($i + 1): 一時停止していない状態では再開できません。"
                    }
                }

                $state = "Running"
            }


            "Stop" {

                if ($i -ne ($Steps.Count - 1)) {

                    return [PSCustomObject]@{
                        Valid   = $false
                        Message = "終了は最後のステップにのみ設定できます。"
                    }
                }

                $state = "Stopped"
            }


            default {

                return [PSCustomObject]@{
                    Valid   = $false
                    Message = "不明なスケジュール動作です。"
                }
            }
        }
    }

    # 最後がPauseだと永久停止状態になってしまうため禁止
    if ($state -eq "Paused") {

        return [PSCustomObject]@{
            Valid   = $false
            Message = "最後が一時停止になっています。再開または終了を追加してください。"
        }
    }

    return [PSCustomObject]@{
        Valid   = $true
        Message = ""
    }
}

function Start-MouseMoveSchedule {

    param (
        [object[]]$Steps
    )

    $result = Test-MouseMoveSchedule -Steps $Steps

    if (-not $result.Valid) {

        throw $result.Message
    }

    # 元のUIオブジェクトへの参照を持たないようコピー
    $script:ScheduleSteps = @(
        foreach ($step in $Steps) {

            [PSCustomObject]@{
                Delay  = $step.Delay
                Action = $step.Action
            }
        }
    )

    $script:ScheduleIndex = 0
    $script:ScheduleEnabled = $true
    $script:SchedulePaused = $false
    $script:ScheduleCompleted = $false

    # 最初のイベントは現在時刻を基準に計算
    $script:ScheduleNextAt =
        [DateTime]::Now +
        $script:ScheduleSteps[0].Delay
}

function Clear-MouseMoveSchedule {

    $script:ScheduleEnabled = $false
    $script:SchedulePaused = $false
    $script:ScheduleCompleted = $false

    $script:ScheduleSteps = @()
    $script:ScheduleIndex = 0
    $script:ScheduleNextAt = $null

    if ($null -ne $scheduleStatusItem) {
        $scheduleStatusItem.Text = "スケジュール：設定なし"
    }
}

function Update-MouseMoveSchedule {

    if (-not $script:ScheduleEnabled) {
        return
    }

    $now = [DateTime]::Now

    # PCスリープなどで複数イベントの時刻を
    # 一気に過ぎていた場合にも対応
    while (
        $script:ScheduleEnabled -and
        $now -ge $script:ScheduleNextAt
    ) {

        $scheduledAt = $script:ScheduleNextAt

        $step =
            $script:ScheduleSteps[
                $script:ScheduleIndex
            ]

        switch ($step.Action) {

            "Pause" {

                $script:SchedulePaused = $true
            }


            "Resume" {

                $script:SchedulePaused = $false
            }


            "Stop" {

                $script:ScheduleEnabled = $false
                $script:SchedulePaused = $false

                # MouseMovePS自体を終了
                $stopEvent.Set() | Out-Null

                return
            }
        }


        # 次のステップ
        $script:ScheduleIndex++


        # 全ステップ完了
        if (
            $script:ScheduleIndex -ge
            $script:ScheduleSteps.Count
        ) {

            $script:ScheduleEnabled = $false
            $script:ScheduleCompleted = $true
            $script:ScheduleNextAt = $null

            return
        }


        # 次の予定時刻は
        # 「実際に処理した時刻」ではなく
        # 「本来の予定時刻」から計算する
        #
        # これにより処理遅延によるズレを蓄積させない
        $script:ScheduleNextAt =
            $scheduledAt +
            $script:ScheduleSteps[
                $script:ScheduleIndex
            ].Delay

        $now = [DateTime]::Now
    }
}

function Update-ScheduleStatusText {

    if ($null -eq $scheduleStatusItem) {
        return
    }

    if ($script:ScheduleEnabled) {

        $remaining =
            $script:ScheduleNextAt -
            [DateTime]::Now

        if ($remaining.TotalMilliseconds -lt 0) {
            $remaining = [TimeSpan]::Zero
        }

        $nextStep =
            $script:ScheduleSteps[
                $script:ScheduleIndex
            ]

        $nextAction =
            Get-ScheduleActionText `
                -Action $nextStep.Action

        if ($script:SchedulePaused) {
            $state = "一時停止中"
        }
        else {
            $state = "動作中"
        }

        $remainingText =
            Format-ScheduleDuration `
                -Duration $remaining

        $scheduleStatusItem.Text =
            "スケジュール：$state / 次：$nextAction まで $remainingText"

    }
    elseif ($script:ScheduleCompleted) {

        $scheduleStatusItem.Text =
            "スケジュール：完了（動作継続）"

    }
    else {

        $scheduleStatusItem.Text =
            "スケジュール：設定なし"
    }
}

# ========================================================
# 一覧番号更新
# ========================================================
function Update-ScheduleListNumbers {

    param (
        [object]$ListView
    )

    for (
        $i = 0;
        $i -lt $ListView.Items.Count;
        $i++
    ) {

        $ListView.Items[$i].Text =
            [string]($i + 1)
    }
}

function Show-ScheduleDialog {

    # ========================================================
    # すでに設定画面が開いている場合
    # ========================================================
    #
    # モードレス表示では関数終了後もフォームが残るため、
    # 同じ設定画面を複数作成しないようにする。
    #
    # 既存フォームが最小化されている場合は通常表示へ戻し、
    # 前面へ移動して終了する。

    if (
        $null -ne $script:ScheduleForm -and
        -not $script:ScheduleForm.IsDisposed
    ) {

        if (
            $script:ScheduleForm.WindowState -eq
            [System.Windows.Forms.FormWindowState]::Minimized
        ) {
            $script:ScheduleForm.WindowState =
                [System.Windows.Forms.FormWindowState]::Normal
        }

        $script:ScheduleForm.Activate()

        return
    }

    # ========================================================
    # GUIレイアウトについて
    # ========================================================
    #
    # このダイアログはFixedDialogとして使用するため、
    # 各コントロールは固定ピクセル位置で配置する。
    #
    # フォームサイズは650×520px。
    # 幅600pxの主一覧を左端15pxから配置し、左右に余白を確保する。
    #
    # 上部説明欄は高さ40px、その下に約10pxの余白を取って
    # スケジュール一覧をY=65pxから高さ240pxで配置する。
    # 一覧下端は305pxとなるため、入力欄はY=330pxに置き、
    # 約25pxの間隔を確保する。
    #
    # 下部ボタンはY=410pxに配置し、
    # 入力欄との間隔とフォーム下端の余白を確保する。
    #
    # ラベルのY座標を入力欄より数px下げている箇所は、
    # NumericUpDown等と文字の見た目上のベースラインを合わせるため。
    #
    # これらの座標・サイズはアルゴリズム上の意味を持つ値ではなく、
    # 固定サイズのダイアログ内で各要素を重ならず見やすく配置するための
    # UIレイアウト値として設定している。

    $form = New-Object System.Windows.Forms.Form

    # モードレス表示後もフォームを参照できるよう、
    # scriptスコープへ保存する。
    $script:ScheduleForm = $form

    $form.Text = "MouseMovePS - スケジュール"
    $form.Width = 650
    $form.Height = 520

    $form.StartPosition =
        [System.Windows.Forms.FormStartPosition]::CenterScreen

    $form.FormBorderStyle =
        [System.Windows.Forms.FormBorderStyle]::FixedDialog

    $form.MaximizeBox = $false


    # ========================================================
    # 説明
    # ========================================================

    $description =
        New-Object System.Windows.Forms.Label

    $description.Text =
        "各ステップは、前のイベントから指定時間後に実行されます。" +
        "`r`n最初のステップは現在時刻を基準にします。"

    $description.Location =
        New-Object System.Drawing.Point(15, 15)

    $description.Size =
        New-Object System.Drawing.Size(600, 40)

    $form.Controls.Add($description)


    # ========================================================
    # スケジュール一覧
    # ========================================================

    $listView =
        New-Object System.Windows.Forms.ListView

    $listView.Location =
        New-Object System.Drawing.Point(15, 65)

    $listView.Size =
        New-Object System.Drawing.Size(600, 240)

    $listView.View =
        [System.Windows.Forms.View]::Details

    $listView.FullRowSelect = $true
    $listView.GridLines = $true
    $listView.HideSelection = $false

    [void]$listView.Columns.Add("#", 45)
    [void]$listView.Columns.Add("前のイベントから", 190)
    [void]$listView.Columns.Add("動作", 180)

    $form.Controls.Add($listView)


    # ========================================================
    # 時間入力
    # ========================================================

    $hours =
        New-Object System.Windows.Forms.NumericUpDown

    $hours.Location =
        New-Object System.Drawing.Point(15, 330)

    $hours.Minimum = 0
    $hours.Maximum = $ScheduleMaxHours
    $hours.Width = 80


    $hoursLabel =
        New-Object System.Windows.Forms.Label

    $hoursLabel.Text = "時間"

    $hoursLabel.Location =
        New-Object System.Drawing.Point(100, 334)

    $hoursLabel.AutoSize = $true


    $minutes =
        New-Object System.Windows.Forms.NumericUpDown

    $minutes.Location =
        New-Object System.Drawing.Point(145, 330)

    $minutes.Minimum = 0
    $minutes.Maximum = $ScheduleMaxMinutes
    $minutes.Width = 65


    $minutesLabel =
        New-Object System.Windows.Forms.Label

    $minutesLabel.Text = "分"

    $minutesLabel.Location =
        New-Object System.Drawing.Point(215, 334)

    $minutesLabel.AutoSize = $true


    # ========================================================
    # 動作
    # ========================================================

    $actionCombo =
        New-Object System.Windows.Forms.ComboBox

    $actionCombo.Location =
        New-Object System.Drawing.Point(260, 330)

    $actionCombo.Width = 130

    $actionCombo.DropDownStyle =
        [System.Windows.Forms.ComboBoxStyle]::DropDownList

    [void]$actionCombo.Items.Add("一時停止")
    [void]$actionCombo.Items.Add("再開")
    [void]$actionCombo.Items.Add("終了")

    # 0番目の「一時停止」を初期選択する。
    # ComboBoxを未選択状態にせず、追加ボタンをそのまま使用できるようにする。
    $actionCombo.SelectedIndex = 0


    $form.Controls.Add($hours)
    $form.Controls.Add($hoursLabel)
    $form.Controls.Add($minutes)
    $form.Controls.Add($minutesLabel)
    $form.Controls.Add($actionCombo)

    # ========================================================
    # ダイアログ状態
    # ========================================================
    #
    # Show()によるモードレス表示では、
    # Show-ScheduleDialog関数終了後もフォームが残る。
    #
    # 後から実行されるボタンイベントから各コントロールを
    # 参照できるよう、必要な参照をForm.Tagへまとめて保持する。

    $form.Tag =
        [PSCustomObject]@{
            ListView    = $listView
            Hours       = $hours
            Minutes     = $minutes
            ActionCombo = $actionCombo
        }
    
    # ========================================================
    # ステップ追加
    # ========================================================

    $addButton =
        New-Object System.Windows.Forms.Button

    $addButton.Text = "追加"
    $addButton.Location =
        New-Object System.Drawing.Point(410, 328)

    $addButton.Width = 70

    $addButton.Add_Click({

        param (
            $sender,
            $eventArgs
        )

        # イベントを発生させたButtonから、
        # 所属しているFormとダイアログ状態を取得する。
        $form = $sender.FindForm()
        $state = $form.Tag

        $delay =
            New-TimeSpan `
                -Hours ([int]$state.Hours.Value) `
                -Minutes ([int]$state.Minutes.Value)

        switch ($state.ActionCombo.SelectedItem) {

            "一時停止" {
                $action = "Pause"
            }

            "再開" {
                $action = "Resume"
            }

            "終了" {
                $action = "Stop"
            }
        }

        $step =
            [PSCustomObject]@{
                Delay  = $delay
                Action = $action
            }

        $item =
            New-Object System.Windows.Forms.ListViewItem

        $item.Text =
            [string]($state.ListView.Items.Count + 1)

        $durationText =
            "{0}時間 {1}分" -f `
                [math]::Floor($delay.TotalHours),
                $delay.Minutes

        [void]$item.SubItems.Add(
            $durationText
        )

        [void]$item.SubItems.Add(
            (Get-ScheduleActionText $action)
        )

        $item.Tag = $step

        [void]$state.ListView.Items.Add($item)
    })

    # ========================================================
    # 削除
    # ========================================================

    $deleteButton =
        New-Object System.Windows.Forms.Button

    $deleteButton.Text = "削除"
    $deleteButton.Location =
        New-Object System.Drawing.Point(490, 328)

    $deleteButton.Width = 60


    $deleteButton.Add_Click({

        param (
            $sender,
            $eventArgs
        )

        $form = $sender.FindForm()
        $state = $form.Tag

        if ($state.ListView.SelectedItems.Count -eq 0) {
            return
        }

        $state.ListView.Items.Remove(
            $state.ListView.SelectedItems[0]
        )

        Update-ScheduleListNumbers -ListView $state.ListView
    })


    # ========================================================
    # 上へ
    # ========================================================

    $upButton =
        New-Object System.Windows.Forms.Button

    $upButton.Text = "↑"
    $upButton.Location =
        New-Object System.Drawing.Point(560, 328)

    $upButton.Width = 25


    $upButton.Add_Click({

        param (
            $sender,
            $eventArgs
        )

        $form = $sender.FindForm()
        $state = $form.Tag

        if ($state.ListView.SelectedItems.Count -eq 0) {
            return
        }

        $item = $state.ListView.SelectedItems[0]
        $index = $item.Index

        if ($index -le 0) {
            return
        }

        $state.ListView.Items.RemoveAt($index)
        $state.ListView.Items.Insert($index - 1, $item)

        $item.Selected = $true

        Update-ScheduleListNumbers -ListView $state.ListView
    })


    # ========================================================
    # 下へ
    # ========================================================

    $downButton =
        New-Object System.Windows.Forms.Button

    $downButton.Text = "↓"
    $downButton.Location =
        New-Object System.Drawing.Point(590, 328)

    $downButton.Width = 25


    $downButton.Add_Click({

        param (
            $sender,
            $eventArgs
        )

        $form = $sender.FindForm()
        $state = $form.Tag

        if ($state.ListView.SelectedItems.Count -eq 0) {
            return
        }

        $item = $state.ListView.SelectedItems[0]
        $index = $item.Index

        if (
            $index -ge
            ($state.ListView.Items.Count - 1)
        ) {
            return
        }

        $state.ListView.Items.RemoveAt($index)
        $state.ListView.Items.Insert($index + 1, $item)

        $item.Selected = $true

        Update-ScheduleListNumbers -ListView $state.ListView
    })


    $form.Controls.Add($addButton)
    $form.Controls.Add($deleteButton)
    $form.Controls.Add($upButton)
    $form.Controls.Add($downButton)


    # ========================================================
    # 現在の設定を表示
    # ========================================================

    foreach ($step in $script:ScheduleSteps) {

        $item =
            New-Object System.Windows.Forms.ListViewItem

        $item.Text =
            [string]($listView.Items.Count + 1)

        $durationText =
            "{0}時間 {1}分" -f `
                [math]::Floor(
                    $step.Delay.TotalHours
                ),
                $step.Delay.Minutes

        [void]$item.SubItems.Add(
            $durationText
        )

        [void]$item.SubItems.Add(
            (Get-ScheduleActionText $step.Action)
        )

        $item.Tag =
            [PSCustomObject]@{
                Delay  = $step.Delay
                Action = $step.Action
            }

        [void]$listView.Items.Add($item)
    }


    # ========================================================
    # 設定ボタン
    # ========================================================

    $setButton =
        New-Object System.Windows.Forms.Button

    $setButton.Text = "スケジュール設定"

    $setButton.Location =
        New-Object System.Drawing.Point(310, 410)

    $setButton.Size =
        New-Object System.Drawing.Size(130, 35)


    $setButton.Add_Click({

        param (
            $sender,
            $eventArgs
        )

        $form = $sender.FindForm()
        $state = $form.Tag

        $steps = @()

        foreach ($item in $state.ListView.Items) {
            $steps += $item.Tag
        }


        $result =
            Test-MouseMoveSchedule `
                -Steps $steps


        if (-not $result.Valid) {

            [System.Windows.Forms.MessageBox]::Show(
                $result.Message,
                "MouseMovePS",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )

            return
        }


        Start-MouseMoveSchedule `
            -Steps $steps


        $form.Close()
    })


    # ========================================================
    # スケジュール解除
    # ========================================================

    $clearButton =
        New-Object System.Windows.Forms.Button

    $clearButton.Text = "解除"

    $clearButton.Location =
        New-Object System.Drawing.Point(450, 410)

    $clearButton.Size =
        New-Object System.Drawing.Size(70, 35)


    $clearButton.Add_Click({

        param (
            $sender,
            $eventArgs
        )

        $form = $sender.FindForm()

        Clear-MouseMoveSchedule

        $form.Close()
    })


    # ========================================================
    # キャンセル
    # ========================================================

    $cancelButton =
        New-Object System.Windows.Forms.Button

    $cancelButton.Text = "キャンセル"

    $cancelButton.Location =
        New-Object System.Drawing.Point(530, 410)

    $cancelButton.Size =
        New-Object System.Drawing.Size(85, 35)


    $cancelButton.Add_Click({

        param (
            $sender,
            $eventArgs
        )

        $form = $sender.FindForm()

        $form.Close()
    })


    $form.Controls.Add($setButton)
    $form.Controls.Add($clearButton)
    $form.Controls.Add($cancelButton)

    # ========================================================
    # フォーム終了処理
    # ========================================================

    $form.Add_FormClosed({

        param (
            $sender,
            $eventArgs
        )

        # 閉じたフォームへの参照を残さない。
        #
        # 次回「スケジュール設定...」を選択した際に
        # 新しいフォームを作成できるよう$nullへ戻す。
        #
        # 念のため、現在保持しているフォーム自身が
        # 閉じられた場合だけ参照を解除する。

        if ($sender -eq $script:ScheduleForm) {
            $script:ScheduleForm = $null
        }

    })

    # ========================================================
    # スケジュール設定画面をモードレス表示
    # ========================================================
    #
    # ShowDialog()ではなくShow()を使用する。
    #
    # ShowDialog()はフォームを閉じるまでこの関数から戻らないため、
    # MouseMovePS本体のメインループも停止してしまう。
    #
    # Show()ならフォーム表示後すぐに呼び出し元へ戻るので、
    # 設定画面を開いたままでもMouseMove処理、
    # スケジュール処理、停止要求確認を継続できる。
    #
    # メインループではApplication.DoEvents()を定期実行しているため、
    # モードレスフォームのボタン操作等も処理される。

    $form.Show()

    # 作成直後のフォームを前面へ表示する。
    $form.Activate()

    # # ========================================================
    # # スケジュール設定画面表示中のスケジュール監視
    # # ========================================================
    # #
    # # ShowDialog() はモーダル表示のため、この関数が終了するまで
    # # 外側にあるMouseMovePSのメインループへ処理が戻らない。
    # #
    # # 通常時はメインループ側でUpdate-MouseMoveScheduleを定期実行しているが、
    # # このダイアログを開いている間はその処理が止まる。
    # #
    # # そのためWindows FormsのTimerを使用し、
    # # ダイアログ表示中だけスケジュール状態を別途確認する。
    # #
    # # Timerの間隔には$ControlCheckIntervalMsを使用する。
    # # Defaultの100msで、予定時刻からの確認遅延をおおむね0.1秒以内に抑えつつ、
    # # 数ms単位の過剰な監視を避ける。

    # $dialogScheduleTimer =
    #     New-Object System.Windows.Forms.Timer

    # $dialogScheduleTimer.Interval =
    #     $ControlCheckIntervalMs


    # $dialogScheduleTimer.Add_Tick({

    #     # 現在のスケジュールを進行し、
    #     # タスクトレイメニューに表示する残り時間も更新する。
    #     Update-MouseMoveSchedule
    #     Update-ScheduleStatusText


    #     # WaitOne(0) の0msは「待機しない」指定。
    #     # 停止イベントがすでにセットされているかだけを非ブロッキングで確認する。
    #     #
    #     # スケジュールのStop、タスクトレイの停止、
    #     # または別インスタンスから停止要求を受信した場合は、
    #     # モーダルダイアログを閉じて通常の終了処理へ制御を戻す。
    #     if ($stopEvent.WaitOne(0)) {
    #         $form.Close()
    #     }
    # })


    # # ========================================================
    # # スケジュール設定画面を表示
    # # ========================================================

    # try {

    #     # ShowDialog中のみ監視Timerを動作させる。
    #     $dialogScheduleTimer.Start()

    #     [void]$form.ShowDialog()
    # }
    # finally {

    #     # ダイアログ終了後はTimerを確実に停止・破棄する。
    #     # 再度設定画面を開いた際に古いTimerを残さないため、
    #     # Disposeまでここで実行する。
    #     $dialogScheduleTimer.Stop()
    #     $dialogScheduleTimer.Dispose()

    #     $form.Dispose()
    # }
}

# ============================================================
# 多重起動チェック
# ============================================================

$createdNew = $false

$mutex = New-Object System.Threading.Mutex(
    $true,
    $mutexName,
    [ref]$createdNew
)

# ============================================================
# すでに起動中なら「停止要求」を送って終了
# ============================================================

if (-not $createdNew) {

    try {
        $stopEvent = [System.Threading.EventWaitHandle]::OpenExisting(
            $stopEventName
        )

        # 実行中のMouseMoveへ停止要求
        $stopEvent.Set() | Out-Null

        $stopEvent.Dispose()
    }
    catch {
        # すでに終了していた場合などは何もしない
    }

    $mutex.Dispose()
    exit
}

# ============================================================
# ここからON側
# ============================================================

# ============================================================
# 停止要求イベント
# ============================================================
#
# 設定値警告を表示する前に作成する。
#
# 警告ダイアログ表示中にMouseMovePSがもう一度起動された場合でも、
# 2個目のプロセスがこのEventWaitHandleを開いて停止要求を送れるようにする。

$stopEvent = New-Object System.Threading.EventWaitHandle(
    $false,
    [System.Threading.EventResetMode]::ManualReset,
    $stopEventName
)


# ============================================================
# 設定値警告
# ============================================================

if ($script:SettingWarnings.Count -gt 0) {

    $warningMessage =
        "設定値に不正な値が見つかりました。" +
        "`r`n" +
        "該当する設定はDefault値へ戻して実行します。" +
        "`r`n`r`n" +
        ($script:SettingWarnings -join "`r`n")


    # コンソールを表示して実行している場合にも確認できるよう
    # Write-Warningへ同じ内容を出力する。
    Write-Warning $warningMessage

    # GUI実行時にも気付けるよう警告ダイアログを表示する。
    [void][System.Windows.Forms.MessageBox]::Show(
        $warningMessage,
        "MouseMovePS - 設定値の警告",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
}

# ============================================================
# タスクトレイアイコン
# ============================================================

# 標準の情報アイコンを読み込む
$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
# アイコンのパスを決定するために、スクリプトのベース名を取得
$ScriptBaseName = [System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath)
# アイコンのパスを決定
$TrayIconPath = Join-Path $PSScriptRoot ($ScriptBaseName + ".ico")

# アイコンのパスが存在するか確認して、存在すれば用意されたアイコンを使用し、存在しなければWindows標準アイコンを使用
if (Test-Path -LiteralPath $TrayIconPath) {

    # ps1と同じフォルダーにMouseMove.icoがある場合
    $notifyIcon.Icon = New-Object System.Drawing.Icon($TrayIconPath)

}
else {

    # アイコンが見つからない場合はWindows標準アイコンを使用
    $notifyIcon.Icon = [System.Drawing.SystemIcons]::Information
}

# マウスをアイコンに重ねた時の表示
$notifyIcon.Text = "Mouse Move : ON"

# アイコンを表示
$notifyIcon.Visible = $true

# ============================================================
# 右クリックメニュー
# ============================================================

$contextMenu = New-Object System.Windows.Forms.ContextMenuStrip

# 状態表示
$statusItem = New-Object System.Windows.Forms.ToolStripMenuItem
$statusItem.Text =
    ([char]0x72B6).ToString() +
    ([char]0x614B) +
    ([char]0xFF1A) +
    "ON"

# スケジュール状態
$scheduleStatusItem =
    New-Object System.Windows.Forms.ToolStripMenuItem

$scheduleStatusItem.Text =
    "スケジュール：設定なし"

$scheduleStatusItem.Enabled = $false


# スケジュール設定
$scheduleItem =
    New-Object System.Windows.Forms.ToolStripMenuItem

$scheduleItem.Text =
    "スケジュール設定..."


$scheduleItem.Add_Click({

    Show-ScheduleDialog
})


# スケジュール解除
$clearScheduleItem =
    New-Object System.Windows.Forms.ToolStripMenuItem

$clearScheduleItem.Text =
    "スケジュール解除"


$clearScheduleItem.Add_Click({

    Clear-MouseMoveSchedule
})

# 停止ボタン
$stopItem = New-Object System.Windows.Forms.ToolStripMenuItem
$stopItem.Text = ([char]0x505C).ToString() + ([char]0x6B62)

# 停止がクリックされたら停止イベントをセット
$stopItem.Add_Click({
    $stopEvent.Set() | Out-Null
})

# メニューへ追加
[void]$contextMenu.Items.Add($statusItem)

[void]$contextMenu.Items.Add(
    (New-Object System.Windows.Forms.ToolStripSeparator)
)

[void]$contextMenu.Items.Add(
    $scheduleStatusItem
)

[void]$contextMenu.Items.Add(
    $scheduleItem
)

[void]$contextMenu.Items.Add(
    $clearScheduleItem
)

[void]$contextMenu.Items.Add(
    (New-Object System.Windows.Forms.ToolStripSeparator)
)

[void]$contextMenu.Items.Add($stopItem)

# トレイアイコンへメニューを設定
$notifyIcon.ContextMenuStrip = $contextMenu

# ============================================================
# ON通知
# ============================================================

$notifyIcon.BalloonTipTitle = "Mouse Move"
$notifyIcon.BalloonTipText = "Mouse Move をONにしました"
$notifyIcon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info

$notifyIcon.ShowBalloonTip($OnNotificationDurationMs)

# ============================================================
# メイン処理
# ============================================================

try {

    while ($true) {

        # ----------------------------------------------------
        # スケジュール処理
        # ----------------------------------------------------

        Update-MouseMoveSchedule
        Update-ScheduleStatusText


        # ----------------------------------------------------
        # 停止要求チェック
        # ----------------------------------------------------
        #
        # WaitOne(0) の0msは「待機しない」指定。
        # 停止イベントが現在セットされているかだけを確認し、
        # セットされていなければ即座に次の処理へ進む。
        # 通常のマウス移動処理をブロックしないため0msとしている。
        if ($stopEvent.WaitOne(0)) {
            break
        }


        # ----------------------------------------------------
        # スケジュールによる一時停止
        # ----------------------------------------------------

        if ($script:SchedulePaused) {

            # 一時停止中もMouseMovePS自体は終了せず、
            # $ControlCheckIntervalMsごとに停止要求を確認する。
            #
            # Defaultは100ms。
            # スケジュール再開やユーザーからの停止操作へ十分素早く反応しながら、
            # CPUを使って連続監視することを避ける。
            if ($stopEvent.WaitOne($ControlCheckIntervalMs)) {
                break
            }

            # Windows Formsのメッセージを処理することで、
            # タスクトレイメニューなどのUIイベントを処理する。
            [System.Windows.Forms.Application]::DoEvents()

            continue
            
        }

        # ----------------------------------------------------
        # 停止要求チェック
        # ----------------------------------------------------

        if ($stopEvent.WaitOne(0)) {
            break
        }

        # ----------------------------------------------------
        # 移動方向をランダム決定
        #
        # X方向・Y方向それぞれについて
        #   -1 = 負方向
        #    0 = その軸では移動しない
        #    1 = 正方向
        # の3種類からランダムに選択する。
        #
        # PowerShellのGet-Randomでは-Maximumの値そのものは結果に含まれない
        # （上限は排他的）ため、-1 / 0 / 1を取得するには
        # -Minimum -1、-Maximum 2とする必要がある。
        #
        # 最後に$MovePixelsを掛けるため、
        # Defaultの1pxではX/Yそれぞれ-1 / 0 / +1pxとなる。
        #
        # X=0かつY=0だけはマウスが全く動かないため除外し、
        # 結果として上下左右＋斜めの8方向から選択される。
        # ----------------------------------------------------

        do {
            $DX = (Get-Random -Minimum -1 -Maximum 2) * $MovePixels
            $DY = (Get-Random -Minimum -1 -Maximum 2) * $MovePixels
        }
        while (($DX -eq 0) -and ($DY -eq 0))

        # ----------------------------------------------------
        # マウス入力を発生
        # 発動毎に $MoveRepeatCount 回 実行
        # 移動後毎に $MoveReturnDelayMs ms待機して元の位置に戻す
        # ----------------------------------------------------

        for ($I = 0; $I -lt $MoveRepeatCount; $I++) {

            # 停止要求チェック
            if ($stopEvent.WaitOne(0)) {
                break
            }

            # [debug] アイドルタイム表示
            if ($DebugEnabled) {
                $idle = [IdleTime]::GetIdleSeconds()
                Write-Host ("Idle: {0:N3} sec" -f $idle)
            }

            # 実際にマウスポインターを移動
            #
            # SendInputで相対マウス移動イベントを送信
            [MouseInput]::Move($DX, $DY)


            # ------------------------------------------------
            # 元の位置へ戻すまで待機
            # ------------------------------------------------
            #
            # WaitOneを使用することで、待機中にも停止要求を検出する。
            #
            # ただし停止要求を受け取った場合でも、
            # ここでは直ちにbreakしない。
            #
            # 移動した後に復帰処理を飛ばすと、
            # カーソルが$MovePixels分ずれた状態で終了する可能性があるため、
            # 停止要求の有無を一旦変数へ保存し、
            # 必ず元の位置へ戻してから終了判定を行う。

            $stopRequested =
                $stopEvent.WaitOne($MoveReturnDelayMs)


            # ------------------------------------------------
            # 元の位置に戻す
            # ------------------------------------------------
            #
            # 停止要求の有無にかかわらず必ず実行する。
            [MouseInput]::Move(-$DX, -$DY)

            # ------------------------------------------------
            # 復帰後に停止
            # ------------------------------------------------

            if ($stopRequested) {
                break
            }

            # [debug] 操作後アイドルタイム表示
            if ($DebugEnabled) {
                $idle = [IdleTime]::GetIdleSeconds()
                Write-Host ("Idle: {0:N3} sec" -f $idle)
            }

            # ------------------------------------------------
            # Windows Formsのイベント処理
            #
            # これを入れることで、
            # タスクトレイの右クリック操作などを処理できる
            # ------------------------------------------------

            [System.Windows.Forms.Application]::DoEvents()
        }

        # ----------------------------------------------------
        # 停止要求チェック
        # ----------------------------------------------------

        if ($stopEvent.WaitOne(0)) {
            break
        }

        # ----------------------------------------------------
        # $MainIntervalSeconds 秒待機
        #
        # ただし停止要求が来たら即終了
        # ----------------------------------------------------

        $waitStart = [DateTime]::Now

        while (
            ([DateTime]::Now - $waitStart).TotalSeconds -lt $MainIntervalSeconds
        ) {

            # 次回のマウス移動まで待機しながら、
            # $ControlCheckIntervalMsごとに停止要求を確認する。
            #
            # Defaultは100ms。
            # 60秒を一括でSleepする場合と異なり、
            # 停止・一時停止・再開などへ短時間で反応できる。
            if ($stopEvent.WaitOne($ControlCheckIntervalMs)) {
                break
            }

            Update-MouseMoveSchedule
            Update-ScheduleStatusText
            
            if ($stopEvent.WaitOne(0)) {
                break
            }

            # 一時停止へ切り替わった場合は
            # 通常の60秒待機から抜ける
            if ($script:SchedulePaused) {
                break
            }

            # タスクトレイ操作を受け付ける
            [System.Windows.Forms.Application]::DoEvents()
        }

        if ($stopEvent.WaitOne(0)) {
            break
        }
    }
}
finally {

    # ========================================================
    # OFF処理
    # ========================================================

    # OFF通知
    try {
        $notifyIcon.BalloonTipTitle = "Mouse Move"
        $notifyIcon.BalloonTipText = "Mouse Move をOFFにしました"
        $notifyIcon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info

        $notifyIcon.ShowBalloonTip($OffNotificationDurationMs)

        # 通知要求の直後にNotifyIconを破棄しないよう、
        # $NotificationDispatchWaitMsだけWindows側へ通知を引き渡す時間を確保する。
        $notificationWait = [DateTime]::Now

        while (
            ([DateTime]::Now - $notificationWait).TotalMilliseconds -lt $NotificationDispatchWaitMs
        ) {
            [System.Windows.Forms.Application]::DoEvents()
            Start-Sleep -Milliseconds $NotificationPumpIntervalMs
        }
    }
    catch {
    }

    # --------------------------------------------------------
    # タスクトレイアイコンを消す
    # --------------------------------------------------------

    $notifyIcon.Visible = $false

    # --------------------------------------------------------
    # 各オブジェクトを解放
    # --------------------------------------------------------

    if ($null -ne $script:ScheduleForm -and -not $script:ScheduleForm.IsDisposed) {
        $script:ScheduleForm.Close()
    }

    $contextMenu.Dispose()
    $notifyIcon.Dispose()

    $stopEvent.Dispose()

    if ($createdNew) {
        try {
            $mutex.ReleaseMutex()
        }
        catch {
        }
    }

    $mutex.Dispose()
}
