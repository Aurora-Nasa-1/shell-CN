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

    implicitWidth: mainLayout.implicitWidth + pad * 2
    implicitHeight: mainLayout.implicitHeight + Tokens.padding.smaller * 2

    // Config with proper bindings to GlobalConfig settings
    readonly property real cfgFontSize: LyricsService.fontSize || Tokens.font.size.small
    readonly property string cfgFontFamily: LyricsService.fontFamily || Tokens.font.family.sans
    
    readonly property string cfgAnim: LyricsService.animType || "fade"
    readonly property int cfgAnimDur: LyricsService.animDuration || 300
    readonly property string cfgExitAnim: LyricsService.animExitType || "fade"
    readonly property int cfgExitAnimDur: LyricsService.animExitDuration || 200

    property string currentText: ""
    property string nextText: ""
    property bool isTransitioning: false

    Connections {
        target: GlobalConfig.services
        function onLyricsAnimTypeChanged() { root.replay() }
        function onLyricsAnimDurationChanged() { root.replay() }
        function onLyricsAnimExitTypeChanged() { root.replay() }
        function onLyricsAnimExitDurationChanged() { root.replay() }
    }

    function replay() {
        if (root.label.length > 0) {
            triggerTransition(root.label, true);
        }
    }

    onLabelChanged: {
        if (root.label.length > 0) {
            triggerTransition(root.label, false);
        } else {
            root.currentText = "";
            root.nextText = "";
            exitAnimGroup.stop();
            enterAnimGroup.stop();
            root.isTransitioning = false;
        }
    }

    function triggerTransition(newText, force) {
        if (root.currentText === newText && !force) return;
        
        root.nextText = newText;
        root.isTransitioning = true;
        
        exitAnimGroup.stop();
        enterAnimGroup.stop();
        
        setupAndStartExit();
    }

    function setupAndStartExit() {
        animTarget.opacity = 1.0;
        root.scale = 1.0;
        slideTr.y = 0;

        exitFade.duration = 0;
        exitSlide.duration = 0;
        exitScale.duration = 0;
        exitTw.duration = 0;
        
        exitFade.to = animTarget.opacity;
        exitSlide.to = slideTr.y;
        exitScale.to = root.scale;
        exitTw.to = root.twWidth;

        if (cfgExitAnim === "none" || cfgExitAnimDur <= 0) {
            doSwapAndEnter();
            return;
        }

        if (cfgExitAnim === "fade") {
            exitFade.duration = cfgExitAnimDur;
            exitFade.to = 0.0;
        } else if (cfgExitAnim === "slideUp") {
            exitSlide.duration = cfgExitAnimDur;
            exitSlide.to = -root.implicitHeight * 0.5;
        } else if (cfgExitAnim === "slideDown") {
            exitSlide.duration = cfgExitAnimDur;
            exitSlide.to = root.implicitHeight * 0.5;
        } else if (cfgExitAnim === "scale") {
            exitScale.duration = cfgExitAnimDur;
            exitScale.to = 0.5;
        } else if (cfgExitAnim === "typewriter") {
            if (root.twWidth === 0) root.twWidth = dummyText.implicitWidth;
            exitTw.duration = cfgExitAnimDur;
            exitTw.to = 0;
        }
        
        exitAnimGroup.start();
    }

    function doSwapAndEnter() {
        if (!root.isTransitioning) return;
        
        root.currentText = root.nextText;
        
        animTarget.opacity = 1.0;
        root.scale = 1.0;
        slideTr.y = 0;
        root.twWidth = dummyText.implicitWidth;

        enterFade.duration = 0;
        enterSlide.duration = 0;
        enterScale.duration = 0;
        enterTw.duration = 0;

        enterFade.to = animTarget.opacity;
        enterSlide.to = slideTr.y;
        enterScale.to = root.scale;
        enterTw.to = root.twWidth;

        if (cfgAnim === "none" || cfgAnimDur <= 0) {
            root.isTransitioning = false;
            return;
        }

        if (cfgAnim === "fade") {
            animTarget.opacity = 0.0;
            enterFade.duration = cfgAnimDur;
            enterFade.to = 1.0;
        } else if (cfgAnim === "slideUp") {
            slideTr.y = root.implicitHeight * 0.5;
            enterSlide.duration = cfgAnimDur;
            enterSlide.to = 0;
        } else if (cfgAnim === "slideDown") {
            slideTr.y = -root.implicitHeight * 0.5;
            enterSlide.duration = cfgAnimDur;
            enterSlide.to = 0;
        } else if (cfgAnim === "scale") {
            root.scale = 0.5;
            enterScale.duration = cfgAnimDur;
            enterScale.to = 1.0;
        } else if (cfgAnim === "typewriter") {
            root.twWidth = 0;
            enterTw.duration = cfgAnimDur;
            enterTw.to = dummyText.implicitWidth;
        }
        
        enterAnimGroup.start();
    }

    ParallelAnimation {
        id: exitAnimGroup
        NumberAnimation { id: exitFade; target: animTarget; property: "opacity"; easing.type: Easing.InQuad }
        NumberAnimation { id: exitSlide; target: slideTr; property: "y"; easing.type: Easing.InQuad }
        NumberAnimation { id: exitScale; target: root; property: "scale"; easing.type: Easing.InQuad }
        NumberAnimation { id: exitTw; target: root; property: "twWidth"; easing.type: Easing.InQuad }
        
        onFinished: {
            if (root.isTransitioning) doSwapAndEnter();
        }
    }

    ParallelAnimation {
        id: enterAnimGroup
        NumberAnimation { id: enterFade; target: animTarget; property: "opacity"; easing.type: Easing.OutQuad }
        NumberAnimation { id: enterSlide; target: slideTr; property: "y"; easing.type: Easing.OutQuad }
        NumberAnimation { id: enterScale; target: root; property: "scale"; easing.type: Easing.OutQuad }
        NumberAnimation { id: enterTw; target: root; property: "twWidth"; easing.type: Easing.OutQuad }
        
        onFinished: {
            root.isTransitioning = false;
        }
    }

    Row {
        id: mainLayout
        anchors.centerIn: parent
        spacing: Tokens.spacing.smaller

        Item {
            width: dummyText.implicitWidth
            height: dummyText.implicitHeight

            StyledText {
                id: dummyText
                text: root.currentText
                font.pointSize: root.cfgFontSize
                font.family: root.cfgFontFamily
                font.weight: Font.Medium
                opacity: 0 // Used just to reserve space securely and stabilize layout center
            }

            Item {
                id: animTarget
                width: root.cfgAnim === "typewriter" || root.cfgExitAnim === "typewriter" ? root.twWidth : parent.width
                height: parent.height
                clip: root.cfgAnim === "typewriter" || root.cfgExitAnim === "typewriter"

                StyledText {
                    text: root.currentText
                    color: Colours.palette.m3onSurface
                    font.pointSize: root.cfgFontSize
                    font.family: root.cfgFontFamily
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }
            }
        }
    }

    transform: Translate { id: slideTr }

    property real twWidth: 0

    Component.onCompleted: {
        if (root.label.length > 0) {
            root.currentText = root.label;
            root.nextText = root.label;
            root.twWidth = dummyText.implicitWidth;
        }
    }
}
