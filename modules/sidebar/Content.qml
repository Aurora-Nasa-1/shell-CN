import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property Props props
    required property DrawerVisibilities visibilities

    readonly property color sidebarColour: {
        var c = Config.sidebar.colour;
        if (c === undefined || c === null)
            return Colours.tPalette.m3surfaceContainerLow;
        // Use custom colour only if alpha > 0 (not the default transparent/invalid colour)
        return c.a > 0 ? c : Colours.tPalette.m3surfaceContainerLow;
    }

    ColumnLayout {
        id: layout

        anchors.fill: parent
        spacing: Tokens.spacing.normal

        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: Tokens.rounding.normal
            color: root.sidebarColour

            NotifDock {
                props: root.props
                visibilities: root.visibilities
            }
        }

        StyledRect {
            Layout.topMargin: Tokens.padding.large - layout.spacing
            Layout.fillWidth: true
            implicitHeight: 1

            color: Colours.tPalette.m3outlineVariant
        }
    }
}
