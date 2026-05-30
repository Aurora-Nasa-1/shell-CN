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
        icon: "cable"
        title: I18n.tr("Ethernet settings")
    }

    StyledText {
        Layout.topMargin: Tokens.spacing.large
        text: I18n.tr("Ethernet devices")
        font.pointSize: Tokens.font.size.larger
        font.weight: 500
    }

    StyledText {
        text: I18n.tr("Available ethernet devices")
        color: Colours.palette.m3outline
    }

    StyledRect {
        Layout.fillWidth: true
        implicitHeight: ethernetInfo.implicitHeight + Tokens.padding.large * 2

        radius: Tokens.rounding.normal
        color: Colours.tPalette.m3surfaceContainer

        ColumnLayout {
            id: ethernetInfo

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.large

            spacing: Tokens.spacing.small / 2

            StyledText {
                text: I18n.tr("Total devices")
            }

            StyledText {
                text: I18n.tr("%1").arg(Nmcli.ethernetDevices.length)
                color: Colours.palette.m3outline
                font.pointSize: Tokens.font.size.small
            }

            StyledText {
                Layout.topMargin: Tokens.spacing.normal
                text: I18n.tr("Connected devices")
            }

            StyledText {
                text: I18n.tr("%1").arg(Nmcli.ethernetDevices.filter(d => d.connected).length)
                color: Colours.palette.m3outline
                font.pointSize: Tokens.font.size.small
            }
        }
    }
}
