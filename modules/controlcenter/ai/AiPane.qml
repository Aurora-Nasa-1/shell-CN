pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.effects
import qs.services
import qs.utils
import qs.modules.ai as Ai
import ".."
import "../components"

Item {
    id: root

    required property Session session

    anchors.fill: parent

    ClippingRectangle {
        id: clippingRect

        anchors.fill: parent
        anchors.margins: Tokens.padding.normal
        anchors.leftMargin: 0
        anchors.rightMargin: Tokens.padding.normal

        radius: paneBorder.innerRadius
        color: "transparent"

        Loader {
            id: contentLoader

            anchors.fill: parent
            anchors.margins: Tokens.padding.large + Tokens.padding.normal
            anchors.leftMargin: Tokens.padding.large
            anchors.rightMargin: Tokens.padding.large

            asynchronous: true
            sourceComponent: Ai.Content {
                // Pass dummy visibilities since we're in the control center now
                visibilities: DrawerVisibilities {}
            }
        }
    }

    InnerBorder {
        id: paneBorder

        leftThickness: 0
        rightThickness: Tokens.padding.normal
    }
}
