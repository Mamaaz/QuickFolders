import Cocoa
import SwiftUI

/// 状态栏控制器 - 管理菜单栏图标和菜单
class StatusBarController {
    
    private var statusItem: NSStatusItem
    private let configManager = ConfigManager.shared
    private let fileOrganizer = FileOrganizer()
    
    init() {
        // 创建状态栏项目
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // 设置图标
        if let button = statusItem.button {
            // 从应用支持目录加载图标
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let iconPath = appSupport.appendingPathComponent("QuickFolders/menubar_icon.png").path
            
            if let icon = NSImage(contentsOfFile: iconPath) {
                icon.size = NSSize(width: 18, height: 18)
                // 不使用 template 模式，保留原色
                button.image = icon
            } else {
                // 回退到系统图标
                button.image = NSImage(systemSymbolName: "folder.fill", accessibilityDescription: "Quick Folders")
                button.image?.isTemplate = true
            }
        }
        
        // 构建菜单
        setupMenu()
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        // ========== 收藏夹 ==========
        let favoritesHeader = NSMenuItem(title: "收藏夹", action: nil, keyEquivalent: "")
        menu.addItem(favoritesHeader)
        menu.addItem(NSMenuItem.separator())
        
        // 添加收藏夹项目（每个有子菜单）
        for favorite in configManager.favorites {
            let favMenu = NSMenuItem(title: favorite.name, action: nil, keyEquivalent: "")
            let favSubmenu = NSMenu()
            
            // 打开
            let openItem = NSMenuItem(title: "打开", action: #selector(openFavorite(_:)), keyEquivalent: "")
            openItem.representedObject = favorite.path
            openItem.target = self
            favSubmenu.addItem(openItem)
            
            // 删除
            let deleteItem = NSMenuItem(title: "删除", action: #selector(deleteFavorite(_:)), keyEquivalent: "")
            deleteItem.representedObject = favorite.id
            deleteItem.target = self
            favSubmenu.addItem(deleteItem)
            
            favMenu.submenu = favSubmenu
            menu.addItem(favMenu)
        }
        
        if configManager.favorites.isEmpty {
            let emptyItem = NSMenuItem(title: "   (无收藏)", action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            menu.addItem(emptyItem)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // 添加当前文件夹到收藏
        let addFavoriteItem = NSMenuItem(title: "添加当前文件夹", action: #selector(addCurrentFolderToFavorites), keyEquivalent: "")
        addFavoriteItem.target = self
        menu.addItem(addFavoriteItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // ========== 文件整理 ==========
        let organizeMenu = NSMenuItem(title: "文件整理", action: nil, keyEquivalent: "")
        let organizeSubmenu = NSMenu()
        
        let organizeItem = NSMenuItem(title: "开始整理", action: #selector(organizeCurrentFolder), keyEquivalent: "")
        organizeItem.target = self
        organizeSubmenu.addItem(organizeItem)
        
        let previewItem = NSMenuItem(title: "预览整理", action: #selector(previewOrganize), keyEquivalent: "")
        previewItem.target = self
        organizeSubmenu.addItem(previewItem)
        
        organizeSubmenu.addItem(NSMenuItem.separator())
        
        // 撤销
        let undoItem = NSMenuItem(title: "撤销上次整理", action: #selector(undoLastOrganize), keyEquivalent: "")
        undoItem.target = self
        organizeSubmenu.addItem(undoItem)
        
        organizeSubmenu.addItem(NSMenuItem.separator())
        
        // 整理模式
        let modeMenu = NSMenuItem(title: "整理模式", action: nil, keyEquivalent: "")
        let modeSubmenu = NSMenu()
        
        for mode in OrganizeMode.allCases {
            let item = NSMenuItem(title: mode.displayName, action: #selector(setOrganizeMode(_:)), keyEquivalent: "")
            item.representedObject = mode
            item.target = self
            if mode == configManager.settings.organizeMode {
                item.state = .on
            }
            modeSubmenu.addItem(item)
        }
        modeMenu.submenu = modeSubmenu
        organizeSubmenu.addItem(modeMenu)
        
        organizeMenu.submenu = organizeSubmenu
        menu.addItem(organizeMenu)
        
        menu.addItem(NSMenuItem.separator())
        
        // ========== 显示主窗口 (用小猫图标) ==========
        let showMainItem = NSMenuItem(title: "🐱 显示Dundun", action: #selector(showMainWindow), keyEquivalent: "")
        showMainItem.target = self
        menu.addItem(showMainItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // ========== 设置 ==========
        let settingsItem = NSMenuItem(title: "设置...", action: #selector(openSettings), keyEquivalent: "")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // ========== 退出 ==========
        menu.addItem(NSMenuItem(title: "退出 Quick Folders", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    // MARK: - Actions
    
    @objc private func openFavorite(_ sender: NSMenuItem) {
        guard let path = sender.representedObject as? String else { return }
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
    }
    
    @objc private func deleteFavorite(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? UUID else { return }
        configManager.removeFavorite(id: id)
        setupMenu() // 刷新菜单
    }
    
    @objc private func organizeCurrentFolder() {
        guard let folderPath = getCurrentFinderFolder() else {
            showAlert(title: "提示", message: "请先在 Finder 中打开要整理的文件夹")
            return
        }
        
        let result = fileOrganizer.organize(folderPath: folderPath)
        showAlert(title: "整理完成", message: "成功移动 \(result.success) 个文件")
    }
    
    @objc private func previewOrganize() {
        guard let folderPath = getCurrentFinderFolder() else {
            showAlert(title: "提示", message: "请先在 Finder 中打开要整理的文件夹")
            return
        }
        
        let preview = fileOrganizer.preview(folderPath: folderPath)
        var message = "共 \(preview.totalFiles) 个文件:\n"
        for (category, count) in preview.categories {
            message += "\n\(category): \(count) 个"
        }
        showAlert(title: "预览整理", message: message)
    }
    
    @objc private func setOrganizeMode(_ sender: NSMenuItem) {
        guard let mode = sender.representedObject as? OrganizeMode else { return }
        configManager.settings.organizeMode = mode
        configManager.save()
        setupMenu() // 刷新菜单
    }
    
    @objc private func addCurrentFolderToFavorites() {
        guard let folderPath = getCurrentFinderFolder() else {
            showAlert(title: "提示", message: "请先在 Finder 中打开要添加的文件夹")
            return
        }
        
        let defaultName = (folderPath as NSString).lastPathComponent
        
        // 弹出输入框让用户自定义名称
        let alert = NSAlert()
        alert.messageText = "添加到收藏夹"
        alert.informativeText = "请输入收藏夹名称:"
        alert.addButton(withTitle: "添加")
        alert.addButton(withTitle: "取消")
        
        let inputField = NSTextField(frame: NSRect(x: 0, y: 0, width: 250, height: 24))
        inputField.stringValue = defaultName
        alert.accessoryView = inputField
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let name = inputField.stringValue.isEmpty ? defaultName : inputField.stringValue
            configManager.addFavorite(name: name, path: folderPath)
            setupMenu() // 刷新菜单
        }
    }
    
    @objc private func undoLastOrganize() {
        let undoCount = fileOrganizer.undo()
        if undoCount > 0 {
            showAlert(title: "撤销成功", message: "已恢复 \(undoCount) 个文件")
        } else {
            showAlert(title: "无法撤销", message: "没有可撤销的操作")
        }
    }
    
    @objc private func openSettings() {
        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Quick Folders 设置"
        window.styleMask = [.titled, .closable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.setContentSize(NSSize(width: 550, height: 450))
        window.center()
        
        // 添加毛玻璃背景
        let visualEffect = NSVisualEffectView()
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.material = .hudWindow
        window.contentView = visualEffect
        visualEffect.addSubview(hostingController.view)
        hostingController.view.frame = visualEffect.bounds
        hostingController.view.autoresizingMask = [.width, .height]
        
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        
        // 保持窗口引用
        settingsWindow = window
    }
    
    private var settingsWindow: NSWindow?
    private var mainWindow: NSWindow?
    
    @objc private func showMainWindow() {
        let mainView = MainWindowView()
        let hostingController = NSHostingController(rootView: mainView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Quick Folders"
        window.styleMask = [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.setContentSize(NSSize(width: 480, height: 450))
        window.minSize = NSSize(width: 400, height: 300)
        window.center()
        
        // 添加毛玻璃背景
        let visualEffect = NSVisualEffectView()
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.material = .hudWindow
        window.contentView = visualEffect
        visualEffect.addSubview(hostingController.view)
        hostingController.view.frame = visualEffect.bounds
        hostingController.view.autoresizingMask = [.width, .height]
        
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        
        // 保持窗口引用
        mainWindow = window
    }
    
    // MARK: - Helpers
    
    private func getCurrentFinderFolder() -> String? {
        let script = """
        tell application "Finder"
            if (count of windows) > 0 then
                set currentFolder to target of front window as alias
                return POSIX path of currentFolder
            else
                return ""
            end if
        end tell
        """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            let output = scriptObject.executeAndReturnError(&error)
            if let path = output.stringValue, !path.isEmpty {
                return path
            }
        }
        return nil
    }
    
    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }
    
    // MARK: - 快捷键触发的公开方法
    
    func organizeFromHotkey() {
        organizeCurrentFolder()
    }
    
    func previewFromHotkey() {
        previewOrganize()
    }
    
    func showMainWindowFromHotkey() {
        showMainWindow()
    }
    
    func openSettingsFromHotkey() {
        openSettings()
    }
}
