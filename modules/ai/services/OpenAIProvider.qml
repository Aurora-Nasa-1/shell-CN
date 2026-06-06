pragma ComponentBehavior: Bound

import QtQuick
import Caelestia
import Caelestia.Config
import qs.modules.ai.config

AIProvider {
    id: root

    apiUrl: {
        var base = AIState.apiUrl !== "" ? AIState.apiUrl : "https://api.openai.com/v1/chat/completions";
        if (base.indexOf("chat/completions") === -1) {
            if (!base.endsWith("/")) base += "/";
            base += "chat/completions";
        }
        return base;
    }

    property var activeToolCalls: ({})

    function buildRequest(messages) {
        var formattedMessages = [];
        
        // Always inject system prompt
        formattedMessages.push({
            "role": "system",
            "content": AIState.systemPrompt
        });
        
        for (var i = 0; i < messages.length; i++) {
            var msg = {
                "role": messages[i].role,
                "content": messages[i].text || ""
            };
            if (messages[i].tool_calls) {
                msg.tool_calls = messages[i].tool_calls;
            }
            if (messages[i].tool_call_id) {
                msg.tool_call_id = messages[i].tool_call_id;
                msg.name = messages[i].name;
            }

            if (messages[i].base64Data && messages[i].base64Data !== "") {
                msg.content = [
                    { "type": "text", "text": messages[i].text || "" },
                    { "type": "image_url", "image_url": { "url": "data:image/png;base64," + messages[i].base64Data } }
                ];
            }
            formattedMessages.push(msg);
        }
        
        var req = {
            "model": AIState.activeModel,
            "messages": formattedMessages,
            "stream": true,
            "tools": [
                {
                    "type": "function",
                    "function": {
                        "name": "execute_command",
                        "description": "Execute a shell command on the local system",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "command": {
                                    "type": "string",
                                    "description": "The command to execute"
                                }
                            },
                            "required": ["command"]
                        }
                    }
                }
            ]
        };
        return req;
    }

    function parseChunk(chunkData) {
        if (!chunkData || chunkData.length === 0) return "";
        try {
            var json = JSON.parse(chunkData);
            if (json.choices && json.choices.length > 0) {
                var delta = json.choices[0].delta;
                
                if (delta.tool_calls) {
                    for (var i = 0; i < delta.tool_calls.length; i++) {
                        var tc = delta.tool_calls[i];
                        if (tc.id) {
                            activeToolCalls[tc.index] = {
                                "id": tc.id,
                                "type": tc.type,
                                "function": {
                                    "name": tc.function.name,
                                    "arguments": tc.function.arguments || ""
                                }
                            };
                        } else if (activeToolCalls[tc.index]) {
                            activeToolCalls[tc.index].function.arguments += (tc.function.arguments || "");
                        }
                    }
                    root.toolCallsUpdated(activeToolCalls);
                }

                if (delta && delta.content) {
                    return delta.content;
                }
            }
        } catch (e) {
            console.error("OpenAI Parse Error:", e, chunkData);
        }
        return "";
    }
}
