; == 设置加载器 ==

; 从配置文件加载设置
LoadSettings() {
    Config.LoadFromIni()
    State.UpdateDelay()
}
