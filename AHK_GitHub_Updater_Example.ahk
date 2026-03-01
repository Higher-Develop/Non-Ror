; ============================================================
; AHK v1.1 GUI ตัวอย่างพร้อมระบบอัพเดทจาก GitHub
; ============================================================
; ผู้เขียน: Super Z
; เวอร์ชัน: 1.0.0
; คำอธิบาย: สคริปต์ตัวอย่างที่แสดงวิธีสร้าง GUI และระบบอัพเดท
; ============================================================

#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SendMode Input

; ============================================================
; การตั้งค่า - แก้ไขส่วนนี้ให้ตรงกับ GitHub ของคุณ
; ============================================================

;~ https://raw.githubusercontent.com/Higher-Develop/MyAHKApp/main/Version.ini

global AppName := "MyAHKApp"
global AppVersion := "1.0.0"
global GitHubUser := "Higher-Develop"
global GitHubRepo := "MyAHKApp"
global VersionURL := "https://raw.githubusercontent.com/" . GitHubUser . "/" . GitHubRepo . "/main/version.ini"
global DownloadURL := "https://github.com/" . GitHubUser . "/" . GitHubRepo . "/releases/download/v"

; ============================================================
; สร้าง GUI หลัก
; ============================================================
Gui, Main:New, +Resize +MinSize400x300, %AppName% v%AppVersion%
Gui, Font, s10, Segoe UI
Gui, Color, F5F5F5

; Menu Bar
Menu, FileMenu, Add, &ตรวจสอบอัพเดท`tCtrl+U, CheckUpdate
Menu, FileMenu, Add
Menu, FileMenu, Add, &รีสตาร์ทโปรแกรม, RestartApp
Menu, FileMenu, Add
Menu, FileMenu, Add, &ออกจากโปรแกรม`tAlt+F4, ExitApp
Menu, HelpMenu, Add, &เกี่ยวกับโปรแกรม, ShowAbout
Menu, HelpMenu, Add, &ดูบน GitHub, OpenGitHub
Menu, MyMenuBar, Add, &ไฟล์, :FileMenu
Menu, MyMenuBar, Add, &ช่วยเหลือ, :HelpMenu
Gui, Menu, MyMenuBar

; Header Section
Gui, Add, GroupBox, x10 y10 w380 h80, ข้อมูลโปรแกรม
Gui, Add, Text, x20 y30 w360 h20, ชื่อโปรแกรม: %AppName%
Gui, Add, Text, x20 y50 w360 h20, เวอร์ชันปัจจุบัน: v%AppVersion%
Gui, Add, Text, x20 y70 w360 h20 vUpdateStatus, สถานะ: พร้อมใช้งาน

; Status Section
Gui, Add, GroupBox, x10 y100 w380 h100, สถานะระบบ
Gui, Add, Text, x20 y120 w100 h20, CPU:
Gui, Add, Progress, x120 y120 w260 h20 vCPUProgress cGreen, 0
Gui, Add, Text, x20 y150 w100 h20, หน่วยความจำ:
Gui, Add, Progress, x120 y150 w260 h20 vMemProgress cBlue, 0
Gui, Add, Text, x20 y180 w360 h20 vSystemInfo, กำลังโหลดข้อมูล...

; Action Buttons
Gui, Add, GroupBox, x10 y210 w380 h80, การดำเนินการ
Gui, Add, Button, x20 y230 w170 h30 gCheckUpdate, 🔍 ตรวจสอบอัพเดท
Gui, Add, Button, x200 y230 w180 h30 gOpenSettings, ⚙️ ตั้งค่า
Gui, Add, Button, x20 y260 w170 h30 gRunDemo, ▶️ ทดสอบฟีเจอร์
Gui, Add, Button, x200 y260 w180 h30 gShowLog, 📋 ดู Log

; Footer
Gui, Add, Text, x10 y300 w380 h20 Center, กด Ctrl+U เพื่อตรวจสอบอัพเดท

Gui, Show, w400 h330
Gosub, UpdateSystemInfo
SetTimer, UpdateSystemInfo, 2000

; ============================================================
; Hotkeys
; ============================================================
^u::Gosub, CheckUpdate
^r::Reload

; ============================================================
; Labels และ Functions
; ============================================================

MainGuiClose:
    ExitApp
Return

MainGuiSize:
    if (A_EventInfo = 1)
        Return
    GuiControl, Move, UpdateStatus, w%A_GuiWidth%
Return

; อัพเดทข้อมูลระบบ
UpdateSystemInfo:
    CPUUsage := GetCPUUsage()
    MemUsage := GetMemoryUsage()
    GuiControl,, CPUProgress, %CPUUsage%
    GuiControl,, MemProgress, %MemUsage%
    GuiControl,, SystemInfo, CPU: %CPUUsage%`% | หน่วยความจำ: %MemUsage%`%
