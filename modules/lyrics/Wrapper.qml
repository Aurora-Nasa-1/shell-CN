pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    property bool forceRetract: false

    readonly property bool hasPlayer: Players.active !== null
    readonly property bool shouldBeActive: hasPlayer && !forceRetract
    property real offsetScale: shouldBeActive ? 0 : 1

    visible: offsetScale < 1
    anchors.topMargin: (-implicitHeight - 5) * offsetScale
    implicitHeight: content.implicitHeight
    implicitWidth: content.implicitWidth || 200
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

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        active: root.shouldBeActive || root.visible

        sourceComponent: Content {}
    }

    // Sync lyrics position periodically
    Timer {
        running: hasPlayer
        interval: GlobalConfig.services.lyricsUpdateInterval ?? 500
        triggeredOnStart: true
        repeat: true
        onTriggered: {
            if (Players.active)
                LyricsService.updatePosition();
        }
    }
}
