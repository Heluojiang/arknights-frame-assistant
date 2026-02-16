; == 更新UI模块 ==

class UpdateUI {
    ; 显示更新提示对话框
    ; params: 包含以下字段的对象
    ;   - localVersion: 当前版本
    ;   - remoteVersion: 远程版本
    ;   - downloadUrl: 下载链接
    ;   - isManual: 是否是手动检查（影响提示内容）
    static ShowUpdateDialog(params) {
        localVersion := params.localVersion
        remoteVersion := params.remoteVersion
        isManual := params.HasProp("isManual") ? params.isManual : false
        
        if (isManual) {
            title := "发现新版本"
            message := "当前版本: " localVersion "`n最新版本: " remoteVersion "`n`n是否立即更新？"
        } else {
            title := "发现新版本"
            message := "检测到新版本可用！`n当前版本: " localVersion "`n最新版本: " remoteVersion "`n`n是否立即更新？`n`n（可在设置中关闭自动检查）"
        }
        
        result := MsgBox(message, title, "Iconi YesNo")
        
        if (result = "Yes") {
            EventBus.Publish("UpdateConfirmed", params)
        } else {
            EventBus.Publish("UpdateDismissed", params)
        }
    }
    
    ; 显示已是最新版本的提示
    static ShowUpToDateDialog(version) {
        MsgBox("当前版本 " version " 已是最新版本。", "无需更新", "Iconi")
    }
    
    ; 显示更新检查失败的提示
    static ShowCheckFailedDialog(message := "") {
        if (message = "") {
            message := "检查更新失败，请检查网络连接后重试。"
        }
        MsgBox(message, "检查失败", "Icon!")
    }
    
    ; 显示正在下载的提示
    static ShowDownloadingDialog() {
        ; 使用进度条窗口或简单提示
        ; 由于AHK的限制，这里使用简单提示
        MsgBox("正在下载更新，请稍候...", "下载中", "Iconi")
    }
    
    ; 显示下载完成的提示
    static ShowDownloadCompleteDialog() {
        MsgBox("下载完成！程序将在重启后应用更新。", "下载完成", "Iconi")
    }
    
    ; 显示下载失败的提示
    static ShowDownloadFailedDialog(message := "") {
        if (message = "") {
            message := "下载更新失败，请检查网络连接后重试。"
        }
        MsgBox(message, "下载失败", "Icon!")
    }
    
    ; 显示自动更新已禁用的提示
    static ShowAutoUpdateDisabledDialog() {
        MsgBox("自动检查更新已禁用。`n如需开启，请在配置文件中设置 AutoUpdate=1", "提示", "Iconi")
    }
}
