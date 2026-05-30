pragma ComponentBehavior: Bound

import ".."
import "../components"
import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.components.effects
import qs.services
import qs.utils

ColumnLayout {
    id: root

    required property Session session

    spacing: Tokens.spacing.normal

    SettingsHeader {
        icon: "apps"
        title: I18n.tr("Launcher Settings")
    }

    SectionHeader {
        Layout.topMargin: Tokens.spacing.large
        title: I18n.tr("General")
        description: I18n.tr("General launcher settings")
    }

    SectionContainer {
        ToggleRow {
            label: I18n.tr("Enabled")
            checked: Config.launcher.enabled
            toggle.onToggled: {
                GlobalConfig.launcher.enabled = checked;
            }
        }

        ToggleRow {
            label: I18n.tr("Show on hover")
            checked: Config.launcher.showOnHover
            toggle.onToggled: {
                GlobalConfig.launcher.showOnHover = checked;
            }
        }

        ToggleRow {
            label: I18n.tr("Vim keybinds")
            checked: GlobalConfig.launcher.vimKeybinds
            toggle.onToggled: {
                GlobalConfig.launcher.vimKeybinds = checked;
            }
        }

        ToggleRow {
            label: I18n.tr("Enable dangerous actions")
            checked: GlobalConfig.launcher.enableDangerousActions
            toggle.onToggled: {
                GlobalConfig.launcher.enableDangerousActions = checked;
            }
        }
    }

    SectionHeader {
        Layout.topMargin: Tokens.spacing.large
        title: I18n.tr("Display")
        description: I18n.tr("Display and appearance settings")
    }

    SectionContainer {
        contentSpacing: Tokens.spacing.small / 2

        PropertyRow {
            label: I18n.tr("Max shown items")
            value: I18n.tr("%1").arg(Config.launcher.maxShown)
        }

        PropertyRow {
            showTopMargin: true
            label: I18n.tr("Max wallpapers")
            value: I18n.tr("%1").arg(Config.launcher.maxWallpapers)
        }

        PropertyRow {
            showTopMargin: true
            label: I18n.tr("Drag threshold")
            value: I18n.tr("%1 px").arg(Config.launcher.dragThreshold)
        }
    }

    SectionHeader {
        Layout.topMargin: Tokens.spacing.large
        title: I18n.tr("Prefixes")
        description: I18n.tr("Command prefix settings")
    }

    SectionContainer {
        contentSpacing: Tokens.spacing.small / 2

        PropertyRow {
            label: I18n.tr("Special prefix")
            value: GlobalConfig.launcher.specialPrefix || I18n.tr("None")
        }

        PropertyRow {
            showTopMargin: true
            label: I18n.tr("Action prefix")
            value: GlobalConfig.launcher.actionPrefix || I18n.tr("None")
        }
    }

    SectionHeader {
        Layout.topMargin: Tokens.spacing.large
        title: I18n.tr("Fuzzy search")
        description: I18n.tr("Fuzzy search settings")
    }

    SectionContainer {
        ToggleRow {
            label: I18n.tr("Apps")
            checked: GlobalConfig.launcher.useFuzzy.apps
            toggle.onToggled: {
                GlobalConfig.launcher.useFuzzy.apps = checked;
            }
        }

        ToggleRow {
            label: I18n.tr("Actions")
            checked: GlobalConfig.launcher.useFuzzy.actions
            toggle.onToggled: {
                GlobalConfig.launcher.useFuzzy.actions = checked;
            }
        }

        ToggleRow {
            label: I18n.tr("Schemes")
            checked: GlobalConfig.launcher.useFuzzy.schemes
            toggle.onToggled: {
                GlobalConfig.launcher.useFuzzy.schemes = checked;
            }
        }

        ToggleRow {
            label: I18n.tr("Variants")
            checked: GlobalConfig.launcher.useFuzzy.variants
            toggle.onToggled: {
                GlobalConfig.launcher.useFuzzy.variants = checked;
            }
        }

        ToggleRow {
            label: I18n.tr("Wallpapers")
            checked: GlobalConfig.launcher.useFuzzy.wallpapers
            toggle.onToggled: {
                GlobalConfig.launcher.useFuzzy.wallpapers = checked;
            }
        }
    }

    SectionHeader {
        Layout.topMargin: Tokens.spacing.large
        title: I18n.tr("Sizes")
        description: I18n.tr("Size settings for launcher items")
    }

    SectionContainer {
        contentSpacing: Tokens.spacing.small / 2

        PropertyRow {
            label: I18n.tr("Item width")
            value: I18n.tr("%1 px").arg(Tokens.sizes.launcher.itemWidth)
        }

        PropertyRow {
            showTopMargin: true
            label: I18n.tr("Item height")
            value: I18n.tr("%1 px").arg(Tokens.sizes.launcher.itemHeight)
        }

        PropertyRow {
            showTopMargin: true
            label: I18n.tr("Wallpaper width")
            value: I18n.tr("%1 px").arg(Tokens.sizes.launcher.wallpaperWidth)
        }

        PropertyRow {
            showTopMargin: true
            label: I18n.tr("Wallpaper height")
            value: I18n.tr("%1 px").arg(Tokens.sizes.launcher.wallpaperHeight)
        }
    }

    SectionHeader {
        Layout.topMargin: Tokens.spacing.large
        title: I18n.tr("Hidden apps")
        description: I18n.tr("Applications hidden from launcher")
    }

    SectionContainer {
        contentSpacing: Tokens.spacing.small / 2

        PropertyRow {
            label: I18n.tr("Total hidden")
            value: I18n.tr("%1").arg(GlobalConfig.launcher.hiddenApps ? GlobalConfig.launcher.hiddenApps.length : 0)
        }
    }
}
