pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.modules.ai.config

Item {
    id: root

    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    signal chipClicked(string text)

    ColumnLayout {
        id: layout
        anchors.centerIn: parent
        spacing: Tokens.spacing.large

        MaterialIcon {
            Layout.alignment: Qt.AlignHCenter
            text: "smart_toy"
            color: Colours.palette.m3primary
            font.pointSize: 48
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: "How can I help you today?"
            font.weight: Font.DemiBold
            font.pointSize: Tokens.font.size.large
            color: Colours.palette.m3onSurface
        }

        // Suggestion Chips
        GridLayout {
            Layout.alignment: Qt.AlignHCenter
            columns: 2
            rowSpacing: Tokens.spacing.normal
            columnSpacing: Tokens.spacing.normal

            Repeater {
                model: [
                    "Help me write a Python script",
                    "Explain this code to me",
                    "Polished my grammar",
                    "Summarize the current clipboard"
                ]

                delegate: StyledRect {
                    required property int index
                    required property string modelData

                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 60
                    radius: Tokens.rounding.large
                    color: itemMouseArea.containsMouse ? Colours.tPalette.m3surfaceVariant : Colours.tPalette.m3surfaceContainer
                    border.width: 1
                    border.color: Colours.tPalette.m3outlineVariant

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Tokens.padding.normal
                        spacing: Tokens.spacing.small

                        MaterialIcon {
                            text: index === 0 ? "code" : (index === 1 ? "lightbulb" : (index === 2 ? "spellcheck" : "content_paste"))
                            color: Colours.palette.m3primary
                            font.pointSize: Tokens.font.size.normal
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData
                            wrapMode: Text.Wrap
                            color: Colours.palette.m3onSurfaceVariant
                            font.pointSize: Tokens.font.size.small
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: itemMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.chipClicked(modelData)
                    }
                }
            }
        }
    }
}
