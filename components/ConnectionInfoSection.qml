import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.utils

ColumnLayout {
    id: root

    required property var deviceDetails

    spacing: Tokens.spacing.small / 2

    StyledText {
        text: I18n.tr("IP Address")
    }

    StyledText {
        text: root.deviceDetails?.ipAddress || I18n.tr("Not available")
        color: Colours.palette.m3outline
        font.pointSize: Tokens.font.size.small
    }

    StyledText {
        Layout.topMargin: Tokens.spacing.normal
        text: I18n.tr("Subnet Mask")
    }

    StyledText {
        text: root.deviceDetails?.subnet || I18n.tr("Not available")
        color: Colours.palette.m3outline
        font.pointSize: Tokens.font.size.small
    }

    StyledText {
        Layout.topMargin: Tokens.spacing.normal
        text: I18n.tr("Gateway")
    }

    StyledText {
        text: root.deviceDetails?.gateway || I18n.tr("Not available")
        color: Colours.palette.m3outline
        font.pointSize: Tokens.font.size.small
    }

    StyledText {
        Layout.topMargin: Tokens.spacing.normal
        text: I18n.tr("DNS Servers")
    }

    StyledText {
        text: (root.deviceDetails && root.deviceDetails.dns && root.deviceDetails.dns.length > 0) ? root.deviceDetails.dns.join(", ") : I18n.tr("Not available")
        color: Colours.palette.m3outline
        font.pointSize: Tokens.font.size.small
        wrapMode: Text.Wrap
        Layout.maximumWidth: parent.width
    }
}