Return

; ตรวจสอบอัพเดท
CheckUpdate:
    GuiControl,, UpdateStatus, สถานะ: กำลังตรวจสอบ...

    ; แสดง Progress GUI
    Gui, UpdateProgress:New, -SysMenu +AlwaysOnTop, ตรวจสอบอัพเดท
    Gui, UpdateProgress:Font, s10, Segoe UI
    Gui, UpdateProgress:Add, Text, x10 y10 w280 h20 Center, กำลังตรวจสอบเวอร์ชันใหม่...
    Gui, UpdateProgress:Add, Progress, x10 y40 w280 h20 vDLProgress -Smooth, 0
    Gui, UpdateProgress:Show, w300 h80

    ; ดาวน์โหลด version.ini
    TempFile := A_Temp . "\Version_Check.ini"
    try {
        URLDownloadToFile, %VersionURL%, %TempFile%

        if (FileExist(TempFile)) {
            IniRead, LatestVersion, %TempFile%, Version, Version, 0.0.0
            IniRead, ReleaseNotes, %TempFile%, Version, ReleaseNotes, ไม่มีข้อมูล
            IniRead, Mandatory, %TempFile%, Version, Mandatory, 0

            Gui, UpdateProgress:Destroy

            ; เปรียบเทียบเวอร์ชัน
            if (CompareVersions(LatestVersion, AppVersion)) {
                ; มีเวอร์ชันใหม่
                MsgBox, 68, พบอัพเดทใหม่!
                , มีเวอร์ชันใหม่: v%LatestVersion%`nเวอร์ชันปัจจุบัน: v%AppVersion%`n`nRelease Notes:`n%ReleaseNotes%`n`nต้องการดาวน์โหลดเดี๋ยวนี้หรือไม่?

                IfMsgBox, Yes
                {
                    DownloadUpdate(LatestVersion)
                }
            } else {
                GuiControl,, UpdateStatus, สถานะ: ใช้เวอร์ชันล่าสุดแล้ว
                MsgBox, 64, ไม่มีอัพเดท, คุณใช้เวอร์ชันล่าสุดแล้ว (v%AppVersion%)
            }

            FileDelete, %TempFile%
        } else {
            Gui, UpdateProgress:Destroy
            GuiControl,, UpdateStatus, สถานะ: ไม่สามารถตรวจสอบได้
            MsgBox, 48, ข้อผิดพลาด, ไม่สามารถดาวน์โหลดข้อมูลเวอร์ชันได้`nกรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต
        }
    } catch e {
        Gui, UpdateProgress:Destroy
        GuiControl,, UpdateStatus, สถานะ: เกิดข้อผิดพลาด
        MsgBox, 16, ข้อผิดพลาด, เกิดข้อผิดพลาดในการตรวจสอบอัพเดท:`n%e%
    }
Return

; ดาวน์โหลดอัพเดท
DownloadUpdate(Version) {
    global AppName, DownloadURL

    URL := DownloadURL . Version . "/" . AppName . ".exe"
    TempFile := A_Temp . "\" . AppName . "_update.exe"

    ; แสดง GUI ดาวน์โหลด
    Gui, DownloadGUI:New, -SysMenu +AlwaysOnTop, ดาวน์โหลดอัพเดท
    Gui, DownloadGUI:Font, s10, Segoe UI
    Gui, DownloadGUI:Add, Text, x10 y10 w280 h20, กำลังดาวน์โหลด v%Version%...
    Gui, DownloadGUI:Add, Progress, x10 y40 w280 h20 vDLProgress -Smooth, 0
    Gui, DownloadGUI:Add, Text, x10 y70 w280 h20 vDLPercent Center, 0`%
    Gui, DownloadGUI:Show, w300 h100

    try {
        ; ใช้ WinHttp สำหรับดาวน์โหลดพร้อม Progress
        DownloadWithProgress(URL, TempFile, "DLProgress", "DLPercent")

        Gui, DownloadGUI:Destroy

        MsgBox, 68, ดาวน์โหลดสำเร็จ, ดาวน์โหลดเสร็จสมบูรณ์!`n`nต้องการติดตั้งเดี๋ยวนี้หรือไม่?

        IfMsgBox, Yes
        {
            ; สร้าง batch file สำหรับอัพเดท
            UpdateBat := A_Temp . "\update.bat"
            BatchContent := "@echo off`n"
            . "timeout /t 2 /nobreak > nul`n"
            . "taskkill /f /im """ . AppName . ".exe"" > nul 2>&1`n"
            . "move /y """ . TempFile . """ """ . A_ScriptDir . "\" . AppName . ".exe""`n"
            . "start """" """ . A_ScriptDir . "\" . AppName . ".exe""`n"
            . "del ""%~f0""`n"

            FileDelete, %UpdateBat%
            FileAppend, %BatchContent%, %UpdateBat%

            Run, %UpdateBat%, , Hide
            ExitApp
        }
    } catch e {
        Gui, DownloadGUI:Destroy
        MsgBox, 16, ข้อผิดพลาด, ไม่สามารถดาวน์โหลดอัพเดทได้:`n%e%
    }
}

; ดาวน์โหลดพร้อมแสดง Progress
DownloadWithProgress(URL, Dest, ProgressControl, PercentControl) {
    global DownloadGUI

    try {
        ; ใช้ WinHttp.WinHttpRequest
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", URL, true)
        whr.Send()

        ; รอการตอบสนอง
        whr.WaitForResponse()

        ; ตรวจสอบ Content-Length
        Size := whr.GetResponseHeader("Content-Length")

        if (Size = "") {
            ; ไม่ทราบขนาด ดาวน์โหลดแบบปกติ
            URLDownloadToFile, %URL%, %Dest%
            GuiControl,, %ProgressControl%, 100
            GuiControl,, %PercentControl%, 100`%
            Return
        }

        ; รับข้อมูลแบบ chunk
        adoStream := ComObjCreate("ADODB.Stream")
        adoStream.Type := 1  ; Binary
        adoStream.Open()
        adoStream.Write(whr.ResponseBody)
        adoStream.SaveToFile(Dest, 2)
        adoStream.Close()

        GuiControl,, %ProgressControl%, 100
        GuiControl,, %PercentControl%, 100`%

    } catch {
        ; Fallback ไปใช้ URLDownloadToFile
        URLDownloadToFile, %URL%, %Dest%
        GuiControl,, %ProgressControl%, 100
        GuiControl,, %PercentControl%, 100`%
    }
}

