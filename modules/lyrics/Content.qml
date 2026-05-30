pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    readonly property bool hasPlayer: Players.active !== null
    readonly property bool hasLyrics: LyricsService.model.count > 0

    readonly property string lyric: {
        const i = LyricsService.currentIndex;
        if (i >= 0 && i < LyricsService.model.count) {
            const item = LyricsService.model.get(i);
            return item?.lyricLine ?? "";
        }
        return "";
    }
    readonly property string label: {
        if (lyric) return lyric;
        if (hasPlayer) {
            const p = Players.active;
            const t = p?.trackTitle ?? "Now Playing";
            const a = p?.trackArtist ?? "";
            return a ? `${t}  ·  ${a}` : t;
        }
        return "";
    }

    readonly property real pad: Tokens.padding.normal + Tokens.padding.smaller

    // Config
    readonly property real cfgFontSize: GlobalConfig.services.lyricsFontSize || Tokens.font.size.small
    readonly property string cfgFontFamily: GlobalConfig.services.lyricsFontFamily || Tokens.font.family.sans
    readonly property string cfgAnim: GlobalConfig.services.lyricsAnimType || "fade"
    readonly property int cfgAnimDur: GlobalConfig.services.lyricsAnimDuration || 300

    readonly property bool animFade: cfgAnim === "fade"
    readonly property bool animSlide: cfgAnim === "slideUp"
    readonly property bool animScale: cfgAnim === "scale"
    readonly property bool animTw: cfgAnim === "typewriter"

    // Typewriter state
    property int twCount: 0
    property string twText: ""

    implicitWidth: row.implicitWidth + pad * 2
    implicitHeight: row.implicitHeight + Tokens.padding.smaller * 2

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Tokens.spacing.smaller

        StyledText {
            id: labelText
            anchors.verticalCenter: parent.verticalCenter
            text: animTw ? root.twText : root.label
            color: Colours.palette.m3onSurface
            font.pointSize: root.cfgFontSize
            font.family: root.cfgFontFamily
            font.weight: Font.Medium
            elide: Text.ElideRight

            // Fade
            opacity: animFade ? 1 : 1
            Behavior on opacity {
                enabled: root.animFade
                NumberAnimation { duration: root.cfgAnimDur }
            }
        }
    }

    // Slide: translate the row vertically (animated via explicit NumberAnimation)
    transform: Translate { id: slideTr }
    NumberAnimation {
        id: slideAnim
        target: slideTr; property: "y"
        duration: root.cfgAnimDur
        easing: Tokens.anim.standardDecel
    }

    // Scale: scale the whole item
    scale: animScale ? 1 : 1
    Behavior on scale {
        enabled: root.animScale
        NumberAnimation {
            from: 0.5; to: 1
            duration: root.cfgAnimDur
            easing: Tokens.anim.standardDecel
        }
    }

    // Trigger animations when label changes
    onLabelChanged: {
        if (animSlide) {
            slideTr.y = root.implicitHeight * 0.3;
            slideAnim.start();
        } else if (animScale) {
            root.scale = 0.5;
            Qt.callLater(() => root.scale = 1);
        } else if (animFade) {
            labelText.opacity = 0;
            Qt.callLater(() => labelText.opacity = 1);
        } else if (animTw) {
            twCount = 0;
            twText = "";
            twTimer.start();
        }
    }

    // Typewriter timer
    Timer {
        id: twTimer
        interval: Math.max(20, root.cfgAnimDur / Math.max(1, root.label.length))
        repeat: false
        onTriggered: {
            if (root.twCount < root.label.length) {
                root.twCount++;
                root.twText = root.label.substring(0, root.twCount);
                twTimer.restart();
            }
        }
    }

    Component.onCompleted: {
        if (animTw) {
            twText = "";
            twCount = 0;
            twTimer.start();
        }
    }
}
