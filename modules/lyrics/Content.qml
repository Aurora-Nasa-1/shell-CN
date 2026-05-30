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

    // Re-read font config when it changes
    readonly property real cfgFontSize: GlobalConfig.services.lyricsFontSize || Tokens.font.size.small
    readonly property string cfgFontFamily: GlobalConfig.services.lyricsFontFamily || Tokens.font.family.sans

    implicitWidth: row.implicitWidth + pad * 2
    implicitHeight: row.implicitHeight + Tokens.padding.smaller * 2

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Tokens.spacing.smaller

        StyledText {
            id: lyricLabel
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: Colours.palette.m3onSurface
            font.pointSize: root.cfgFontSize
            font.family: root.cfgFontFamily
            font.weight: Font.Medium
            elide: Text.ElideRight
            animate: true
        }
    }
}
