pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.effects
import qs.services
import qs.utils
import "components"
import "config"
import "services"

Item {
    id: root

    required property DrawerVisibilities visibilities
    
    readonly property bool needsKeyboard: true

    implicitWidth: Tokens.sizes.sidebar.width + (showHistory ? (250 + layout.spacing) : 0)
    implicitHeight: Math.min(((QsWindow.window as QsWindow)?.screen?.height ?? 1080) * 0.7, 750)

    readonly property color aiSidebarColour: {
        var c = Config.sidebar.colour;
        if (c === undefined || c === null)
            return Colours.tPalette.m3surfaceContainerLow;
        return c.a > 0 ? c : Colours.tPalette.m3surfaceContainerLow;
    }

    property bool showHistory: false

    RowLayout {
        id: layout

        anchors.fill: parent
        spacing: Tokens.spacing.normal

        // History Panel
        StyledRect {
            Layout.fillHeight: true
            Layout.preferredWidth: 250
            visible: root.showHistory
            color: root.aiSidebarColour
            radius: Tokens.rounding.normal

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.padding.normal
                spacing: Tokens.spacing.normal
                
                // History Header
                RowLayout {
                    Layout.fillWidth: true
                    
                    StyledText {
                        Layout.fillWidth: true
                        text: "Chat History"
                        font.weight: Font.DemiBold
                        font.pointSize: Tokens.font.size.normal
                        color: Colours.palette.m3onSurface
                    }
                    
                    IconButton {
                        icon: "add"
                        type: IconButton.Tonal
                        onClicked: AIState.createNewChat()
                    }
                }
                
                // History List
                StyledListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: AIState.chats
                    spacing: Tokens.spacing.small
                    clip: true
                    
                    delegate: StyledRect {
                        required property var modelData
                        required property int index
                        
                        width: ListView.view.width
                        height: 48
                        color: AIState.currentChatId === modelData.id ? Colours.palette.m3surfaceVariant : "transparent"
                        radius: Tokens.rounding.normal
                        
                        CustomMouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: AIState.switchChat(modelData.id)
                        }
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Tokens.padding.small
                            
                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.title || "New Chat"
                                color: Colours.palette.m3onSurface
                                elide: Text.ElideRight
                                font.pointSize: Tokens.font.size.small
                            }
                            
                            IconButton {
                                icon: "delete"
                                type: 2
                                onClicked: AIState.deleteChat(modelData.id)
                            }
                        }
                    }
                }
            }
        }

        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: Tokens.rounding.normal
            color: root.aiSidebarColour

            Item {
                anchors.fill: parent
                anchors.margins: Tokens.padding.large

                ColumnLayout {
                    id: mainLayout
                    anchors.fill: parent
                    spacing: Tokens.spacing.normal
                    
                    // Header Card
                    StyledRect {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        
                        radius: Tokens.rounding.large
                        color: Colours.tPalette.m3surfaceContainer
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Tokens.padding.normal
                            
                            IconButton {
                                icon: "menu"
                                type: 2
                                onClicked: root.showHistory = !root.showHistory
                            }

                            MaterialIcon {
                                text: "smart_toy"
                                color: Colours.palette.m3primary
                                font.pointSize: Tokens.font.size.large
                            }
                            
                            StyledText {
                                Layout.fillWidth: true
                                text: "AI Assistant"
                                font.weight: Font.DemiBold
                                font.pointSize: Tokens.font.size.large
                                color: Colours.palette.m3onSurface
                            }
                            
                            IconButton {
                                icon: "delete_sweep"
                                type: 2
                                onClicked: AIState.clearHistory()
                            }
                            
                            IconButton {
                                icon: "settings"
                                type: IconButton.Tonal
                                onClicked: settingsDialog.isOpen = !settingsDialog.isOpen
                            }
                        }
                    }
                    
                    // Main Chat Area
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        StyledListView {
                            id: messageList
                            anchors.fill: parent
                            
                            clip: true
                            spacing: Tokens.spacing.normal
                            
                            model: AIState.currentMessages
                            
                            delegate: ChatBubble {
                                required property var modelData
                                required property int index

                                role: modelData.role || ""
                                text: {
                                    if (modelData.role === "tool") return "🔧 Tool Output (" + (modelData.name || "") + "):\n" + (modelData.text || "");
                                    if (modelData.tool_calls && modelData.tool_calls.length > 0) return "⚙️ Executing tools...\n" + (modelData.text || "");
                                    return modelData.text || "";
                                }
                                imagePath: modelData.imagePath || ""
                                width: messageList.width
                                itemIndex: index
                                
                                onRegenerateRequested: function(idx) {
                                    var messages = AIState.currentMessages;
                                    while (messages.length > 0 && messages[messages.length - 1].role !== "user") {
                                        AIState.popLastMessage();
                                        messages = AIState.currentMessages;
                                    }
                                    if (messages.length > 0 && messages[messages.length - 1].role === "user") {
                                        var lastUserText = messages[messages.length - 1].text;
                                        AIState.popLastMessage(); // Pop User message
                                        sendPrompt(lastUserText);
                                    }
                                }
                            }
                            
                            onCountChanged: {
                                Qt.callLater(() => {
                                    if (count > 0 && atYEnd) {
                                        positionViewAtEnd();
                                    }
                                });
                            }
                        }

                        // Suggestion Chips (Empty State)
                        SuggestionChips {
                            anchors.centerIn: parent
                            visible: AIState.currentMessages.length === 0
                            onChipClicked: function(text) { sendPrompt(text); }
                        }

                        // Streaming Status Bubble
                        ChatBubble {
                            id: streamBubble
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            visible: AIState.currentStatus === AIState.Generating
                            role: "assistant"
                            text: AIState.currentStreamText.length > 0 ? AIState.currentStreamText : "Thinking..."
                        }
                        
                        // Error Status Bubble
                        ChatBubble {
                            id: errorBubble
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            visible: AIState.currentStatus === AIState.Error
                            role: "assistant"
                            text: "⚠️ Error: " + AIState.currentErrorText
                        }

                        // Tool Execution Confirmation
                        StyledRect {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: Tokens.padding.normal
                            visible: root.waitingForToolApproval
                            color: Colours.tPalette.m3surfaceContainerHigh
                            radius: Tokens.rounding.normal
                            border.color: Colours.palette.m3primary
                            border.width: 1
                            
                            implicitHeight: toolLayout.implicitHeight + Tokens.padding.normal * 2

                            ColumnLayout {
                                id: toolLayout
                                anchors.fill: parent
                                anchors.margins: Tokens.padding.normal
                                spacing: Tokens.spacing.small

                                StyledText {
                                    text: "Assistant wants to execute command(s):"
                                    font.weight: Font.DemiBold
                                    color: Colours.palette.m3onSurface
                                }

                                StyledText {
                                    text: root.getPendingToolDescriptions()
                                    wrapMode: Text.Wrap
                                    color: Colours.palette.m3onSurfaceVariant
                                    font.family: Tokens.font.family.mono
                                    font.pointSize: Tokens.font.size.small
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    Item { Layout.fillWidth: true } // spacer
                                    
                                    StyledText {
                                        visible: AIState.autoExecuteTools && root.toolExecutionCountdown > 0
                                        text: "Auto executing in " + root.toolExecutionCountdown + "s..."
                                        color: Colours.palette.m3onSurfaceVariant
                                    }

                                    TextButton {
                                        text: "Deny"
                                        onClicked: root.denyToolExecution()
                                    }

                                    TextButton {
                                        text: "Approve"
                                        onClicked: root.approveToolExecution()
                                    }
                                }
                            }
                        }

                        // Scroll to bottom FAB
                        IconButton {
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.margins: Tokens.padding.normal
                            visible: messageList.contentHeight > messageList.height && !messageList.atYEnd
                            icon: "arrow_downward"
                            type: IconButton.Filled
                            onClicked: messageList.positionViewAtEnd()
                        }
                    }
                    
                    // Input Area
                    AutoResizeInput {
                        Layout.fillWidth: true
                        
                        onSendRequested: function(text) { sendPrompt(text); }
                        onStopRequested: {
                            // Interrupt generation by setting state
                            AIState.currentStatus = AIState.Idle; 
                        }
                        onCloseRequested: {
                            root.visibilities.ai = false;
                        }
                    }
                }

                // Overlay Settings Dialog
                SettingsDialog {
                    id: settingsDialog
                    anchors.centerIn: parent
                    width: parent.width * 0.9
                    // z-index to appear above everything
                    z: 100
                }
            }
        }
    }

    property var pendingTools: []
    property int completedTools: 0
    property bool waitingForToolApproval: false
    property int toolExecutionCountdown: 0

    Timer {
        id: toolExecutionTimer
        interval: 1000
        repeat: true
        running: root.waitingForToolApproval && AIState.autoExecuteTools && root.toolExecutionCountdown > 0
        onTriggered: {
            root.toolExecutionCountdown--;
            if (root.toolExecutionCountdown <= 0) {
                root.approveToolExecution();
            }
        }
    }

    function getPendingToolDescriptions() {
        var desc = "";
        for (var i = 0; i < pendingTools.length; i++) {
            var tc = pendingTools[i];
            if (tc.function.name === "execute_command") {
                try {
                    var args = JSON.parse(tc.function.arguments);
                    desc += "$ " + args.command + "\n";
                } catch(e) {
                    desc += "Invalid command args\n";
                }
            } else {
                desc += "Tool: " + tc.function.name + "\n";
            }
        }
        return desc;
    }

    function requestToolExecution() {
        if (pendingTools.length === 0) return;
        waitingForToolApproval = true;
        if (AIState.autoExecuteTools) {
            toolExecutionCountdown = AIState.autoExecuteTimeout;
        }
    }

    function approveToolExecution() {
        waitingForToolApproval = false;
        executePendingTools();
    }

    function denyToolExecution() {
        waitingForToolApproval = false;
        completedTools = 0;
        for (var i = 0; i < pendingTools.length; i++) {
            var tc = pendingTools[i];
            finishTool(tc.id, tc.function.name, "User denied execution.");
        }
    }

    function finishTool(id, name, output) {
        AIState.appendMessage("tool", output, undefined, undefined, undefined, id, name);
        completedTools++;
        if (completedTools >= pendingTools.length) {
            pendingTools = [];
            completedTools = 0;
            Qt.callLater(function() {
                sendPrompt("", true);
            });
        }
    }

    function executePendingTools() {
        if (pendingTools.length === 0) return;
        completedTools = 0;
        for (var i = 0; i < pendingTools.length; i++) {
            var tc = pendingTools[i];
            if (tc.function.name === "execute_command") {
                try {
                    var args = JSON.parse(tc.function.arguments);
                    var cmd = args.command;
                    var qmlStr = `
                        import QtQuick
                        import Quickshell.Io
                        Process {
                            id: proc
                            command: ["sh", "-c", "` + cmd.replace(/"/g, '\\"').replace(/\n/g, ' ') + `"]
                            property string output: ""
                            stdout: StdioCollector {
                                onStreamFinished: proc.output += text
                            }
                            stderr: StdioCollector {
                                onStreamFinished: proc.output += "\\n" + text
                            }
                            onExited: function(code) {
                                root.finishTool("` + tc.id + `", "` + tc.function.name + `", proc.output);
                                proc.destroy();
                            }
                            Component.onCompleted: proc.running = true
                        }
                    `;
                    Qt.createQmlObject(qmlStr, root, "toolProcess");
                } catch (e) {
                    finishTool(tc.id, tc.function.name, "Error: " + e);
                }
            } else {
                finishTool(tc.id, tc.function.name, "Unknown tool");
            }
        }
    }

    function sendPrompt(text, isToolResponse) {
        var isFirstMessage = AIState.currentMessages.length === 0;
        var chatId = AIState.currentChatId;

        if (!isToolResponse) {
            AIState.appendMessage("user", text);
        }
        
        var providerType = "OpenAIProvider";
        if (AIState.activeProvider === "anthropic") providerType = "AnthropicProvider";
        else if (AIState.activeProvider === "google") providerType = "GoogleProvider";
        
        var retryCount = 0;
        
        function attemptSend() {
            var provider = Qt.createQmlObject('import qs.modules.ai.services; ' + providerType + ' {}', root, "dynamicProvider");
            var messages = AIState.currentMessages;
            
            provider.sendMessage(messages, function(response, toolCalls) {
                AIState.appendMessage("assistant", response, undefined, undefined, toolCalls);
                
                if (toolCalls && toolCalls.length > 0) {
                    pendingTools = toolCalls;
                    root.requestToolExecution();
                }
                
                try { provider.destroy(); } catch(e) {}
            }, function(error) {
                try { provider.destroy(); } catch(e) {}
                
                if (AIState.autoRetryOnFailure && retryCount < AIState.maxRetries) {
                    retryCount++;
                    var timer = Qt.createQmlObject('import QtQuick; Timer { interval: 1000; repeat: false }', root, "retryTimer");
                    timer.onTriggered.connect(function() {
                        timer.destroy();
                        AIState.currentStatus = AIState.Generating;
                        AIState.currentStreamText = "⚠️ Retrying... (" + retryCount + "/" + AIState.maxRetries + ")";
                        attemptSend();
                    });
                    timer.start();
                }
            });
        }
        
        attemptSend();

        if (isFirstMessage && AIState.autoGenerateTitle && !isToolResponse) {
            generateTitle(text, chatId);
        }
    }

    function generateTitle(text, chatId) {
        var promptText = AIState.titleGenerationPrompt + "\n\nUser message:\n" + text;
        var apiUrl = "";
        var reqBody = {};
        var headers = {};
        
        if (AIState.activeProvider === "anthropic") {
            apiUrl = AIState.apiUrl !== "" ? AIState.apiUrl : "https://api.anthropic.com/v1/messages";
            if (apiUrl.indexOf("messages") === -1) {
                if (!apiUrl.endsWith("/")) apiUrl += "/";
                apiUrl += "messages";
            }
            reqBody = {
                "model": AIState.activeModel,
                "messages": [{"role": "user", "content": promptText}],
                "max_tokens": 50,
                "stream": false
            };
            headers = {
                "x-api-key": AIState.apiKey,
                "anthropic-version": "2023-06-01",
                "Content-Type": "application/json"
            };
        } else if (AIState.activeProvider === "google") {
            apiUrl = AIState.apiUrl !== "" ? AIState.apiUrl : "https://generativelanguage.googleapis.com/v1beta/models/";
            if (!apiUrl.endsWith("/")) apiUrl += "/";
            apiUrl += AIState.activeModel + ":generateContent?key=" + AIState.apiKey;
            reqBody = {
                "contents": [{"parts": [{"text": promptText}]}]
            };
            headers = {
                "Content-Type": "application/json"
            };
        } else {
            apiUrl = AIState.apiUrl !== "" ? AIState.apiUrl : "https://api.openai.com/v1/chat/completions";
            if (apiUrl.indexOf("chat/completions") === -1) {
                if (!apiUrl.endsWith("/")) apiUrl += "/";
                apiUrl += "chat/completions";
            }
            reqBody = {
                "model": AIState.activeModel,
                "messages": [{"role": "user", "content": promptText}],
                "stream": false
            };
            headers = {
                "Authorization": "Bearer " + AIState.apiKey,
                "Content-Type": "application/json"
            };
        }

        var xhr = new XMLHttpRequest();
        xhr.open("POST", apiUrl);
        for (var key in headers) {
            xhr.setRequestHeader(key, headers[key]);
        }
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var json = JSON.parse(xhr.responseText);
                        var title = "New Chat";
                        if (AIState.activeProvider === "anthropic") {
                            if (json.content && json.content.length > 0) {
                                title = json.content[0].text.replace(/^["']|["']$/g, '').trim();
                            }
                        } else if (AIState.activeProvider === "google") {
                            if (json.candidates && json.candidates.length > 0 && json.candidates[0].content && json.candidates[0].content.parts.length > 0) {
                                title = json.candidates[0].content.parts[0].text.replace(/^["']|["']$/g, '').trim();
                            }
                        } else {
                            if (json.choices && json.choices.length > 0 && json.choices[0].message) {
                                title = json.choices[0].message.content.replace(/^["']|["']$/g, '').trim();
                            }
                        }
                        if (title.length > 50) title = title.substring(0, 50) + "...";
                        AIState.updateChatTitle(chatId, title);
                    } catch (e) {
                        console.error("Title generation parse error:", e);
                    }
                } else {
                    console.error("Title generation HTTP error:", xhr.status, xhr.responseText);
                }
            }
        };
        xhr.send(JSON.stringify(reqBody));
    }
}