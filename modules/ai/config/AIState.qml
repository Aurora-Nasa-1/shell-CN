pragma Singleton
import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import Caelestia

QtObject {
    id: root

    enum Status {
        Idle,
        Generating,
        Error
    }

    property int currentStatus: AIState.Idle
    
    // Config properties backed by Settings
    property string activeProvider: settings.activeProvider
    property string activeModel: settings.activeModel
    property string apiKey: settings.apiKey
    property string apiUrl: settings.apiUrl
    property string systemPrompt: settings.systemPrompt
    property bool autoGenerateTitle: settings.autoGenerateTitle
    property string titleGenerationPrompt: settings.titleGenerationPrompt
    property bool autoExecuteTools: settings.autoExecuteTools
    property int autoExecuteTimeout: settings.autoExecuteTimeout
    property bool autoRetryOnFailure: settings.autoRetryOnFailure
    property int maxRetries: settings.maxRetries
    
    onActiveProviderChanged: settings.activeProvider = activeProvider
    onActiveModelChanged: settings.activeModel = activeModel
    onApiKeyChanged: settings.apiKey = apiKey
    onApiUrlChanged: settings.apiUrl = apiUrl
    onSystemPromptChanged: settings.systemPrompt = systemPrompt
    onAutoGenerateTitleChanged: settings.autoGenerateTitle = autoGenerateTitle
    onTitleGenerationPromptChanged: settings.titleGenerationPrompt = titleGenerationPrompt
    onAutoExecuteToolsChanged: settings.autoExecuteTools = autoExecuteTools
    onAutoExecuteTimeoutChanged: settings.autoExecuteTimeout = autoExecuteTimeout
    onAutoRetryOnFailureChanged: settings.autoRetryOnFailure = autoRetryOnFailure
    onMaxRetriesChanged: settings.maxRetries = maxRetries
    
    property bool settingsOpen: false
    
    // Settings backend for persistence
    property Settings settings: Settings {
        category: "AI"
        
        property string activeProvider: "openai"
        property string activeModel: "gpt-4o"
        property string apiKey: ""
        property string apiUrl: ""
        property string systemPrompt: "You are a helpful assistant."
        property string chatsJson: "[]"
        property string messageHistoryJson: "[]" // Kept for migration
        property bool autoGenerateTitle: true
        property string titleGenerationPrompt: "Summarize this conversation into a short title (max 5 words)."
        property bool autoExecuteTools: false
        property int autoExecuteTimeout: 10
        property bool autoRetryOnFailure: false
        property int maxRetries: 3
    }
    
    // Conversation State
    property var chats: []
    property string currentChatId: ""
    property var currentMessages: []
    
    // Persisted scroll position for message list
    property real scrollPosition: 0
    
    function _updateCurrentMessages() {
        for (var i = 0; i < chats.length; i++) {
            if (chats[i].id === currentChatId) {
                currentMessages = chats[i].messages || [];
                return;
            }
        }
        currentMessages = [];
    }

    onChatsChanged: {
        settings.chatsJson = JSON.stringify(chats);
        _updateCurrentMessages();
    }
    
    onCurrentChatIdChanged: {
        _updateCurrentMessages();
    }
    
    Component.onCompleted: {
        try {
            var loadedChats = JSON.parse(settings.chatsJson);
            if (Array.isArray(loadedChats) && loadedChats.length > 0) {
                chats = loadedChats;
                currentChatId = chats[0].id;
            } else {
                // Try migrating old history
                try {
                    var oldHist = JSON.parse(settings.messageHistoryJson);
                    if (Array.isArray(oldHist) && oldHist.length > 0) {
                        var newId = "chat_" + Date.now();
                        chats = [{ "id": newId, "title": "Migrated Chat", "messages": oldHist }];
                        currentChatId = newId;
                    }
                } catch (e2) {}
            }
        } catch (e) {
            chats = [];
        }
    }
    
    // Current streaming message
    property string currentStreamText: ""
    property string currentErrorText: ""
    
    // Screenshot Process
    function startScreenshot() {
        var path = "/tmp/ai_screenshot_" + Date.now() + ".png";
        
        // Completely bypass QML Process and use raw detached system execution
        Quickshell.execDetached(["sh", "-c", "sleep 0.5 && grim -g \"$(slurp)\" " + path + " && base64 -w 0 " + path + " > " + path + ".b64 && notify-send 'AI Assistant' 'Screenshot attached'"]);
        
        // Use a Timer to poll for the base64 file, avoiding any process exit signal issues
        var timer = Qt.createQmlObject('import QtQuick; Timer { interval: 1000; repeat: true }', root, "screenshotPollTimer");
        
        // Prevent infinite polling if user cancels slurp (stop after 30 seconds)
        var pollCount = 0;
        
        timer.onTriggered.connect(function() {
            pollCount++;
            if (pollCount > 30) {
                timer.stop();
                timer.destroy();
                return;
            }
            
            try {
                Requests.get("file://" + path + ".b64", function(b64Data) {
                    if (b64Data && b64Data.trim().length > 0) {
                        root.appendMessage("user", "Attached screenshot", path, b64Data.trim());
                        timer.stop();
                        timer.destroy();
                    }
                }, function(err) {
                    // File might not exist yet, keep polling
                });
            } catch(e) {}
        });
        timer.start();
    }
    
    function createNewChat() {
        root.scrollPosition = 0;
        var newId = "chat_" + Date.now();
        var newChat = { "id": newId, "title": "New Chat", "messages": [] };
        var c = chats.slice();
        c.unshift(newChat);
        chats = c;
        currentChatId = newId;
    }
    
    function switchChat(chatId) {
        root.scrollPosition = 0;
        currentChatId = chatId;
    }
    
    function deleteChat(chatId) {
        var c = chats.filter(function(chat) { return chat.id !== chatId; });
        chats = c;
        if (currentChatId === chatId) {
            currentChatId = chats.length > 0 ? chats[0].id : "";
        }
    }
    
    function appendMessage(role, text, imagePath, base64Data, tool_calls, tool_call_id, name) {
        if (!currentChatId) {
            createNewChat();
        }
        var c = chats.slice();
        var chatIndex = -1;
        for (var i = 0; i < c.length; i++) {
            if (c[i].id === currentChatId) {
                chatIndex = i;
                break;
            }
        }
        if (chatIndex !== -1) {
            var chat = c[chatIndex];
            var msgs = chat.messages ? chat.messages.slice() : [];
            var msg = { "role": role, "text": text };
            if (imagePath !== undefined && imagePath !== null && imagePath !== "") {
                msg.imagePath = imagePath;
            }
            if (base64Data !== undefined && base64Data !== null && base64Data !== "") {
                msg.base64Data = base64Data;
            }
            if (tool_calls !== undefined && tool_calls !== null) {
                msg.tool_calls = tool_calls;
            }
            if (tool_call_id !== undefined && tool_call_id !== null) {
                msg.tool_call_id = tool_call_id;
            }
            if (name !== undefined && name !== null) {
                msg.name = name;
            }
            msgs.push(msg);
            chat.messages = msgs;
            c[chatIndex] = chat;
            chats = c;
        }
    }
    
    function clearHistory() {
        var c = chats.slice();
        for (var i = 0; i < c.length; i++) {
            if (c[i].id === currentChatId) {
                c[i].messages = [];
                break;
            }
        }
        chats = c;
        currentStreamText = "";
        currentStatus = AIState.Idle;
    }
    
    function popLastMessage() {
        var c = chats.slice();
        for (var i = 0; i < c.length; i++) {
            if (c[i].id === currentChatId) {
                if (c[i].messages && c[i].messages.length > 0) {
                    var msgs = c[i].messages.slice();
                    msgs.pop();
                    c[i].messages = msgs;
                    chats = c;
                }
                break;
            }
        }
    }
    
    function updateChatTitle(chatId, title) {
        var c = chats.slice();
        for (var i = 0; i < c.length; i++) {
            if (c[i].id === chatId) {
                c[i].title = title;
                chats = c;
                break;
            }
        }
    }
}