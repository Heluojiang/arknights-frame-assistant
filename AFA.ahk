#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off

DetectHiddenWindows True 
DllCall("winmm\timeBeginPeriod", "UInt", 1)
OnExit (*) => DllCall("winmm\timeEndPeriod", "UInt", 1)

if not A_IsAdmin
{
    try {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp
}

ConfigDir := A_AppData "\ArknightsFrameAssistant\PC"
if !DirExist(ConfigDir)
    DirCreate(ConfigDir)
INI_FILE := ConfigDir "\Settings.ini"

global Version := "v1.1.12"
global WindowName := "明日方舟帧操小助手 " Version
global GameHasStarted := false, WaitingModify := false, LastEditCtrl := ""
global OriginalValue := "", ActiveIH := InputHook("L0"), MissingCounter := 0
global Delay := 11.3 

global DefaultAppSettings := Map(
    "PauseA", "f", "PauseB", "Space", "GameSpeed", "d",
    "33ms", "r", "166ms", "t", "Pauseselect", "w",
    "Skill", "s", "Retreat", "a", "OneClickSkill", "e",
    "OneClickRetreat", "q", "PauseSkill", "XButton2",
    "PauseRetreat", "XButton1", "AutoClose", "1",
    "AutoOpen", "1", "Frame", "3"
)
global AppSettings := DefaultAppSettings.Clone()

global DelayA := 35.3, DelayB := 19.6, DelayC := 11.3  

USleep(delay_ms) {
    static freq := 0
    l_start := 0, l_current := 0 
    if (freq = 0)
        DllCall("QueryPerformanceFrequency", "Int64*", &freq)
    DllCall("QueryPerformanceCounter", "Int64*", &l_start)
    target := l_start + (delay_ms * freq / 1000)
    while (l_current < target) {
        DllCall("QueryPerformanceCounter", "Int64*", &l_current)
    }
}

HandleAction(ThisHotkey, ActionType) {
    switch ActionType {
        case "Pause", "ReleasePause": 
            Send("{ESC Down}"), USleep(Delay), Send("{ESC Up}")
        case "Speed": 
            Send("{f Down}"), USleep(Delay), Send("{f Up}"), Send("{g Down}"), USleep(Delay), Send("{g Up}")
        case "33ms": 
            Send("{ESC Down}"), USleep(Delay), Send("{ESC Up}"), USleep(29 - Delay), Send("{ESC Down}"), USleep(Delay), Send("{ESC Up}")
        case "166ms": 
            Send("{ESC Down}"), USleep(Delay), Send("{ESC Up}"), USleep(166 - Delay), Send("{ESC Down}"), USleep(Delay), Send("{ESC Up}")
        case "Pauseselect": 
            Send("{ESC Down}"), USleep(Delay), Send("{Click Left}"), Send("{ESC Up}"), USleep(Delay * 1.2), Send("{ESC Down}"), USleep(Delay), Send("{ESC Up}")
        case "Skill": 
            Send("{e Down}"), USleep(Delay), Send("{e Up}")
        case "Retreat": 
            Send("{q Down}"), USleep(Delay), Send("{q Up}")
        case "OneClickSkill": 
            Send("{Click Left}"), USleep(Delay * 1.5), Send("{e Down}"), USleep(Delay * 1.3), Send("{e Up}")
        case "OneClickRetreat": 
            Send("{Click Left}"), USleep(Delay * 1.5), Send("{q Down}"), USleep(Delay * 1.3), Send("{q Up}")
        case "PauseSkill": 
            Send("{ESC Down}"), USleep(Delay), Send("{Click Left}"), Send("{ESC Up}"), USleep(Delay * 1.4), Send("{ESC Down}"), USleep(Delay), Send("{ESC Up}"), Send("{e Down}"), USleep(Delay * 1.2), Send("{e Up}")
        case "PauseRetreat": 
            Send("{ESC Down}"), USleep(Delay), Send("{Click Left}"), Send("{ESC Up}"), USleep(Delay * 1.4), Send("{ESC Down}"), USleep(Delay), Send("{ESC Up}"), Send("{q Down}"), USleep(Delay * 1.2), Send("{q Up}")
    }
    if !InStr(ThisHotkey, "Wheel")
        KeyWait(ThisHotkey)
}

MyGui := Gui(, WindowName)
MyGui.SetFont("s9", "Microsoft YaHei UI")

MyGui.Add("GroupBox", "x10 y10 w310 h250", "基础操作")
MyGui.Add("Text", "x20 y35 w100 Right +0x200", "额外暂停键A")
MyGui.Add("Edit", "x125 y35 w110 Center ReadOnly vPauseA", AppSettings["PauseA"])
MyGui.Add("Text", "x20 y70 w100 Right +0x200", "额外暂停键B")
MyGui.Add("Edit", "x125 y70 w110 Center ReadOnly vPauseB", AppSettings["PauseB"])
MyGui.SetFont("s8 cGray"), MyGui.Add("Text", "x240 y70 w60 +0x200", "(松开触发)"), MyGui.SetFont("s9 cDefault")
MyGui.Add("Text", "x20 y105 w100 Right +0x200", "切换倍速")
MyGui.Add("Edit", "x125 y105 w110 Center ReadOnly vGameSpeed", AppSettings["GameSpeed"])
MyGui.Add("Text", "x20 y140 w100 Right +0x200", "暂停选中")
MyGui.Add("Edit", "x125 y140 w110 Center ReadOnly vPauseselect", AppSettings["Pauseselect"])
MyGui.Add("Text", "x20 y175 w100 Right +0x200", "干员技能")
MyGui.Add("Edit", "x125 y175 w110 Center ReadOnly vSkill", AppSettings["Skill"])
MyGui.Add("Text", "x20 y210 w100 Right +0x200", "干员撤退")
MyGui.Add("Edit", "x125 y210 w110 Center ReadOnly vRetreat", AppSettings["Retreat"])

MyGui.Add("GroupBox", "x330 y10 w310 h250", "高级微操")
MyGui.Add("Text", "x340 y35 w100 Right +0x200", "前进 33ms")
MyGui.Add("Edit", "x445 y35 w110 Center ReadOnly v33ms", AppSettings["33ms"])
MyGui.Add("Text", "x340 y70 w100 Right +0x200", "前进 166ms")
MyGui.Add("Edit", "x445 y70 w110 Center ReadOnly v166ms", AppSettings["166ms"])
MyGui.Add("Text", "x340 y105 w100 Right +0x200", "一键技能")
MyGui.Add("Edit", "x445 y105 w110 Center ReadOnly vOneClickSkill", AppSettings["OneClickSkill"])
MyGui.Add("Text", "x340 y140 w100 Right +0x200", "一键撤退")
MyGui.Add("Edit", "x445 y140 w110 Center ReadOnly vOneClickRetreat", AppSettings["OneClickRetreat"])
MyGui.Add("Text", "x340 y175 w100 Right +0x200", "暂停技能")
MyGui.Add("Edit", "x445 y175 w110 Center ReadOnly vPauseSkill", AppSettings["PauseSkill"])
MyGui.Add("Text", "x340 y210 w100 Right +0x200", "暂停撤退")
MyGui.Add("Edit", "x445 y210 w110 Center ReadOnly vPauseRetreat", AppSettings["PauseRetreat"])

MyGui.Add("Text", "x10 y275 w630 h1 0x10")
MyGui.Add("Checkbox", "x30 y290 vAutoClose", " 随游戏进程关闭自动退出").Value := AppSettings["AutoClose"]
MyGui.Add("Checkbox", "x240 y290 vAutoOpen", " 启动时自动打开窗口").Value := AppSettings["AutoOpen"]
MyGui.Add("Text", "x30 y320", "游戏内帧数:")
GuiFrame := MyGui.Add("DropDownList", "x110 y317 w100 vFrame AltSubmit", ["30 FPS", "60 FPS", "120 FPS"])
GuiFrame.Value := AppSettings["Frame"]

MyGui.SetFont("c1b98d7"), MyGui.Add("Text", "x10 y345 w630 Center", "提示: 使用一键/暂停功能前，请先将鼠标指针指向对应干员"), MyGui.SetFont("cff2424"), MyGui.Add("Text", "x10 y365 w630 Center", "注意: 请关闭垂直同步，并确保设置与游戏内一致"), MyGui.SetFont("cDefault")
btnReset := MyGui.Add("Button", "x30 y395 w100 h32", "重置按键"), btnReset.OnEvent("Click", (*) => ResetSettings()), btnSave := MyGui.Add("Button", "x530 y395 w110 h32 Default", "保存并应用"), btnSave.OnEvent("Click", (*) => SaveAndApply())

LoadSettings() {
    for k, v in DefaultAppSettings
        AppSettings[k] := IniRead(INI_FILE, "Settings", k, v)
    global Delay := (AppSettings["Frame"] == "1") ? DelayA : (AppSettings["Frame"] == "2") ? DelayB : DelayC
}

HotkeyControl(State) {
    HotIfWinActive("ahk_exe Arknights.exe")
    Keys := ["PauseA", "PauseB", "GameSpeed", "33ms", "166ms", "Pauseselect", "Skill", "Retreat", "OneClickSkill", "OneClickRetreat", "PauseSkill", "PauseRetreat"]
    Actions := ["Pause", "ReleasePause", "Speed", "33ms", "166ms", "Pauseselect", "Skill", "Retreat", "OneClickSkill", "OneClickRetreat", "PauseSkill", "PauseRetreat"]
    for i, KeyVar in Keys {
        K := AppSettings[KeyVar]
        if (K != "") {
            BoundFunc := HandleAction.Bind(, Actions[i])
            try Hotkey(K, BoundFunc, State)
        }
    }
}

SaveAndApply() {
    HotkeyControl("Off"), Saved := MyGui.Submit() 
    for k, v in DefaultAppSettings {
        if Saved.HasProp(k) {
            AppSettings[k] := Saved.%k%
            IniWrite(AppSettings[k], INI_FILE, "Settings", k)
        }
    }
    LoadSettings(), HotkeyControl("On")
    ToolTip("设置已应用！"), SetTimer(() => ToolTip(), -2000)
}

ResetSettings() {
    if (MsgBox("确定要重置所有按键为默认设置吗？", "询问", "YesNo Icon!") == "No")
        return
    for k, v in DefaultAppSettings {
        try MyGui[k].Value := v
    }
    ToolTip("按键已重置，请点击保存！"), SetTimer(() => ToolTip(), -2500)
}

CheckGame() {
    global GameHasStarted, MissingCounter
    if (AppSettings["AutoClose"] == "1") {
        if WinExist("ahk_exe Arknights.exe") {
            GameHasStarted := true, MissingCounter := 0 
        } else if (GameHasStarted == true) {
            MissingCounter += 1
            if (MissingCounter >= 5)
                ExitApp()
        }
    }
}
SetTimer(CheckGame, 2000)

WatchActiveWindow() {
    global LastEditCtrl, OriginalValue, WaitingModify
    if (WinActive(WindowName) == 0 && LastEditCtrl != "")
        CancelModify()
}
SetTimer(WatchActiveWindow, 100)

LoadSettings()
HotkeyControl("On")
if (AppSettings["AutoOpen"] == "1") {
    MyGui.Show(), btnSave.Focus()
}

OnMessage(0x0201, WM_LBUTTONDOWN)
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    global LastEditCtrl, OriginalValue, WaitingModify, ActiveIH
    Ctrl := GuiCtrlFromHwnd(hwnd)
    if (Ctrl && Ctrl.Type == "Edit") {
        if (LastEditCtrl != "" && Ctrl != LastEditCtrl)
            LastEditCtrl.Value := OriginalValue
        LastEditCtrl := Ctrl, OriginalValue := Ctrl.Value, Ctrl.Value := "请按键...", WaitingModify := true
        if (ActiveIH.InProgress)
            ActiveIH.Stop()
        ActiveIH := InputHook("L1 M"), ActiveIH.KeyOpt("{All}", "E"), ActiveIH.OnEnd := (ih) => EndChange(ih.EndKey), ActiveIH.Start()
        return
    }
    if (LastEditCtrl != "")
        CancelModify()
}

