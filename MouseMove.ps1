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

# ============================================================
# 設定
# ============================================================

$mutexName     = "Local\MouseMoveToggle_Mutex"
$stopEventName = "Local\MouseMoveToggle_StopEvent"

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

$notifyIcon = New-Object System.Windows.Forms.NotifyIcon

# Windows標準アイコンを使用
$notifyIcon.Icon = [System.Drawing.SystemIcons]::Information

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

# 停止ボタン
$stopItem = New-Object System.Windows.Forms.ToolStripMenuItem
$stopItem.Text = ([char]0x505C).ToString() + ([char]0x6B62)

# 停止がクリックされたら停止イベントをセット
$stopItem.Add_Click({
    $stopEvent.Set() | Out-Null
})

# メニューへ追加
[void]$contextMenu.Items.Add($statusItem)
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
        # 停止要求チェック
        # ----------------------------------------------------

        if ($stopEvent.WaitOne(0)) {
            break
        }

        # ----------------------------------------------------
        # 移動方向をランダム決定
        #
        # -1 / 0 / 1 のどれか
        # ----------------------------------------------------

        do {
            $DX = Get-Random -Minimum -1 -Maximum 2
            $DY = Get-Random -Minimum -1 -Maximum 2
        }
        while (($DX -eq 0) -and ($DY -eq 0))

	    # ----------------------------------------------------
        # 現在のマウス位置取得
        # ----------------------------------------------------

        $originalPosition = [System.Windows.Forms.Cursor]::Position

        # ----------------------------------------------------
        # マウス入力を発生
        # 1回 × 8ms
        # ----------------------------------------------------

        for ($I = 0; $I -lt 1; $I++) {

            # 停止要求チェック
            if ($stopEvent.WaitOne(0)) {
                break
            }

            # 座標変更
            $temporaryPosition = $originalPosition
            $temporaryPosition.X += $DX
            $temporaryPosition.Y += $DY

            # [debug] アイドルタイム表示
            $idle = [IdleTime]::GetIdleSeconds()
            Write-Host ("Idle: {0:N3} sec" -f $idle)

            # 実際にマウスポインターを移動（マウスインプット）
            [MouseInput]::Move($DX, $DY)

            # 8ms待機(約120fps時の1フレーム秒)
            #
            # Start-SleepではなくWaitOneを使用することで、
            # 待機中でも停止要求を受け取れる
            if ($stopEvent.WaitOne(8)) {
                break
            }

            # 元の位置に戻す（逆方向へマウスインプット）
            [MouseInput]::Move(-$DX, -$DY)

            # [debug] アイドルタイム表示
            $idle = [IdleTime]::GetIdleSeconds()
            Write-Host ("Idle: {0:N3} sec" -f $idle)

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
        # 60秒待機
        #
        # ただし停止要求が来たら即終了
        # ----------------------------------------------------

        $waitStart = [DateTime]::Now

        while (
            ([DateTime]::Now - $waitStart).TotalSeconds -lt 60
        ) {

            if ($stopEvent.WaitOne(100)) {
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
