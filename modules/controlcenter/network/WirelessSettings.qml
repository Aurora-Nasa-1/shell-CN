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
        icon: "wifi"
        title: I18n.tr("Network settings")
    }

    SectionHeader {
        Layout.topMargin: Tokens.spacing.large
        title: I18n.tr("WiFi status")
        description: I18n.tr("General WiFi settings")
    }

    SectionContainer {
        ToggleRow {
            label: I18n.tr("WiFi enabled")
            checked: Nmcli.wifiEnabled
            toggle.onToggled: {
                Nmcli.enableWifi(checked);
            }
        }
    }

    SectionHeader {
        Layout.topMargin: Tokens.spacing.large
        title: I18n.tr("Network information")
        description: I18n.tr("Current network connection")
    }

    SectionContainer {
        contentSpacing: Tokens.spacing.small / 2

        PropertyRow {
            label: I18n.tr("Connected network")
            value: Nmcli.active ? Nmcli.active.ssid : I18n.tr("Not connected")
        }

        PropertyRow {
            showTopMargin: true
            label: I18n.tr("Signal strength")
            value: Nmcli.active ? I18n.tr("%1%").arg(Nmcli.active.strength) : I18n.tr("N/A")
        }

        PropertyRow {
            showTopMargin: true
            label: I18n.tr("Security")
            value: Nmcli.active ? (Nmcli.active.isSecure ? I18n.tr("Secured") : I18n.tr("Open")) : I18n.tr("N/A")
        }

        PropertyRow {
            showTopMargin: true
            label: I18n.tr("Frequency")
            value: Nmcli.active ? I18n.tr("%1 MHz").arg(Nmcli.active.frequency) : I18n.tr("N/A")
        }
    }
}
