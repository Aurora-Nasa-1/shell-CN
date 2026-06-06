pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.modules.ai.config

StyledRect {
    id: root
    
    signal sendRequested(string text)
    signal stopRequested()
    signal closeRequested()
    
    // Add effect: when generating, change visual state
    property bool isGenerating: AIState.currentStatus === AIState.Generating
    
    implicitHeight: Math.min(Math.max(textArea.contentHeight + Tokens.padding.normal * 2, 48), 200)
    color: Colours.palette.m3surfaceVariant
    radius: Tokens.rounding.large
    
    // Minimal blur effect for input area can be achieved via wrapper in Content.qml, 
    // here we just handle the input itself.

    RowLayout {
        anchors.fill: parent
        anchors.margins: Tokens.padding.small
        spacing: Tokens.spacing.small
        
        // Add attachment placeholder
        IconButton {
            Layout.alignment: Qt.AlignVCenter
            icon: "attach_file"
            type: 2
            onClicked: {
                var fileDialog = Qt.createQmlObject('
                    import QtQuick
                    import qs.components.filedialog
                    FileDialog {
                        filters: ["png", "jpg", "jpeg", "webp"]
                        filterLabel: "Images"
                        onAccepted: path => {
                            try {
                                AIState.appendMessage("user", "Attached image: " + path, path);
                            } catch(e) {}
                            destroy();
                        }
                        onRejected: destroy()
                    }
                ', root, "fileDialog");
                fileDialog.open();
            }
        }
        
        IconButton {
            Layout.alignment: Qt.AlignVCenter
            icon: "crop_free"
            type: 2
            onClicked: {
                AIState.startScreenshot();
                root.closeRequested();
            }
        }
        
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            TextArea {
                id: textArea
                
                focus: true
                
                placeholderText: "Type a message... (Shift+Enter for new line)"
                color: Colours.palette.m3onSurfaceVariant
                font.family: Tokens.font.family.sans
                font.pointSize: Tokens.font.size.normal
                wrapMode: Text.Wrap
                
                background: null
                
                onActiveFocusChanged: {
                    if (activeFocus) {
                        Qt.inputMethod.show();
                    }
                }
                
                // Force focus when AI panel becomes visible
                Connections {
                    target: root
                    function onVisibleChanged() {
                        if (root.visible) {
                            textArea.forceActiveFocus();
                        }
                    }
                }
                
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (event.modifiers & Qt.ShiftModifier) {
                            return;
                        } else {
                            event.accepted = true;
                            if (textArea.text.trim().length > 0 && !root.isGenerating) {
                                root.sendRequested(textArea.text);
                                textArea.text = "";
                            }
                        }
                    }
                }
            }
        }
        
        IconButton {
            Layout.alignment: Qt.AlignVCenter
            
            // Switch icon and logic based on generating status
            icon: root.isGenerating ? "stop" : "send"
            type: IconButton.Filled
            disabled: !root.isGenerating && textArea.text.trim().length === 0
            
            onClicked: {
                if (root.isGenerating) {
                    root.stopRequested();
                } else {
                    root.sendRequested(textArea.text);
                    textArea.text = "";
                }
            }
        }
    }
}
