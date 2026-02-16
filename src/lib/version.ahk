; == 版本管理 ==

class Version {
    ; 当前版本号
    static Number := "v1.0.12"
    
    ; 获取版本号
    static Get() {
        return this.Number
    }
}
