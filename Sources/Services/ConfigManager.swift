import Foundation

/// 配置管理器 - 单例模式
class ConfigManager {
    
    static let shared = ConfigManager()
    
    // 配置目录
    private let configDir: URL
    private let settingsFile: URL
    private let favoritesFile: URL
    private let rulesFile: URL
    private let sizeRulesFile: URL
    private let monitorsFile: URL
    private let hotkeysFile: URL
    private let renameRulesFile: URL
    
    // 数据
    var settings: AppSettings
    var favorites: [Favorite]
    var rules: [OrganizeRule]
    var sizeRules: [SizeRule]
    var monitors: [MonitorConfig]
    var hotkeys: [HotkeyConfig]
    var renameRules: [RenameRule]
    
    private init() {
        // 配置目录: ~/Library/Application Support/QuickFolders/
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        configDir = appSupport.appendingPathComponent("QuickFolders")
        
        settingsFile = configDir.appendingPathComponent("settings.json")
        favoritesFile = configDir.appendingPathComponent("favorites.json")
        rulesFile = configDir.appendingPathComponent("rules.json")
        sizeRulesFile = configDir.appendingPathComponent("size_rules.json")
        monitorsFile = configDir.appendingPathComponent("monitors.json")
        hotkeysFile = configDir.appendingPathComponent("hotkeys.json")
        renameRulesFile = configDir.appendingPathComponent("rename_rules.json")
        
        // 确保目录存在
        try? FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)
        
        // 加载配置
        settings = Self.load(from: settingsFile) ?? AppSettings()
        favorites = Self.load(from: favoritesFile) ?? []
        rules = Self.load(from: rulesFile) ?? OrganizeRule.defaultRules
        sizeRules = Self.load(from: sizeRulesFile) ?? SizeRule.defaultRules
        monitors = Self.load(from: monitorsFile) ?? []
        hotkeys = Self.load(from: hotkeysFile) ?? HotkeyConfig.defaultHotkeys
        renameRules = Self.load(from: renameRulesFile) ?? RenameRule.defaultRules
    }
    
    // MARK: - 加载/保存
    
    private static func load<T: Codable>(from url: URL) -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    func save() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if let data = try? encoder.encode(settings) {
            try? data.write(to: settingsFile)
        }
        if let data = try? encoder.encode(favorites) {
            try? data.write(to: favoritesFile)
        }
        if let data = try? encoder.encode(rules) {
            try? data.write(to: rulesFile)
        }
        if let data = try? encoder.encode(sizeRules) {
            try? data.write(to: sizeRulesFile)
        }
        if let data = try? encoder.encode(monitors) {
            try? data.write(to: monitorsFile)
        }
        if let data = try? encoder.encode(hotkeys) {
            try? data.write(to: hotkeysFile)
        }
        if let data = try? encoder.encode(renameRules) {
            try? data.write(to: renameRulesFile)
        }
    }
    
    // MARK: - 收藏夹管理
    
    func addFavorite(name: String, path: String, group: String? = nil) {
        let favorite = Favorite(name: name, path: path, group: group)
        favorites.append(favorite)
        save()
    }
    
    func removeFavorite(id: UUID) {
        favorites.removeAll { $0.id == id }
        save()
    }
    
    // MARK: - 规则管理
    
    func getCategoryForExtension(_ ext: String) -> String? {
        let lowercased = ext.lowercased()
        for rule in rules where rule.isEnabled {
            if rule.extensions.contains(lowercased) {
                return rule.category
            }
        }
        return nil
    }
    
    func getCategoryForSize(_ bytes: Int64) -> String {
        // 按优先级排序，优先级高的先匹配
        let sortedRules = sizeRules.sorted { $0.priority > $1.priority }
        for rule in sortedRules {
            if rule.matches(bytes: bytes) {
                return rule.name
            }
        }
        return "其他"
    }
}
