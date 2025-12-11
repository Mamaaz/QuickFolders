import SwiftUI

/// Quick Folders - macOS 菜单栏文件整理工具
/// Swift 版本 v1.0
@main
struct QuickFoldersApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // 菜单栏应用使用 Settings 场景显示设置窗口
        SwiftUI.Settings {
            SettingsView()
        }
    }
}
