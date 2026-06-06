pragma ComponentBehavior: Bound

import QtQuick
import Caelestia
import Caelestia.Config
import qs.modules.ai.config

AIProvider {
    id: root

    apiUrl: {
        var base = AIState.apiUrl !== "" ? AIState.apiUrl : "https://api.anthropic.com/v1/messages";
        if (base.indexOf("messages") === -1) {
            if (!base.endsWith("/")) base += "/";
            base += "messages";
        }
        return base;
    }

    function buildRequest(messages) {
        var formattedMessages = [];
        
        for (var i = 0; i < messages.length; i++) {
            if (messages[i].base64Data && messages[i].base64Data !== "") {
                formattedMessages.push({
                    "role": messages[i].role,
                    "content": [
                        { "type": "image", "source": { "type": "base64", "media_type": "image/png", "data": messages[i].base64Data } },
                        { "type": "text", "text": messages[i].text }
                    ]
                });
            } else {
                formattedMessages.push({
                    "role": messages[i].role,
                    "content": messages[i].text
                });
            }
        }
        
        return {
            "model": AIState.activeModel,
            "messages": formattedMessages,
            "system": AIState.systemPrompt,
            "max_tokens": 4096,
            "stream": true
        };
    }

    function sendMessage(messages, onComplete, onError) {
        var reqBody = buildRequest(messages);
        
        var headers = {
            "x-api-key": getApiKey(),
            "anthropic-version": "2023-06-01",
            "Accept": "text/event-stream"
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
                        return;
                    }
                    try {
                        var json = JSON.parse(data);
                        if (json.type === "content_block_delta" && json.delta && json.delta.text) {
                            currentResponse += json.delta.text;
                            AIState.currentStreamText = currentResponse;
                        } else if (json.type === "message_stop") {
                            onComplete(currentResponse);
                            AIState.currentStatus = AIState.Idle;
                        } else if (json.type === "error") {
                            onErrorCallback(json.error.message);
                        }
                    } catch (e) {
                        // ignore unparseable chunks
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
                onComplete(currentResponse);
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
}