; เปรียบเทียบเวอร์ชัน (return true ถ้า v1 > v2)
CompareVersions(v1, v2) {
    StringSplit, parts1, v1, .
    StringSplit, parts2, v2, .

    Loop, 3 {
        p1 := parts1%A_Index% ? parts1%A_Index% : 0
        p2 := parts2%A_Index% ? parts2%A_Index% : 0

        if (p1 > p2)
            Return true
        if (p1 < p2)
            Return false
    }
    Return false
}

; เปิดหน้า GitHub
OpenGitHub:
    global GitHubUser, GitHubRepo
    URL := "https://github.com/" . GitHubUser . "/" . GitHubRepo
    Run, %URL%
Return

; แสดงเกี่ยวกับโปรแกรม
ShowAbout:
    Gui, About:New, +OwnerMain, เกี่ยวกับ %AppName%
    Gui, About:Font, s10, Segoe UI
    Gui, About:Add, Picture, x10 y10 w64 h64, shell32.dll|-145
    Gui, About:Add, Text, x84 y10 w200 h30, %AppName%
    Gui, About:Font, s8
    Gui, About:Add, Text, x84 y35 w200 h20, เวอร์ชัน %AppVersion%
    Gui, About:Add, Text, x10 y90 w290 h60, โปรแกรมตัวอย่างสำหรับสาธิตการสร้าง GUI และระบบอัพเดทอัตโนมัติผ่าน GitHub ใน AutoHotkey v1.1
    Gui, About:Add, Button, x100 y160 w100 h30 gAboutOK, ตกลง
    Gui, About:Show, w300 h200
Return

AboutOK:
AboutGuiClose:
    Gui, About:Destroy
Return

; เปิดตั้งค่า
OpenSettings:
    Gui, Settings:New, +OwnerMain, ตั้งค่า
    Gui, Settings:Font, s10, Segoe UI
    Gui, Settings:Add, GroupBox, x10 y10 w280 h120, การอัพเดท
    Gui, Settings:Add, CheckBox, x20 y30 w260 h20 vAutoCheck, ตรวจสอบอัพเดทอัตโนมัติเมื่อเปิดโปรแกรม
    Gui, Settings:Add, CheckBox, x20 y50 w260 h20 vSilentUpdate, อัพเดทแบบเงียบ (ไม่แจ้งเตือน)
    Gui, Settings:Add, CheckBox, x20 y70 w260 h20 vBetaChannel, รับเวอร์ชัน Beta
    Gui, Settings:Add, Text, x20 y100 w100 h20, ตรวจสอบทุก:
    Gui, Settings:Add, DropDownList, x120 y100 w100 vCheckInterval, เปิดโปรแกรม|ทุกวัน|ทุกสัปดาห์|ทุกเดือน

    Gui, Settings:Add, GroupBox, x10 y140 w280 h80, ทั่วไป
    Gui, Settings:Add, CheckBox, x20 y160 w260 h20 vStartWithWindows, เปิดโปรแกรมพร้อม Windows
    Gui, Settings:Add, CheckBox, x20 y180 w260 h20 vMinimizeToTray, ย่อเก็บไปที่ Tray
    Gui, Settings:Add, Button, x50 y230 w100 h30 gSettingsSave, บันทึก
    Gui, Settings:Add, Button, x160 y230 w100 h30 gSettingsCancel, ยกเลิก
    Gui, Settings:Show, w300 h270
