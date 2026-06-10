pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Config
import qs.modules.bar as Bar

Region {
    id: root

    required property Bar.BarWrapper bar
    required property Panels panels
    required property var win

    Config.screen: win.screen.name

    readonly property real borderThickness: win.contentItem.Config.border.thickness
    readonly property real clampedThickness: win.contentItem.Config.border.clampedThickness

    readonly property real barLeftWidth: Config.bar.position === "left" ? bar.clampedThickness : clampedThickness
    readonly property real barRightWidth: Config.bar.position === "right" ? bar.clampedThickness : clampedThickness
    readonly property real barTopHeight: Config.bar.position === "top" ? bar.clampedThickness : clampedThickness
    readonly property real barBottomHeight: Config.bar.position === "bottom" ? bar.clampedThickness : clampedThickness

    x: barLeftWidth + win.dragMaskPadding
    y: barTopHeight + win.dragMaskPadding
    width: win.width - barLeftWidth - barRightWidth - win.dragMaskPadding * 2
    height: win.height - barTopHeight - barBottomHeight - win.dragMaskPadding * 2
    intersection: Intersection.Xor

    R {
        panel: root.panels.dashboard
        y: 0
        height: root.panels.dashboard.offsetScale < 1 ? panel.height * (1 - root.panels.dashboard.offsetScale) + root.borderThickness : 0
    }

    R {
        panel: root.panels.launcher
        y: root.win.height - height
        height: root.panels.launcher.offsetScale < 1 ? panel.height * (1 - root.panels.launcher.offsetScale) + root.borderThickness : 0
    }

    R {
        id: sessionRegion

        panel: root.panels.sessionWrapper
        x: root.Config.bar.position === "right" ? 0 : root.win.width - sessionRegion.width
        width: panel.width * (1 - root.panels.session.offsetScale) + (root.panels.session.offsetScale < 1 ? root.borderThickness : 0) + sidebarRegion.width
    }

    R {
        id: sidebarRegion

        panel: root.panels.sidebar
        x: root.Config.bar.position === "right" ? 0 : root.win.width - sidebarRegion.width
        width: panel.width * (1 - root.panels.sidebar.offsetScale) + (root.panels.sidebar.offsetScale < 1 ? root.borderThickness : 0)
    }

    R {
        id: aiRegion
        panel: root.panels.aiWrapper
    }

    R {
        id: osdRegion
        panel: root.panels.osdWrapper
        x: root.Config.bar.position === "right" ? 0 : root.win.width - osdRegion.width
        width: panel.width * (1 - root.panels.osd.offsetScale) + (root.panels.osd.offsetScale < 1 ? root.borderThickness : 0) + sessionRegion.width
    }

    R {
        panel: root.panels.notifications
        y: Config.bar.position === "bottom" ? (panel.y + root.panels.topMargin) : 0
        height: Config.bar.position === "bottom" ? (root.win.height - y) : (panel.height > 0 ? panel.height + panel.y + root.panels.topMargin : 0)
    }

    R {
        panel: root.panels.utilities
        y: root.Config.bar.position === "bottom" ? 0 : root.win.height - height
        height: root.panels.utilities.offsetScale < 1 ? panel.height * (1 - root.panels.utilities.offsetScale) + root.borderThickness : 0
    }

    R {
        panel: root.panels.lyricsHoverArea
        y: 0
        height: root.panels.lyricsHoverArea.forceHide ? 0 : (panel.height > 0 ? panel.height + root.borderThickness : 0)
    }

    R {
        panel: root.panels.popoutsWrapper
        width: panel.width * (1 - root.panels.popoutsWrapper.offsetScale)
    }

    component R: Region {
        required property Item panel

        x: panel.x + root.panels.leftMargin
        y: panel.y + root.panels.topMargin
        width: panel.width
        height: panel.height
        intersection: Intersection.Subtract
    }
}
