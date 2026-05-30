pragma ComponentBehavior: Bound

import ".."
import "../../components"
import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.services

CollapsibleSection {
    id: root

    required property var rootPane

    title: qsTr("Border")
    showBackground: true

    SectionContainer {
        contentSpacing: Tokens.spacing.normal

        SliderInput {
            Layout.fillWidth: true

            label: qsTr("Border rounding")
            value: rootPane.borderRounding
            from: 0.1
            to: 100
            decimals: 1
            suffix: "px"
            validator: DoubleValidator {
                bottom: 0.1
                top: 100
            }

            onValueModified: newValue => {
                rootPane.borderRounding = newValue;
                rootPane.saveConfig();
            }
        }
    }

    SectionContainer {
        contentSpacing: Tokens.spacing.normal

        SliderInput {
            Layout.fillWidth: true

            label: qsTr("Border thickness")
            value: rootPane.borderThickness
            from: 0
            to: 100
            decimals: 1
            suffix: "px"
            validator: DoubleValidator {
                bottom: 0.1
                top: 100
            }

            onValueModified: newValue => {
                rootPane.borderThickness = newValue;
                rootPane.saveConfig();
            }
        }
    }

    SectionContainer {
        contentSpacing: Tokens.spacing.normal

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            StyledText {
                text: qsTr("Border decoration colour")
                font.pointSize: Tokens.font.size.normal
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                StyledRect {
                    id: colourPreview

                    readonly property bool hasCustomColour: rootPane.borderColour !== undefined && rootPane.borderColour.a > 0

                    Layout.preferredWidth: Tokens.padding.large * 2
                    Layout.preferredHeight: Tokens.padding.large * 2
                    radius: Tokens.rounding.small
                    color: hasCustomColour ? rootPane.borderColour : Colours.palette.m3surface
                    border.width: 1
                    border.color: Qt.alpha(Colours.palette.m3outline, 0.3)
                }

                StyledInputField {
                    id: borderColourInput

                    Layout.preferredWidth: 100
                    horizontalAlignment: TextInput.AlignLeft

                    text: {
                        if (rootPane.borderColour !== undefined) {
                            const c = rootPane.borderColour;
                            if (c.a === 0)
                                return "";
                            return c.toString().slice(0, 7);
                        }
                        return "";
                    }

                    onTextEdited: {
                        var inputText = borderColourInput.text;
                        if (inputText.length > 0 && inputText.charAt(0) !== '#') {
                            inputText = '#' + inputText;
                        }
                        var match = /^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/.exec(inputText);
                        if (match) {
                            var hex = match[1];
                            if (hex.length === 3) {
                                hex = hex.charAt(0) + hex.charAt(0) + hex.charAt(1) + hex.charAt(1) + hex.charAt(2) + hex.charAt(2);
                            }
                            rootPane.borderColour = Qt.rgba(
                                parseInt(hex.slice(0, 2), 16) / 255,
                                parseInt(hex.slice(2, 4), 16) / 255,
                                parseInt(hex.slice(4, 6), 16) / 255,
                                1
                            );
                            rootPane.saveConfig();
                        }
                    }
                }

                IconButton {
                    icon: "close"
                    type: IconButton.Text

                    implicitWidth: Tokens.padding.large * 2
                    implicitHeight: Tokens.padding.large * 2

                    onClicked: {
                        rootPane.borderColour = Qt.rgba(0, 0, 0, 0);
                        rootPane.saveConfig();
                    }
                }
            }

            StyledText {
                text: qsTr("Leave empty to use the theme colour")
                color: Colours.palette.m3outline
                font.pointSize: Tokens.font.size.small
                opacity: 0.7
            }
        }
    }

    SectionContainer {
        contentSpacing: Tokens.spacing.normal

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            StyledText {
                text: qsTr("Sidebar background colour")
                font.pointSize: Tokens.font.size.normal
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal

                StyledRect {
                    id: sidebarColourPreview

                    readonly property bool hasCustomColour: rootPane.sidebarColour !== undefined && rootPane.sidebarColour.a > 0

                    Layout.preferredWidth: Tokens.padding.large * 2
                    Layout.preferredHeight: Tokens.padding.large * 2
                    radius: Tokens.rounding.small
                    color: hasCustomColour ? rootPane.sidebarColour : Colours.tPalette.m3surfaceContainerLow
                    border.width: 1
                    border.color: Qt.alpha(Colours.palette.m3outline, 0.3)
                }

                StyledInputField {
                    id: sidebarColourInput

                    Layout.preferredWidth: 100
                    horizontalAlignment: TextInput.AlignLeft

                    text: {
                        if (rootPane.sidebarColour !== undefined) {
                            const c = rootPane.sidebarColour;
                            if (c.a === 0)
                                return "";
                            return c.toString().slice(0, 7);
                        }
                        return "";
                    }

                    onTextEdited: {
                        var inputText = sidebarColourInput.text;
                        if (inputText.length > 0 && inputText.charAt(0) !== '#') {
                            inputText = '#' + inputText;
                        }
                        var match = /^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/.exec(inputText);
                        if (match) {
                            var hex = match[1];
                            if (hex.length === 3) {
                                hex = hex.charAt(0) + hex.charAt(0) + hex.charAt(1) + hex.charAt(1) + hex.charAt(2) + hex.charAt(2);
                            }
                            rootPane.sidebarColour = Qt.rgba(
                                parseInt(hex.slice(0, 2), 16) / 255,
                                parseInt(hex.slice(2, 4), 16) / 255,
                                parseInt(hex.slice(4, 6), 16) / 255,
                                1
                            );
                            rootPane.saveConfig();
                        }
                    }
                }

                IconButton {
                    icon: "close"
                    type: IconButton.Text

                    implicitWidth: Tokens.padding.large * 2
                    implicitHeight: Tokens.padding.large * 2

                    onClicked: {
                        rootPane.sidebarColour = Qt.rgba(0, 0, 0, 0);
                        rootPane.saveConfig();
                    }
                }
            }

            StyledText {
                text: qsTr("Leave empty to use the theme colour")
                color: Colours.palette.m3outline
                font.pointSize: Tokens.font.size.small
                opacity: 0.7
            }
        }
    }

    // ── Lyrics bar settings ──────────────────────────────
    CollapsibleSection {
        title: qsTr("Top lyrics bar")
        expanded: true
        nested: true
        showBackground: true

        SectionContainer {
            contentSpacing: Tokens.spacing.normal

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                SliderInput {
                    Layout.fillWidth: true

                    label: qsTr("Font size")
                    value: rootPane.lyricsFontSize
                    from: 8
                    to: 24
                    decimals: 0
                    suffix: "px"

                    onValueModified: newValue => {
                        rootPane.lyricsFontSize = newValue;
                        rootPane.saveConfig();
                    }
                }

                SliderInput {
                    Layout.fillWidth: true

                    label: qsTr("Update interval")
                    value: rootPane.lyricsUpdateInterval
                    from: 100
                    to: 2000
                    stepSize: 100
                    decimals: 0
                    suffix: "ms"

                    onValueModified: newValue => {
                        rootPane.lyricsUpdateInterval = newValue;
                        rootPane.saveConfig();
                    }
                }
            }
        }

        // Font family picker — same style as FontsSection
        CollapsibleSection {
            title: qsTr("Font family")
            expanded: false
            nested: true
            showBackground: true

            Loader {
                Layout.fillWidth: true
                Layout.preferredHeight: item ? Math.min(item.contentHeight, 300) : 0
                asynchronous: true
                active: expanded

                sourceComponent: StyledListView {
                    id: lyricsFontList

                    property alias contentHeight: lyricsFontList.contentHeight

                    clip: true
                    spacing: Tokens.spacing.small / 2
                    model: Qt.fontFamilies()

                    StyledScrollBar.vertical: StyledScrollBar {
                        flickable: lyricsFontList
                    }

                    delegate: StyledRect {
                        required property string modelData
                        required property int index
                        readonly property bool isCurrent: modelData === rootPane.lyricsFontFamily

                        width: ListView.view.width
                        color: Qt.alpha(Colours.tPalette.m3surfaceContainer, isCurrent ? Colours.tPalette.m3surfaceContainer.a : 0)
                        radius: Tokens.rounding.normal
                        border.width: isCurrent ? 1 : 0
                        border.color: Colours.palette.m3primary
                        implicitHeight: row.implicitHeight + Tokens.padding.normal * 2

                        StateLayer {
                            onClicked: {
                                rootPane.lyricsFontFamily = modelData;
                                rootPane.saveConfig();
                            }
                        }

                        RowLayout {
                            id: row

                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: Tokens.padding.normal

                            spacing: Tokens.spacing.normal

                            StyledText {
                                text: modelData
                                font.pointSize: Tokens.font.size.normal
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Loader {
                                asynchronous: true
                                active: isCurrent

                                sourceComponent: MaterialIcon {
                                    text: "check"
                                    color: Colours.palette.m3primary
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
