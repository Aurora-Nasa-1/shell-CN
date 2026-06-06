pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.modules.ai.config

Item {
    id: root

    implicitWidth: 350
    implicitHeight: layout.implicitHeight + Tokens.padding.normal * 2

    property bool isOpen: false

    visible: isOpen

    Rectangle {
        anchors.fill: parent
        radius: Tokens.rounding.large
        color: Colours.tPalette.m3surfaceContainerHigh
        border.width: 1
        border.color: Colours.tPalette.m3outlineVariant
        
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: Tokens.padding.large
            spacing: Tokens.spacing.normal
            
            RowLayout {
                Layout.fillWidth: true
                
                MaterialIcon {
                    text: "settings"
                    color: Colours.palette.m3primary
                    font.pointSize: Tokens.font.size.large
                }
                
                StyledText {
                    text: "Settings & Profile"
                    font.weight: Font.DemiBold
                    font.pointSize: Tokens.font.size.large
                    color: Colours.palette.m3onSurface
                    Layout.fillWidth: true
                }
                
                IconButton {
                    icon: "close"
                    type: 2
                    onClicked: root.isOpen = false
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colours.tPalette.m3outlineVariant
            }

            // User Profile Section
            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal
                
                Rectangle {
                    width: 48
                    height: 48
                    radius: 24
                    color: Colours.palette.m3primary
                    
                    StyledText {
                        anchors.centerIn: parent
                        text: "ME"
                        color: Colours.palette.m3onPrimary
                        font.weight: Font.Bold
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    
                    StyledText {
                        text: "User Profile"
                        font.weight: Font.DemiBold
                        color: Colours.palette.m3onSurface
                    }
                    StyledText {
                        text: "Manage your AI assistant settings"
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Tokens.font.size.small
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colours.tPalette.m3outlineVariant
            }

            StyledText {
                text: "System Prompt"
                font.weight: Font.DemiBold
                color: Colours.palette.m3primary
            }
            
            StyledTextField {
                Layout.fillWidth: true
                placeholderText: "e.g., You are a helpful code assistant."
                text: AIState.systemPrompt !== undefined ? AIState.systemPrompt : ""
                onTextChanged: {
                    if (AIState.systemPrompt !== undefined) {
                        AIState.systemPrompt = text;
                    }
                }
            }

            StyledText {
                text: "Tool Execution"
                font.weight: Font.DemiBold
                color: Colours.palette.m3primary
            }

            SwitchRow {
                label: "Auto Execute Commands"
                checked: AIState.autoExecuteTools
                onToggled: function(checked) { AIState.autoExecuteTools = checked; }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal
                visible: AIState.autoExecuteTools

                StyledText {
                    text: "Timeout (seconds):"
                    color: Colours.palette.m3onSurfaceVariant
                }

                StyledTextField {
                    Layout.fillWidth: true
                    text: AIState.autoExecuteTimeout.toString()
                    onTextChanged: {
                        var val = parseInt(text);
                        if (!isNaN(val)) {
                            AIState.autoExecuteTimeout = val;
                        }
                    }
                }
            }

            StyledText {
                text: "API Configuration"
                font.weight: Font.DemiBold
                color: Colours.palette.m3primary
            }

            SwitchRow {
                label: "Auto Retry on Failure"
                checked: AIState.autoRetryOnFailure
                onToggled: function(checked) { AIState.autoRetryOnFailure = checked; }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal
                visible: AIState.autoRetryOnFailure

                StyledText {
                    text: "Max Retries:"
                    color: Colours.palette.m3onSurfaceVariant
                }

                StyledTextField {
                    Layout.fillWidth: true
                    text: AIState.maxRetries.toString()
                    onTextChanged: {
                        var val = parseInt(text);
                        if (!isNaN(val) && val > 0) {
                            AIState.maxRetries = val;
                        }
                    }
                }
            }

            GridLayout {
                columns: 2
                Layout.fillWidth: true
                rowSpacing: Tokens.spacing.normal
                columnSpacing: Tokens.spacing.normal
                
                StyledText {
                    text: "Provider:"
                    color: Colours.palette.m3onSurfaceVariant
                    Layout.alignment: Qt.AlignRight
                }
                
                // For a more complete look, we simulate a combo box with a styled text field
                StyledTextField {
                    Layout.fillWidth: true
                    text: AIState.activeProvider
                    onTextChanged: AIState.activeProvider = text
                }

                StyledText {
                    text: "Model:"
                    color: Colours.palette.m3onSurfaceVariant
                    Layout.alignment: Qt.AlignRight
                }
                
                StyledTextField {
                    Layout.fillWidth: true
                    text: AIState.activeModel
                    onTextChanged: AIState.activeModel = text
                }
                
                StyledText {
                    text: "Base URL:"
                    color: Colours.palette.m3onSurfaceVariant
                    Layout.alignment: Qt.AlignRight
                }
                
                StyledTextField {
                    Layout.fillWidth: true
                    placeholderText: "Default for provider"
                    text: AIState.apiUrl
                    onTextChanged: AIState.apiUrl = text
                }
                
                StyledText {
                    text: "API Key:"
                    color: Colours.palette.m3onSurfaceVariant
                    Layout.alignment: Qt.AlignRight
                }
                
                StyledTextField {
                    Layout.fillWidth: true
                    text: AIState.apiKey
                    // For better UX, show password mode
                    echoMode: TextInput.Password
                    onTextChanged: AIState.apiKey = text
                }
            }
            
            Item { Layout.fillHeight: true } // spacer
        }
    }
}