CancelModify() {
    global LastEditCtrl, OriginalValue, WaitingModify, ActiveIH
    if (LastEditCtrl != "")
        LastEditCtrl.Value := OriginalValue, LastEditCtrl := ""
    WaitingModify := false
    if (ActiveIH.InProgress)
        ActiveIH.Stop()
}

EndChange(NewKey) {
    global LastEditCtrl, WaitingModify
    if (!WaitingModify || LastEditCtrl == "")
        return
    if (NewKey != "") {
        if (NewKey == "Escape" || NewKey == "Backspace")
            LastEditCtrl.Value := ""
        else
            LastEditCtrl.Value := NewKey
        LastEditCtrl := "", WaitingModify := false, btnSave.Focus()
    }
}

#HotIf WaitingModify
*MButton::
*XButton1::
*XButton2::
*WheelUp::
*WheelDown::
{
    CleanKey := StrReplace(A_ThisHotkey, "*", "")
    global LastEditCtrl, WaitingModify, ActiveIH
    if (LastEditCtrl != "") {
        LastEditCtrl.Value := CleanKey, LastEditCtrl := "", WaitingModify := false
        if (ActiveIH.InProgress)
            ActiveIH.Stop()
        btnSave.Focus()
    }
}
#HotIf

A_TrayMenu.Delete()
A_TrayMenu.Add("打开设置", (*) => MyGui.Show())
A_TrayMenu.Add("退出", (*) => ExitApp())