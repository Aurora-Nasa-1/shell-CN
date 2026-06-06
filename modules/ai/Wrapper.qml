pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.ai.config

Item {
    id: root

    required property DrawerVisibilities visibilities

    readonly property bool shouldBeActive: visibilities.ai ?? false
    property real offsetScale: shouldBeActive ? 0 : 1

    visible: offsetScale < 1
    anchors.rightMargin: (-implicitWidth - 5) * offsetScale
    implicitHeight: content.implicitHeight
    implicitWidth: content.implicitWidth || 380
    width: implicitWidth
    height: implicitHeight
    opacity: 1 - offsetScale
    clip: true

    Behavior on offsetScale {
        Anim {
            type: Anim.DefaultSpatial
        }
    }

    Behavior on implicitWidth {
        Anim {
            type: Anim.DefaultSpatial
        }
    }

    Loader {
        id: content

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left

        active: root.shouldBeActive || root.visible || AIState.currentStatus === AIState.Generating

        sourceComponent: Content {
            visibilities: root.visibilities
        }
    }


}
