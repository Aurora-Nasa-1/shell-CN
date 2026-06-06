pragma ComponentBehavior: Bound

import QtQuick
import Caelestia
import Caelestia.Config
import qs.modules.ai.config

AIProvider {
    id: root

    apiUrl: {
        var base = AIState.apiUrl !== "" ? AIState.apiUrl : "https://generativelanguage.googleapis.com/v1beta";
        if (base.indexOf(":streamGenerateContent") === -1) {
            if (!base.endsWith("/")) base += "/";
            if (base.indexOf("models/") === -1) {
                base += "models/" + AIState.activeModel;
            }
            base += ":streamGenerateContent";
        }
        if (base.indexOf("?key=") === -1 && base.indexOf("&key=") === -1) {
            base += "?key=" + getApiKey();
        }
        return base;
    }

    function buildRequest(messages) {
        var contents = [];
        
        for (var i = 0; i < messages.length; i++) {
            var msgParts = [{ "text": messages[i].text }];
            if (messages[i].base64Data && messages[i].base64Data !== "") {
                msgParts.push({
                    "inlineData": {
                        "mimeType": "image/png",
                        "data": messages[i].base64Data
                    }
                });
            }
            contents.push({
                "role": messages[i].role === "assistant" ? "model" : "user",
                "parts": msgParts
            });
        }
        
        var payload = {
            "contents": contents,
            "tools": [{ "googleSearch": {} }]
        };
        
        if (AIState.systemPrompt !== "") {
            payload["systemInstruction"] = {
                "parts": [{ "text": AIState.systemPrompt }]
            };
        }
        
        return payload;
    }

    function sendMessage(messages, onComplete, onError) {
        var reqBody = buildRequest(messages);
        
        var headers = {
            "Content-Type": "application/json",
            "x-goog-api-key": getApiKey(),
            "Authorization": "Bearer " + getApiKey()
        };

        AIState.currentStatus = AIState.Generating;
        AIState.currentStreamText = "";
        
        var currentResponse = "";

        var onChunkCallback = function(dataStr) {
            // Google's stream chunks are formatted as SSE starting with `data: `
            var lines = dataStr.split("\n");
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                if (line.startsWith("data: ")) {
                    var data = line.substring(6);
                    try {
                        var json = JSON.parse(data);
                        if (json.candidates && json.candidates.length > 0) {
                            var parts = json.candidates[0].content.parts;
                            if (parts && parts.length > 0) {
                                currentResponse += parts[0].text;
                                AIState.currentStreamText = currentResponse;
                            }
                        } else if (json.choices && json.choices.length > 0) {
                            // Support OpenAI-compatible proxies incorrectly configured as Google provider
                            var delta = json.choices[0].delta;
                            if (delta && delta.content) {
                                currentResponse += delta.content;
                                AIState.currentStreamText = currentResponse;
                            }
                        }
                    } catch (e) {
                        // ignore parse errors or [DONE] equivalents if any
                    }
                } else if (line.startsWith("[") || line.startsWith(",") || line.startsWith("{")) {
                     // Sometimes Google API sends JSON array chunks directly
                     try {
                        var chunk = JSON.parse(line.endsWith(",") ? line.substring(0, line.length - 1) : line);
                        if (chunk.candidates && chunk.candidates.length > 0) {
                            var parts2 = chunk.candidates[0].content.parts;
                            if (parts2 && parts2.length > 0) {
                                currentResponse += parts2[0].text;
                                AIState.currentStreamText = currentResponse;
                            }
                        }
                     } catch(e) {}
                }
            }
        };

        var onErrorCallback = function(err) {
            AIState.currentStatus = AIState.Error;
            AIState.currentErrorText = err;
            if (onError) onError(err);
        };

        var onFinishedCallback = function() {
            if(AIState.currentStatus === AIState.Generating) {
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
