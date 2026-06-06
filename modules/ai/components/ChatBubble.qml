pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.components.effects
import qs.services

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
            Layout.preferredHeight: contentWrapper.implicitHeight + Tokens.padding.normal * 2
            Layout.preferredWidth: Math.max(180, contentWrapper.implicitWidth + Tokens.padding.normal * 2)
            
            radius: Tokens.rounding.normal
            // Users get primary color bubble, AI gets slightly elevated surface color
            color: root.isUser ? Colours.palette.m3primary : Colours.tPalette.m3surfaceContainerHigh
            
            ColumnLayout {
                id: contentWrapper
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Tokens.padding.normal
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
                
                // Render text with Markdown support (Qt 6 native)
                // This handles bold, italic, code blocks (```), inline code, lists, etc.
                TextEdit {
                    id: textContent
                    Layout.fillWidth: true
                    
                    text: root.text
                    textFormat: TextEdit.MarkdownText
                    readOnly: true
                    selectByMouse: true
                    selectByKeyboard: true
                    wrapMode: TextEdit.Wrap
                    color: root.isUser ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                    font.family: Tokens.font.family.sans
                    font.pointSize: Tokens.font.size.normal
                    selectionColor: root.isUser ? Colours.palette.m3onPrimary : Colours.palette.m3primary
                    selectedTextColor: root.isUser ? Colours.palette.m3primary : Colours.palette.m3onPrimary
                    onLinkActivated: (link) => Qt.openUrlExternally(link)
                }
                
                // Action row
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    Layout.topMargin: Tokens.spacing.small
                    visible: root.text.length > 0
                    
                    IconButton {
                        icon: "refresh"
                        type: 2
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
                            try {
                                var tempEdit = Qt.createQmlObject(
                                    'import QtQuick; TextEdit {}',
                                    root, "tempClipboard"
                                );
                                tempEdit.text = root.text;
                                tempEdit.selectAll();
                                tempEdit.copy();
                                tempEdit.destroy();
                                ConfigToasts.show("Copied to clipboard");
                            } catch(e) {}
                        }
                    }
                }
            }
        }
    }
}
