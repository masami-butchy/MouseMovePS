# ============================================================
# 設定
# ============================================================

# マウス移動を発動1回当たり何回繰り返すか
$MoveRepeatCount = 1

# 1回の移動後、元に戻すまでの待機時間（ミリ秒）
# Default: 8ms待機(120fps表示時の1フレーム秒=8.333...ms未満)
$MoveReturnDelayMs = 8

# 次の発動までの待機時間（秒）=発動終了から次の発動までの待機時間
$MainIntervalSeconds = 60

# 1回あたりの移動量（ピクセル）
$MovePixels = 1

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

function Show-ScheduleDialog {

    $form = New-Object System.Windows.Forms.Form

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
    $hours.Maximum = 9999
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
    $minutes.Maximum = 59
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

    $actionCombo.SelectedIndex = 0


    $form.Controls.Add($hours)
    $form.Controls.Add($hoursLabel)
    $form.Controls.Add($minutes)
    $form.Controls.Add($minutesLabel)
    $form.Controls.Add($actionCombo)


    # ========================================================
    # 一覧番号更新
    # ========================================================

    $updateNumbers = {

        for (
            $i = 0;
            $i -lt $listView.Items.Count;
            $i++
        ) {

            $listView.Items[$i].Text =
                [string]($i + 1)
        }
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

        $delay =
            New-TimeSpan `
                -Hours ([int]$hours.Value) `
                -Minutes ([int]$minutes.Value)


        switch ($actionCombo.SelectedItem) {

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
            [string]($listView.Items.Count + 1)

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

        [void]$listView.Items.Add($item)
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

        if ($listView.SelectedItems.Count -eq 0) {
            return
        }

        $listView.Items.Remove(
            $listView.SelectedItems[0]
        )

        & $updateNumbers
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

        if ($listView.SelectedItems.Count -eq 0) {
            return
        }

        $item = $listView.SelectedItems[0]
        $index = $item.Index

        if ($index -le 0) {
            return
        }

        $listView.Items.RemoveAt($index)
        $listView.Items.Insert($index - 1, $item)

        $item.Selected = $true

        & $updateNumbers
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

        if ($listView.SelectedItems.Count -eq 0) {
            return
        }

        $item = $listView.SelectedItems[0]
        $index = $item.Index

        if (
            $index -ge
            ($listView.Items.Count - 1)
        ) {
            return
        }

        $listView.Items.RemoveAt($index)
        $listView.Items.Insert($index + 1, $item)

        $item.Selected = $true

        & $updateNumbers
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

        $steps = @()

        foreach ($item in $listView.Items) {
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
        $form.Close()
    })


    $form.Controls.Add($setButton)
    $form.Controls.Add($clearButton)
    $form.Controls.Add($cancelButton)


    [void]$form.ShowDialog()

    $form.Dispose()
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

$stopEvent = New-Object System.Threading.EventWaitHandle(
    $false,
    [System.Threading.EventResetMode]::ManualReset,
    $stopEventName
)

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

$notifyIcon.ShowBalloonTip(2000)

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


        if ($stopEvent.WaitOne(0)) {
            break
        }


        # ----------------------------------------------------
        # スケジュールによる一時停止
        # ----------------------------------------------------

        if ($script:SchedulePaused) {

            if ($stopEvent.WaitOne(100)) {
                break
            }

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
        # X方向、Y方向それぞれに "-1 / 0 / 1 のいずれかの$MovePixels倍" を設定
        # （ただし、移動しない "X=0 かつ Y=0" は除く）
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

            # $MoveReturnDelayMs ms待機
            #
            # Start-SleepではなくWaitOneを使用することで、
            # 待機中でも停止要求を受け取れる
            if ($stopEvent.WaitOne($MoveReturnDelayMs)) {
                break
            }

            # 元の位置に戻す
            # 
            # SendInputで移動を打ち消す相対マウス移動イベントを送信
            [MouseInput]::Move(-$DX, -$DY)

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

            if ($stopEvent.WaitOne(100)) {
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

        $notifyIcon.ShowBalloonTip(1500)

        # 通知がWindows側へ渡る時間を少し確保
        $notificationWait = [DateTime]::Now

        while (
            ([DateTime]::Now - $notificationWait).TotalMilliseconds -lt 700
        ) {
            [System.Windows.Forms.Application]::DoEvents()
            Start-Sleep -Milliseconds 50
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
