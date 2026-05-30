pragma Singleton

import QtQuick
import QtQml.Models

QtObject {
    id: root

    // Set to "zh_CN" for Chinese, "en_US" for English
    // This is initialized from shell.qml on startup
    property string locale: "zh_CN"

    readonly property bool isChinese: locale === "zh_CN" || locale.startsWith("zh")

    // Translation dictionary: English -> Chinese
    // Fallback for missing translations is the English key itself
    readonly property var translations: Object.freeze({
        // PaneRegistry display labels
        "Network": "网络",
        "Bluetooth": "蓝牙",
        "Audio": "音频",
        "Appearance": "外观",
        "Taskbar": "任务栏",
        "Notifications": "通知",
        "Launcher": "启动器",
        "Dashboard": "仪表盘",

        // NavRail
        "Float window": "浮动窗口",

        // Appearance pane
        "Wallpaper": "壁纸",
        "Theme mode": "主题模式",
        "Light or dark theme": "浅色或深色主题",
        "Dark mode": "深色模式",
        "Color variant": "颜色变体",
        "Material theme variant": "Material 主题变体",
        "Color scheme": "配色方案",
        "Available color schemes": "可用配色方案",
        "Animations": "动画",
        "Animation duration scale": "动画时长缩放",
        "Fonts": "字体",
        "Sans-serif font family": "无衬线字体",
        "Monospace font family": "等宽字体",
        "Material font family": "Material 字体",
        "Font size scale": "字体大小缩放",
        "Scales": "缩放",
        "Padding scale": "内边距缩放",
        "Rounding scale": "圆角缩放",
        "Spacing scale": "间距缩放",
        "Transparency": "透明度",
        "Transparency enabled": "启用透明度",
        "Transparency base": "基础透明度",
        "Transparency layers": "图层透明度",
        "Border": "边框",
        "Border rounding": "边框圆角",
        "Border thickness": "边框厚度",
        "Border decoration colour": "边框装饰颜色",
        "Leave empty to use the theme colour": "留空以使用主题颜色",
        "Sidebar background colour": "侧边栏背景颜色",
        "Background": "背景",
        "Background enabled": "启用背景",
        "Wallpaper enabled": "启用壁纸",
        "Desktop Clock": "桌面时钟",
        "Desktop Clock enabled": "启用桌面时钟",
        "Positioning": "位置",
        "Vertical Position": "垂直位置",
        "Top": "顶部",
        "Middle": "居中",
        "Bottom": "底部",
        "Horizontal Position": "水平位置",
        "Left": "左侧",
        "Center": "居中",
        "Right": "右侧",
        "Invert colors": "反转颜色",
        "Shadow": "阴影",
        "Enabled": "启用",
        "Opacity": "不透明度",
        "Blur": "模糊",
        "Blur enabled": "启用模糊",
        "Visualiser": "可视化器",
        "Visualiser enabled": "启用可视化器",
        "Visualiser auto hide": "可视化器自动隐藏",
        "Visualiser rounding": "可视化器圆角",
        "Visualiser spacing": "可视化器间距",

        // Lyrics section
        "Top lyrics bar": "歌词栏",
        "Font size": "字体大小",
        "Update interval": "更新间隔",
        "Enter animation": "进入动画",
        "Enter duration": "进入时长",
        "Exit animation": "退出动画",
        "Exit duration": "退出时长",
        "Font family": "字体",

        // Audio pane
        "Audio Settings": "音频设置",
        "Output volume": "输出音量",
        "Control the volume of your output device": "控制输出设备的音量",
        "Volume": "音量",
        "Input volume": "输入音量",
        "Control the volume of your input device": "控制输入设备的音量",
        "Applications": "应用程序",
        "Control volume for individual applications": "控制各个应用程序的音量",
        "No applications currently playing audio": "当前没有应用程序播放音频",
        "Output devices": "输出设备",
        "Input devices": "输入设备",
        "All available output devices": "所有可用的输出设备",
        "All available input devices": "所有可用的输入设备",
        "Devices (%1)": "设备 (%1)",
        "Unknown": "未知",

        // Network pane
        "Network Settings": "网络设置",
        "Ethernet": "以太网",
        "Ethernet device information": "以太网设备信息",
        "Total devices": "设备总数",
        "Connected devices": "已连接设备",
        "Wireless": "无线网络",
        "WiFi network settings": "WiFi 网络设置",
        "WiFi enabled": "启用 WiFi",
        "VPN": "VPN",
        "VPN provider settings": "VPN 提供商设置",
        "VPN enabled": "启用 VPN",
        "Providers": "提供商",
        "⚙ Manage VPN Providers": "⚙ 管理 VPN 提供商",
        "Current connection": "当前连接",
        "Active network connection information": "活跃网络连接信息",
        "Signal strength": "信号强度",
        "Security": "安全性",
        "Secured": "已加密",
        "Open": "开放",
        "Frequency": "频率",
        "%1 MHz": "%1 MHz",
        "%1%": "%1%",
        "Not connected": "未连接",
        "N/A": "不适用",
        "Toggle WiFi": "切换 WiFi",
        "Scan for networks": "扫描网络",
        "Network settings": "网络设置",
        "Settings": "设置",

        // Bluetooth pane
        "Bluetooth Settings": "蓝牙设置",
        "Adapter status": "适配器状态",
        "General adapter settings": "通用适配器设置",
        "Powered": "已开启",
        "Discoverable": "可发现",
        "Pairable": "可配对",
        "Adapter properties": "适配器属性",
        "Per-adapter settings": "每个适配器的设置",
        "Current adapter": "当前适配器",
        "None": "无",
        "Discoverable timeout": "可发现超时",
        "Rename adapter (currently does not work)": "重命名适配器（目前不可用）",
        "Adapter information": "适配器信息",
        "Information about the default adapter": "默认适配器的信息",
        "Adapter state": "适配器状态",
        "Dbus path": "Dbus 路径",
        "Adapter id": "适配器 ID",

        // Notifications pane
        "Notifications": "通知",
        "Show in fullscreen": "全屏显示",
        "Off": "关闭",
        "On": "开启",
        "Important": "重要",
        "Expire automatically": "自动过期",
        "Open expanded": "默认展开",
        "Default timeout": "默认超时",
        "Group preview count": "组预览数量",
        "Toast settings": "Toast 设置",
        "Visible toasts": "显示 Toast 数",
        "Charging changes": "充电变化",
        "Game mode changes": "游戏模式变化",
        "Do not disturb": "免打扰",
        "Audio output changes": "音频输出变化",
        "Audio input changes": "音频输入变化",
        "Caps lock changes": "大写锁定变化",
        "Num lock changes": "数字锁定变化",
        "Keyboard layout changes": "键盘布局变化",
        "VPN changes": "VPN 变化",
        "Now playing": "正在播放",

        // Taskbar pane
        "Taskbar": "任务栏",
        "Status Icons": "状态图标",
        "Speakers": "扬声器",
        "Microphone": "麦克风",
        "Keyboard": "键盘",
        "Network": "网络",
        "Wifi": "WiFi",
        "Battery": "电池",
        "Capslock": "大写锁定",
        "Workspaces": "工作区",
        "Shown": "显示数量",
        "Active indicator": "活动指示器",
        "Occupied background": "占用背景",
        "Show windows": "显示窗口",
        "Max window icons": "最大窗口图标数",
        "Per monitor workspaces": "每个显示器的工作区",
        "Scroll Actions": "滚轮操作",
        "Brightness": "亮度",
        "Clock": "时钟",
        "Show date": "显示日期",
        "Show clock icon": "显示时钟图标",
        "Bar Behavior": "栏行为",
        "Persistent": "常驻显示",
        "Show on hover": "悬停显示",
        "Drag threshold": "拖拽阈值",
        "Active window": "活动窗口",
        "Compact": "紧凑",
        "Inverted": "反转",
        "Popouts": "弹出窗口",
        "Tray": "托盘",
        "Status icons": "状态图标",
        "Tray Settings": "托盘设置",
        "Recolour": "重新着色",
        "Monitors": "显示器",

        // Dashboard pane
        "General": "通用",
        "Show tabs": "显示标签页",
        "Update intervals": "更新间隔",
        "Resources": "资源",
        "CPU": "CPU",
        "GPU": "GPU",
        "Memory": "内存",
        "Storage": "存储",

        // Dashboard tabs
        "Media": "媒体",
        "Performance": "性能",
        "Weather": "天气",

        // Launcher pane
        "Launcher settings": "启动器设置",
        "Launcher Applications": "启动器应用程序",
        "Applications (%1)": "应用程序 (%1)",
        "All applications available in the launcher": "启动器中可用的所有应用程序",
        "Search applications...": "搜索应用程序...",
        "Mark as favourite": "标记为收藏",
        "Hide from launcher": "从启动器隐藏",
        "Application Details": "应用程序详情",

        // Launcher actions
        "Unnamed": "未命名",
        "No description": "无描述",

        // Notification
        "Close": "关闭"
    })

    // Call this from shell.qml on startup to initialize locale
    function init(localeCode: string): void {
        root.locale = localeCode;
    }

    // Translate a single string
    // Returns the Chinese translation if available, otherwise the original English text
    function tr(text: string): string {
        if (root.isChinese && root.translations.hasOwnProperty(text)) {
            return root.translations[text];
        }
        // Fallback: return original English text (via qsTr)
        return qsTr(text);
    }

    // Translate with argument substitution
    // Example: I18n.trArgs("Devices (%1)", 5) -> "设备 (5)"
    function trArgs(text: string): string {
        var translated = root.tr(text);
        if (!root.isChinese || !root.translations.hasOwnProperty(text)) {
            translated = qsTr(text);
        }
        for (var i = 1; i < arguments.length; i++) {
            translated = translated.replace("%" + i, arguments[i]);
        }
        return translated;
    }
}
