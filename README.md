# Quick Folders

<p align="center">
  <img src="icons8-folder-400.svg" width="128" height="128" alt="Quick Folders Icon">
</p>

<p align="center">
  <strong>macOS 智能文件整理工具</strong><br>
  自动分类、监控、整理你的文件夹
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2012%2B-blue" alt="Platform">
  <img src="https://img.shields.io/badge/swift-5.9-orange" alt="Swift">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
</p>

---

## ✨ 功能特性

### 📁 智能文件整理
- **按扩展名分类** - 自动将文件按类型归类（文档、图片、视频等）
- **按日期分类** - 按年/月/日组织文件
- **按大小分类** - 自定义大小规则，灵活分类
- **自定义规则** - 创建你自己的分类规则

### 👁 文件夹监控
- 实时监控指定文件夹
- 新文件自动整理
- 支持多个监控目录

### 🔌 插件系统
- JSON 规则模板
- AppleScript 操作支持
- 自动重命名插件（内置）

### ⌨️ 全局快捷键
- 自定义快捷键
- 快速整理当前 Finder 窗口
- 一键预览整理结果

### 🎨 现代 UI
- 毛玻璃透明效果
- 深色/浅色模式自适应
- 拖放操作支持

---

## 📦 安装

### 方式一：DMG 安装（推荐）
1. 从 [Releases](../../releases) 下载最新的 `.dmg` 文件
2. 双击打开 DMG
3. 将 **Quick Folders** 拖入 **Applications** 文件夹
4. 从启动台打开应用

### 方式二：从源码编译
```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/QuickFoldersSwift.git
cd QuickFoldersSwift

# 编译运行
swift run

# 或打包成 DMG
./build.sh
```

---

## 🚀 使用方法

### 基本使用
1. 启动应用，状态栏会出现文件夹图标
2. 在 Finder 中打开要整理的文件夹
3. 点击状态栏图标 → **文件整理** → **开始整理**

### 主窗口
- 点击 **🐱 显示Dundun** 打开主窗口
- 拖放文件夹到窗口中
- 选择整理模式，点击"开始整理全部"

### 收藏夹
- 将常用文件夹添加到收藏夹
- 快速访问和整理

### 文件夹监控
- 设置 → 监控 → 添加监控文件夹
- 新文件会自动整理

---

## ⚙️ 配置

配置文件位于 `~/Library/Application Support/QuickFolders/`

| 文件 | 说明 |
|------|------|
| `settings.json` | 应用设置 |
| `rules.json` | 分类规则 |
| `favorites.json` | 收藏夹 |
| `monitors.json` | 监控配置 |
| `plugins/` | 插件目录 |

---

## 🔌 插件开发

在 `plugins/` 目录下创建插件文件夹，包含 `manifest.json`：

```json
{
  "name": "我的插件",
  "version": "1.0.0",
  "description": "插件描述",
  "type": "rule",
  "triggers": ["beforeMove"],
  "configuration": [
    {
      "key": "enabled",
      "label": "启用",
      "type": "boolean",
      "defaultValue": "true"
    }
  ]
}
```

---

## 📋 系统要求

- macOS 12.0 (Monterey) 或更高版本
- Apple Silicon 或 Intel 处理器

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📄 许可证

MIT License © 2024

---

## 🙏 致谢

- 图标来自 [Icons8](https://icons8.com)
