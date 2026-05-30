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
import qs.utils

CollapsibleSection {
    id: root

    required property var rootPane

    title: I18n.tr("Top lyrics bar")
    expanded: true
    showBackground: true

    SectionContainer {
        contentSpacing: Tokens.spacing.normal

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            SliderInput {
                Layout.fillWidth: true

                label: I18n.tr("Font size")
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

            SwitchRow {
                label: I18n.tr("NetEase: show translation only")
                checked: rootPane.lyricsShowTranslation

                onToggled: newValue => {
                    rootPane.lyricsShowTranslation = newValue;
                    rootPane.saveConfig();
                }
            }

            SliderInput {
                Layout.fillWidth: true

                label: I18n.tr("Update interval")
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

            StyledText {
                text: I18n.tr("Enter animation")
                font.pointSize: Tokens.font.size.normal
                font.weight: Font.Medium
            }

            Flow {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                Repeater {
                    model: ["fade", "slideUp", "slideDown", "scale", "typewriter"]

                    delegate: TextButton {
                        required property string modelData

                        text: modelData
                        checked: rootPane.lyricsAnimType === modelData
                        type: rootPane.lyricsAnimType === modelData ? TextButton.Filled : TextButton.Tonal

                        onClicked: {
                            rootPane.lyricsAnimType = modelData;
                            rootPane.saveConfig();
                        }
                    }
                }
            }

            SliderInput {
                Layout.fillWidth: true

                label: I18n.tr("Enter duration")
                value: rootPane.lyricsAnimDuration
                from: 50
                to: 1000
                stepSize: 50
                decimals: 0
                suffix: "ms"

                onValueModified: newValue => {
                    rootPane.lyricsAnimDuration = newValue;
                    rootPane.saveConfig();
                }
            }

            StyledText {
                text: I18n.tr("Exit animation")
                font.pointSize: Tokens.font.size.normal
                font.weight: Font.Medium
                color: Colours.palette.m3onSurfaceVariant
            }

            Flow {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                Repeater {
                    model: ["none", "fade", "slideUp", "slideDown", "scale", "typewriter"]

                    delegate: TextButton {
                        required property string modelData

                        text: modelData
                        checked: rootPane.lyricsAnimExitType === modelData
                        type: rootPane.lyricsAnimExitType === modelData ? TextButton.Filled : TextButton.Tonal

                        onClicked: {
                            rootPane.lyricsAnimExitType = modelData;
                            rootPane.saveConfig();
                        }
                    }
                }
            }

            SliderInput {
                Layout.fillWidth: true

                label: I18n.tr("Exit duration")
                value: rootPane.lyricsAnimExitDuration
                from: 50
                to: 500
                stepSize: 50
                decimals: 0
                suffix: "ms"

                onValueModified: newValue => {
                    rootPane.lyricsAnimExitDuration = newValue;
                    rootPane.saveConfig();
                }
            }
        }
    }

    CollapsibleSection {
        title: I18n.tr("Font family")
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
