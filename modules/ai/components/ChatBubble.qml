pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.components.controls
import qs.components.effects

Item {
    id: root
    
    required property string role
    required property string text
    property string imagePath: ""
    property bool isUser: role === "user"
    
    // Optional index for ListView delegates
    property int itemIndex: -1
    
    width: parent ? parent.width : 300
    implicitHeight: layout.implicitHeight
    
    signal regenerateRequested(int itemIndex)
    
    RowLayout {
        id: layout
        
        width: parent.width
        layoutDirection: root.isUser ? Qt.RightToLeft : Qt.LeftToRight
        spacing: Tokens.spacing.normal
        
        Item { Layout.fillWidth: true } // Spacer
        
        StyledRect {
            Layout.maximumWidth: root.width * 0.85
            Layout.preferredHeight: contentLayout.implicitHeight + Tokens.padding.normal * 2
            Layout.preferredWidth: contentLayout.implicitWidth + Tokens.padding.normal * 2
            
            radius: Tokens.rounding.normal
            // Users get primary color bubble, AI gets slightly elevated surface color
            color: root.isUser ? Colours.palette.m3primary : Colours.tPalette.m3surfaceContainerHigh
            
            ColumnLayout {
                id: contentLayout
                anchors.centerIn: parent
                width: Math.min(implicitWidth, parent.Layout.maximumWidth - Tokens.padding.normal * 2)
                spacing: Tokens.spacing.small

                Image {
                    Layout.fillWidth: true
                    Layout.maximumWidth: root.width * 0.85 - Tokens.padding.normal * 2
                    Layout.maximumHeight: 300
                    fillMode: Image.PreserveAspectFit
                    source: root.imagePath !== "" ? "file://" + root.imagePath : ""
                    visible: root.imagePath !== ""
                    asynchronous: true
                }

                StyledText {
                    id: textContent
                    
                    Layout.fillWidth: true
                    Layout.maximumWidth: root.width * 0.85 - Tokens.padding.normal * 2
                    
                    text: root.text
                    textFormat: Text.MarkdownText
                    wrapMode: Text.Wrap
                    color: root.isUser ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                    onLinkActivated: (link) => Qt.openUrlExternally(link)
                    font.pointSize: Tokens.font.size.normal
                    
                    // Simple interaction: right click or long press to copy? Let's add a copy button for AI
                }

                // Action row
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    visible: root.text.length > 0
                    
                    IconButton {
                        icon: "refresh"
                        type: 2
                        // Only show refresh on the last message, or if it's the last user message
                        visible: root.ListView.view && (root.itemIndex === root.ListView.view.count - 1 || (root.isUser && root.itemIndex === root.ListView.view.count - 2))
                        onClicked: {
                            if (root.ListView.view && root.ListView.view.model) {
                                root.regenerateRequested(root.itemIndex);
                            }
                        }
                    }

                    IconButton {
                        icon: "content_copy"
                        type: 2
                        onClicked: {
                            // Basic clipboard copy if accessible
                            // In QtQuick we can use TextInput for quick copy hack if clipboard isn't exposed
                            var copyHelper = Qt.createQmlObject('import QtQuick; TextInput { text: "' + root.text.replace(/"/g, '\\"').replace(/\n/g, '\\n') + '"; visible: false }', root, "copyHelper");
                            copyHelper.selectAll();
                            copyHelper.copy();
                            copyHelper.destroy();
                            
                            // Let's assume we have a toast service
                            try {
                                ConfigToasts.show("Copied to clipboard");
                            } catch(e) {}
                        }
                    }
                }
            }
        }
    }
}