Return

SettingsSave:
    Gui, Settings:Submit
    MsgBox, 64, บันทึกสำเร็จ, บันทึกการตั้งค่าเรียบร้อยแล้ว
    Gui, Settings:Destroy
Return

SettingsCancel:
SettingsGuiClose:
    Gui, Settings:Destroy
Return

; ทดสอบฟีเจอร์
RunDemo:
    Gui, Demo:New, +OwnerMain, ทดสอบฟีเจอร์
    Gui, Demo:Font, s10, Segoe UI
    Gui, Demo:Add, Text, x10 y10 w280 h40, นี่คือหน้าต่างทดสอบฟีเจอร์ต่างๆ ของโปรแกรม
    Gui, Demo:Add, Button, x10 y60 w135 h30 gDemoMsgBox, แสดง MsgBox
    Gui, Demo:Add, Button, x155 y60 w135 h30 gDemoInput, รับ Input
    Gui, Demo:Add, Button, x10 y100 w135 h30 gDemoProgress, แสดง Progress
    Gui, Demo:Add, Button, x155 y100 w135 h30 gDemoNotify, แสดง Notification
    Gui, Demo:Add, Button, x10 y140 w280 h30 gDemoGuiClose, ปิด
    Gui, Demo:Show, w300 h180
Return

DemoMsgBox:
    MsgBox, 64, ทดสอบ, นี่คือ MessageBox ตัวอย่าง!
Return

DemoInput:
    InputBox, UserInput, ทดสอบ Input, กรุณากรอกข้อความ:
    if (ErrorLevel = 0)
        MsgBox, 64, ข้อมูลที่กรอก, คุณกรอก: %UserInput%
Return

DemoProgress:
    Progress, b w200, 0, กำลังประมวลผล...
    Loop, 100 {
        Progress, %A_Index%
        Sleep, 30
    }
    Progress, Off
Return

DemoNotify:
    TrayTip, %AppName%, นี่คือ Notification ตัวอย่าง!, 3, 1
Return

DemoGuiClose:
    Gui, Demo:Destroy
Return

; แสดง Log
ShowLog:
    Gui, Log:New, +OwnerMain +Resize, Log โปรแกรม
    Gui, Log:Font, s9, Consolas
    Gui, Log:Add, Edit, x10 y10 w380 h220 vLogEdit ReadOnly Multi,
        . [%A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%] โปรแกรมเริ่มทำงาน`n
        . [%A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%] โหลดการตั้งค่าเรียบร้อย`n
        . [%A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%] สร้าง GUI หลักเรียบร้อย`n
        . [%A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%] เริ่มต้วกรองข้อมูลระบบ`n
    Gui, Log:Add, Button, x10 y240 w100 h25 gLogClear, ล้าง Log
    Gui, Log:Add, Button, x290 y240 w100 h25 gLogClose, ปิด
    Gui, Log:Show, w400 h280
Return

LogClear:
    GuiControl,, LogEdit,
Return

LogClose:
LogGuiClose:
    Gui, Log:Destroy
Return

RestartApp:
    Reload
Return

ExitApp:
    ExitApp
Return

; ============================================================
; Helper Functions
; ============================================================

GetCPUUsage() {
    static PIT := 0, PKT := 0, PUT := 0

    DllCall("GetSystemTimes", "Int64P", IT, "Int64P", KT, "Int64P", UT)

    if (PIT != 0) {
        DIT := IT - PIT
        DKT := KT - PKT
        DUT := UT - PUT
        Usage := 100 * (1 - (DIT - DKT - DUT) / DIT)
        Usage := Usage < 0 ? 0 : Usage > 100 ? 100 : Usage
    } else {
        Usage := 0
    }

    PIT := IT, PKT := KT, PUT := UT
    Return Round(Usage)
}

GetMemoryUsage() {
    VarSetCapacity(MEMORYSTATUSEX, 64)
    NumPut(64, MEMORYSTATUSEX)
    DllCall("GlobalMemoryStatusEx", "Ptr", &MEMORYSTATUSEX)
    Return Round(NumGet(MEMORYSTATUSEX, 4, "UInt"))
}

; ============================================================
; Auto-Execute Section End
; ============================================================

; ตรวจสอบอัพเดทเมื่อเปิดโปรแกรม (ถ้าเปิดใช้งาน)
; Gosub, CheckUpdate  ; เอา comment ออกถ้าต้องการตรวจสอบอัตโนมัติ
