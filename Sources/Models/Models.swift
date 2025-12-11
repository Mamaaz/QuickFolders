import Foundation

/// 整理模式
enum OrganizeMode: String, Codable, CaseIterable {
    case byExtension = "extension"
    case byDate = "date"
    case bySize = "size"
    
    var displayName: String {
        switch self {
        case .byExtension: return "📁 按类型"
        case .byDate: return "📅 按日期"
        case .bySize: return "📊 按大小"
        }
    }
}

/// 日期格式
enum DateFormat: String, Codable, CaseIterable {
    case yearMonth = "YYYY-MM"
    case yearMonthDay = "YYYY-MM-DD"
    case yearSlashMonth = "YYYY/MM"
    case yearSlashMonthDay = "YYYY/MM/DD"
    
    var formatString: String {
        switch self {
        case .yearMonth: return "yyyy-MM"
        case .yearMonthDay: return "yyyy-MM-dd"
        case .yearSlashMonth: return "yyyy/MM"
        case .yearSlashMonthDay: return "yyyy/MM/dd"
        }
    }
}

/// 大小比较运算符
enum SizeOperator: String, Codable, CaseIterable {
    case lessThan = "<"
    case lessOrEqual = "≤"
    case greaterThan = ">"
    case greaterOrEqual = "≥"
    
    var displayName: String { rawValue }
}

/// 大小单位
enum SizeUnit: String, Codable, CaseIterable {
    case KB = "KB"
    case MB = "MB"
    case GB = "GB"
    
    var bytes: Int64 {
        switch self {
        case .KB: return 1024
        case .MB: return 1024 * 1024
        case .GB: return 1024 * 1024 * 1024
        }
    }
}

/// 大小分类规则（完全自定义）
struct SizeRule: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String           // 分类名称，如 "小文件"
    var op: SizeOperator       // 比较运算符
    var value: Int             // 数值
    var unit: SizeUnit         // 单位
    var priority: Int = 0      // 优先级（越大越先匹配）
    
    /// 检查文件大小是否匹配此规则
    func matches(bytes: Int64) -> Bool {
        let threshold = Int64(value) * unit.bytes
        switch op {
        case .lessThan: return bytes < threshold
        case .lessOrEqual: return bytes <= threshold
        case .greaterThan: return bytes > threshold
        case .greaterOrEqual: return bytes >= threshold
        }
    }
    
    var displayDescription: String {
        "\(op.rawValue) \(value) \(unit.rawValue)"
    }
    
    static var defaultRules: [SizeRule] {
        [
            SizeRule(name: "微小", op: .lessThan, value: 1, unit: .MB, priority: 5),
            SizeRule(name: "小型", op: .lessThan, value: 10, unit: .MB, priority: 4),
            SizeRule(name: "中型", op: .lessThan, value: 100, unit: .MB, priority: 3),
            SizeRule(name: "大型", op: .lessThan, value: 1, unit: .GB, priority: 2),
            SizeRule(name: "超大", op: .greaterOrEqual, value: 1, unit: .GB, priority: 1),
        ]
    }
}

/// 收藏夹
struct Favorite: Codable, Identifiable {
    var id = UUID()
    var name: String
    var path: String
    var group: String?
    
    init(name: String, path: String, group: String? = nil) {
        self.name = name
        self.path = path
        self.group = group
    }
}

/// 应用设置
struct AppSettings: Codable, Equatable {
    var organizeMode: OrganizeMode = .byExtension
    var dateFormat: DateFormat = .yearMonth
    var showNotifications: Bool = true
    var enableUndo: Bool = true
    var useICloud: Bool = false
    var launchAtLogin: Bool = false
}

/// 整理规则
struct OrganizeRule: Codable, Identifiable {
    var id = UUID()
    var category: String
    var extensions: [String]
    var isEnabled: Bool = true
    
    static var defaultRules: [OrganizeRule] {
        [
            OrganizeRule(category: "图片", extensions: ["jpg", "jpeg", "png", "gif", "webp", "heic", "raw", "cr2", "nef"]),
            OrganizeRule(category: "文档", extensions: ["pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "md"]),
            OrganizeRule(category: "视频", extensions: ["mp4", "mov", "avi", "mkv", "wmv", "flv", "webm"]),
            OrganizeRule(category: "音频", extensions: ["mp3", "wav", "flac", "aac", "m4a", "ogg"]),
            OrganizeRule(category: "压缩包", extensions: ["zip", "rar", "7z", "tar", "gz", "dmg"]),
            OrganizeRule(category: "代码", extensions: ["swift", "py", "js", "ts", "html", "css", "json", "xml"]),
        ]
    }
}
