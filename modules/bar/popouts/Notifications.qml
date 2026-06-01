pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.components.controls
import qs.services

ColumnLayout {
    id: root

    required property PopoutState popouts

    width: 300
    spacing: Tokens.spacing.small

    StyledText {
        Layout.topMargin: Tokens.padding.normal
        Layout.rightMargin: Tokens.padding.small
        text: qsTr("Notifications")
        font.weight: 500
    }

    Toggle {
        label: qsTr("Do not disturb")
        checked: Notifs.dnd
        toggle.onToggled: Notifs.dnd = checked
    }

    StyledText {
        Layout.topMargin: Tokens.spacing.small
        Layout.rightMargin: Tokens.padding.small
        text: Notifs.dnd ? qsTr("Notifications off") : qsTr("%1 unread").arg(Notifs.notClosed.length)
        color: Colours.palette.m3onSurfaceVariant
        font.pointSize: Tokens.font.size.small
    }

    IconTextButton {
        Layout.fillWidth: true
        Layout.topMargin: Tokens.spacing.normal
        inactiveColour: Colours.palette.m3primaryContainer
        inactiveOnColour: Colours.palette.m3onPrimaryContainer
        verticalPadding: Tokens.padding.small
        text: qsTr("Clear all")
        icon: "clear_all"

        onClicked: Notifs.clear()
    }

    component Toggle: RowLayout {
        required property string label
        property alias checked: toggle.checked
        property alias toggle: toggle

        Layout.fillWidth: true
        Layout.rightMargin: Tokens.padding.small
        spacing: Tokens.spacing.normal

        StyledText {
            Layout.fillWidth: true
            text: parent.label
        }

        StyledSwitch {
            id: toggle
        }
    }
}
