pragma ComponentBehavior: Bound

import QtQuick
import Caelestia
import Caelestia.Config
import qs.modules.ai.config

QtObject {
    id: root

    // Override these in subclasses
    property string apiUrl: ""
    signal toolCallsUpdated(var toolCalls)
    
    function buildRequest(messages) {
        return {};
    }

    function parseChunk(chunkData) {
        return "";
    }

    function sendMessage(messages, onComplete, onError) {
        var reqBody = buildRequest(messages);
        var self = this;
        
        var headers = {
            "Authorization": "Bearer " + getApiKey(),
            "Accept": "text/event-stream",
            "Content-Type": "application/json"
        };

        AIState.currentStatus = AIState.Generating;
        AIState.currentStreamText = "";
        
        var currentResponse = "";

        var onChunkCallback = function(dataStr) {
            var lines = dataStr.split("\n");
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                if (line.startsWith("data: ")) {
                    var data = line.substring(6);
                    if (data === "[DONE]") {
                        onComplete(currentResponse, self.activeToolCalls ? Object.values(self.activeToolCalls) : undefined);
                        AIState.currentStatus = AIState.Idle;
                        return;
                    }
                    try {
                        var newText = self.parseChunk(data);
                        if (newText && newText.length > 0) {
                            currentResponse += newText;
                            AIState.currentStreamText = currentResponse;
                        }
                    } catch (e) {
                        console.error("Failed to parse chunk:", data, "Error:", e);
                    }
                }
            }
        };

        var onErrorCallback = function(err) {
            AIState.currentStatus = AIState.Error;
            AIState.currentErrorText = err;
            if (onError) onError(err);
        };

        var onFinishedCallback = function() {
            if (AIState.currentStatus === AIState.Generating) {
                onComplete(currentResponse, self.activeToolCalls ? Object.values(self.activeToolCalls) : undefined);
                AIState.currentStatus = AIState.Idle;
            }
        };

        try {
            Requests.postStream(apiUrl, JSON.stringify(reqBody), onChunkCallback, onErrorCallback, headers, onFinishedCallback);
        } catch (e) {
            console.error("Requests.postStream failed (missing C++ plugin). Falling back to pure QML XMLHttpRequest.");
            var xhr = new XMLHttpRequest();
            xhr.open("POST", apiUrl);
            for (var key in headers) {
                xhr.setRequestHeader(key, headers[key]);
            }
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200) {
                        onChunkCallback(xhr.responseText);
                        onFinishedCallback();
                    } else {
                        onErrorCallback("HTTP Error " + xhr.status + ": " + xhr.responseText);
                    }
                }
            };
            xhr.send(JSON.stringify(reqBody));
        }
    }
    
    function getApiKey() {
        return AIState.apiKey;
    }
}
