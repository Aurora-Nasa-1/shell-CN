pragma ComponentBehavior: Bound

import ".."
import "../components"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.effects
import qs.services
import qs.utils

ColumnLayout {
    id: root

    required property Session session

    spacing: Tokens.spacing.normal

    SettingsHeader {
        icon: "router"
        title: I18n.tr("Network Settings")
    }

    SectionHeader {
        Layout.topMargin: Tokens.spacing.large
        title: I18n.tr("Ethernet")
        description: I18n.tr("Ethernet device information")
    }

    SectionContainer {
        contentSpacing: Tokens.spacing.small / 2

        PropertyRow {
            label: I18n.tr("Total devices")
            value: I18n.tr("%1").arg(Nmcli.ethernetDevices.length)
        }

        PropertyRow {
            showTopMargin: true
            label: I18n.tr("Connected devices")
            value: I18n.tr("%1").arg(Nmcli.ethernetDevices.filter(d => d.connected).length)
        }
    }

    SectionHeader {
        Layout.topMargin: Tokens.spacing.large
        title: I18n.tr("Wireless")
        description: I18n.tr("WiFi network settings")
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
        title: I18n.tr("VPN")
        description: I18n.tr("VPN provider settings")
        visible: GlobalConfig.utilities.vpn.enabled || GlobalConfig.utilities.vpn.provider.length > 0
    }

    SectionContainer {
        visible: GlobalConfig.utilities.vpn.enabled || GlobalConfig.utilities.vpn.provider.length > 0

        ToggleRow {
            label: I18n.tr("VPN enabled")
            checked: GlobalConfig.utilities.vpn.enabled
            toggle.onToggled: {
                GlobalConfig.utilities.vpn.enabled = checked;
            }
        }

        PropertyRow {
            showTopMargin: true
            label: I18n.tr("Providers")
            value: I18n.tr("%1").arg(GlobalConfig.utilities.vpn.provider.length)
        }

        TextButton {
            Layout.fillWidth: true
            Layout.topMargin: Tokens.spacing.normal
            Layout.minimumHeight: Tokens.font.size.normal + Tokens.padding.normal * 2
            text: I18n.tr("⚙ Manage VPN Providers")
            inactiveColour: Colours.palette.m3secondaryContainer
            inactiveOnColour: Colours.palette.m3onSecondaryContainer

            onClicked: {
                vpnSettingsDialog.open();
            }
        }
    }

    SectionHeader {
        Layout.topMargin: Tokens.spacing.large
        title: I18n.tr("Current connection")
        description: I18n.tr("Active network connection information")
    }

    SectionContainer {
        contentSpacing: Tokens.spacing.small / 2

        PropertyRow {
            label: I18n.tr("Network")
            value: Nmcli.active ? Nmcli.active.ssid : (Nmcli.activeEthernet ? Nmcli.activeEthernet.interface : I18n.tr("Not connected"))
        }

        PropertyRow {
            showTopMargin: true
            visible: Nmcli.active !== null
            label: I18n.tr("Signal strength")
            value: Nmcli.active ? I18n.tr("%1%").arg(Nmcli.active.strength) : I18n.tr("N/A")
        }

        PropertyRow {
            showTopMargin: true
            visible: Nmcli.active !== null
            label: I18n.tr("Security")
            value: Nmcli.active ? (Nmcli.active.isSecure ? I18n.tr("Secured") : I18n.tr("Open")) : I18n.tr("N/A")
        }

        PropertyRow {
            showTopMargin: true
            visible: Nmcli.active !== null
            label: I18n.tr("Frequency")
            value: Nmcli.active ? I18n.tr("%1 MHz").arg(Nmcli.active.frequency) : I18n.tr("N/A")
        }
    }

    Popup {
        id: vpnSettingsDialog

        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min(600, parent.width - Tokens.padding.large * 2)
        height: Math.min(700, parent.height - Tokens.padding.large * 2)

        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: StyledRect {
            color: Colours.palette.m3surface
            radius: Tokens.rounding.large
        }

        StyledFlickable {
            anchors.fill: parent
            anchors.margins: Tokens.padding.large * 1.5
            flickableDirection: Flickable.VerticalFlick
            contentHeight: vpnSettingsContent.height
            clip: true

            VpnSettings {
                id: vpnSettingsContent

                anchors.left: parent.left
                anchors.right: parent.right
                session: root.session
            }
        }
    }
}
