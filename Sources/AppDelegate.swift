import Cocoa
import SwiftUI
import Carbon

/// 应用代理 - 管理菜单栏和应用生命周期
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var statusBarController: StatusBarController?
    private let configManager = ConfigManager.shared
    private let fileOrganizer = FileOrganizer()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 先设置 Dock 图标（必须在 setActivationPolicy 之前）
        setupDockIcon()
        
        // 设为常规应用（显示 Dock 图标）
        NSApp.setActivationPolicy(.regular)
        
        // 初始化状态栏
        statusBarController = StatusBarController()
        
        // 启动保存的文件夹监控
        startSavedMonitors()
        
        // 注册快捷键
        setupHotkeys()
        
        // 安装事件处理器
        installHotkeyEventHandler()
        
        print("Quick Folders 启动完成")
    }
    
    private func setupDockIcon() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let iconPath = appSupport.appendingPathComponent("QuickFolders/AppIcon.png").path
        
        if let icon = NSImage(contentsOfFile: iconPath) {
            icon.size = NSSize(width: 128, height: 128)
            NSApp.applicationIconImage = icon
            print("Dock 图标已设置: \(iconPath)")
        } else {
            print("无法加载 Dock 图标: \(iconPath)")
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // 停止监控
        FolderMonitor.shared.stopAll()
        
        // 注销快捷键
        HotkeyManager.shared.unregisterAll()
        
        // 保存配置
        configManager.save()
        print("Quick Folders 退出")
    }
    
    // MARK: - 启动监控
    
    private func startSavedMonitors() {
        for monitor in configManager.monitors where monitor.isActive {
            FolderMonitor.shared.startMonitoring(config: monitor)
        }
    }
    
    // MARK: - 快捷键
    
    private func setupHotkeys() {
        // 设置动作处理器
        HotkeyManager.shared.setActionHandler { [weak self] action in
            self?.handleHotkeyAction(action)
        }
        
        // 加载快捷键配置
        let configs = configManager.hotkeys.isEmpty ? HotkeyConfig.defaultHotkeys : configManager.hotkeys
        HotkeyManager.shared.registerAll(configs: configs)
    }
    
    private func handleHotkeyAction(_ action: HotkeyAction) {
        switch action {
        case .organizeCurrentFolder:
            statusBarController?.organizeFromHotkey()
        case .previewOrganize:
            statusBarController?.previewFromHotkey()
        case .showMainWindow:
            statusBarController?.showMainWindowFromHotkey()
        case .showSettings:
            statusBarController?.openSettingsFromHotkey()
        }
    }
    
    // MARK: - Carbon 事件处理
    
    private func installHotkeyEventHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, event, userData) -> OSStatus in
                var hotKeyID = EventHotKeyID()
                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                
                HotkeyManager.shared.handleHotKeyEvent(id: hotKeyID.id)
                
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )
    }
}
