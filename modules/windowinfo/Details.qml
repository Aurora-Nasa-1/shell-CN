import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Caelestia.Config
import qs.components
import qs.services
import qs.utils

ColumnLayout {
    id: root

    required property HyprlandToplevel client

    anchors.fill: parent
    spacing: Tokens.spacing.small

    Label {
        Layout.topMargin: Tokens.padding.large * 2

        text: root.client?.title ?? I18n.tr("No active client")
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

        font.pointSize: Tokens.font.size.large
        font.weight: 500
    }

    Label {
        text: root.client?.lastIpcObject.class ?? I18n.tr("No active client")
        color: Colours.palette.m3tertiary

        font.pointSize: Tokens.font.size.larger
    }

    StyledRect {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        Layout.leftMargin: Tokens.padding.large * 2
        Layout.rightMargin: Tokens.padding.large * 2
        Layout.topMargin: Tokens.spacing.normal
        Layout.bottomMargin: Tokens.spacing.large

        color: Colours.palette.m3secondary
    }

    Detail {
        icon: "location_on"
        text: I18n.tr("Address: %1").arg(`0x${root.client?.address}` ?? "unknown")
        color: Colours.palette.m3primary
    }

    Detail {
        icon: "location_searching"
        text: I18n.tr("Position: %1, %2").arg(root.client?.lastIpcObject.at[0] ?? -1).arg(root.client?.lastIpcObject.at[1] ?? -1)
    }

    Detail {
        icon: "resize"
        text: I18n.tr("Size: %1 x %2").arg(root.client?.lastIpcObject.size[0] ?? -1).arg(root.client?.lastIpcObject.size[1] ?? -1)
        color: Colours.palette.m3tertiary
    }

    Detail {
        icon: "workspaces"
        text: I18n.tr("Workspace: %1 (%2)").arg(root.client?.workspace.name ?? -1).arg(root.client?.workspace.id ?? -1)
        color: Colours.palette.m3secondary
    }

    Detail {
        icon: "desktop_windows"
        text: {
            const mon = root.client?.monitor;
            if (mon)
                return I18n.tr("Monitor: %1 (%2) at %3, %4").arg(mon.name).arg(mon.id).arg(mon.x).arg(mon.y);
            return I18n.tr("Monitor: unknown");
        }
    }

    Detail {
        icon: "page_header"
        text: I18n.tr("Initial title: %1").arg(root.client?.lastIpcObject.initialTitle ?? "unknown")
        color: Colours.palette.m3tertiary
    }

    Detail {
        icon: "category"
        text: I18n.tr("Initial class: %1").arg(root.client?.lastIpcObject.initialClass ?? "unknown")
    }

    Detail {
        icon: "account_tree"
        text: I18n.tr("Process id: %1").arg(root.client?.lastIpcObject.pid ?? -1)
        color: Colours.palette.m3primary
    }

    Detail {
        icon: "picture_in_picture_center"
        text: I18n.tr("Floating: %1").arg(root.client?.lastIpcObject.floating ? "yes" : "no")
        color: Colours.palette.m3secondary
    }

    Detail {
        icon: "gradient"
        text: I18n.tr("Xwayland: %1").arg(root.client?.lastIpcObject.xwayland ? "yes" : "no")
    }

    Detail {
        icon: "keep"
        text: I18n.tr("Pinned: %1").arg(root.client?.lastIpcObject.pinned ? "yes" : "no")
        color: Colours.palette.m3secondary
    }

    Detail {
        icon: "fullscreen"
        text: {
            const fs = root.client?.lastIpcObject.fullscreen;
            if (fs)
                return I18n.tr("Fullscreen state: %1").arg(fs == 0 ? "off" : fs == 1 ? "maximised" : "on");
            return I18n.tr("Fullscreen state: unknown");
        }
        color: Colours.palette.m3tertiary
    }

    Item {
        Layout.fillHeight: true
    }

    component Detail: RowLayout {
        id: detail

        required property string icon
        required property string text
        property alias color: icon.color

        Layout.leftMargin: Tokens.padding.large
        Layout.rightMargin: Tokens.padding.large
        Layout.fillWidth: true

        spacing: Tokens.spacing.smaller

        MaterialIcon {
            id: icon

            Layout.alignment: Qt.AlignVCenter
            text: detail.icon
        }

        StyledText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            text: detail.text
            elide: Text.ElideRight
            font.pointSize: Tokens.font.size.normal
        }
    }

    component Label: StyledText {
        Layout.leftMargin: Tokens.padding.large
        Layout.rightMargin: Tokens.padding.large
        Layout.fillWidth: true
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        animate: true
    }
}
