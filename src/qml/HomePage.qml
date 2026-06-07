import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform

Item {
    id: root

    SystemPalette { id: sysPalette }

    property string result: ""
    signal openSettings()
    readonly property real contentMargin: 5
    readonly property real layoutSpacing: 5
    readonly property real availableContentHeight: Math.max(0, root.height - 2 * contentMargin - layoutSpacing)

    function sendTranslation()
    {
        if (!sourceInput.text || !sourceInput.text.trim()) {
            root.result = qsTr("Please enter some text to translate.");
            return;
        }

        var currentConfig = deepSeekConfigManager.loadConfig();
        var apiUrl = (currentConfig && currentConfig.base_url) ? currentConfig.base_url : "https://api.deepseek.com";
        apiUrl = apiUrl.replace(/\/+$/, "");
        if (!/\/chat\/completions$/i.test(apiUrl) && !/\/v1\/chat\/completions$/i.test(apiUrl))
            apiUrl += "/chat/completions";

        var xhr = new XMLHttpRequest();
        xhr.open("POST", apiUrl, true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", "Bearer " + ((currentConfig && currentConfig.api_key) ? currentConfig.api_key : ""));

        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return;

            if (xhr.status >= 200 && xhr.status < 300) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    var text = "";
                    if (data && data.choices && data.choices.length > 0) {
                        if (data.choices[0].message && data.choices[0].message.content)
                            text = data.choices[0].message.content;
                        else if (data.choices[0].text)
                            text = data.choices[0].text;
                    }
                    root.result = text || xhr.responseText;
                } catch (e) {
                    root.result = xhr.responseText || qsTr("Failed to parse the translation response.");
                }
            } else {
                root.result = qsTr("Request failed: ") + xhr.status + " " + (xhr.statusText || "") + "\n" + (xhr.responseText || "");
            }
        };

        var payload = {
            model: (currentConfig && currentConfig.model) ? currentConfig.model : "deepseek-v4-flash",
            messages: [
                {
                    role: "system",
                    content: (currentConfig && currentConfig.system_prompt) ? currentConfig.system_prompt : "你是专业翻译引擎，逐句忠实翻译，不添加解释"
                },
                {
                    role: "user",
                    content: sourceInput.text
                }
            ],
            temperature: (currentConfig && currentConfig.temperature !== undefined) ? currentConfig.temperature : 0.2,
            top_p: (currentConfig && currentConfig.top_p !== undefined) ? currentConfig.top_p : 1.0,
            max_tokens: (currentConfig && currentConfig.max_tokens) ? currentConfig.max_tokens : 4096
        };

        xhr.send(JSON.stringify(payload));
    }

    Rectangle {
        anchors.fill: parent
        color: sysPalette.window
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5
        spacing: root.layoutSpacing

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.availableContentHeight * 0.25
            Layout.minimumHeight: 0
            radius: 0
            color: sysPalette.base
            border.color: sysPalette.mid
            border.width: 1

            Item {
                id: actionButtons
                z: 2
                anchors.fill: parent

                ToolButton {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 4
                    text: "⚙"
                    font.pixelSize: Math.max(11, parent && parent.font ? parent.font.pixelSize : Qt.application.font.pixelSize)
                    flat: true
                    focusPolicy: Qt.NoFocus
                    padding: 4
                    onClicked: root.openSettings()
                }

                ToolButton {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 4
                    text: "➤"
                    font.pixelSize: Math.max(11, parent && parent.font ? parent.font.pixelSize : Qt.application.font.pixelSize)
                    flat: true
                    focusPolicy: Qt.NoFocus
                    padding: 4
                    onClicked: root.sendTranslation()
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 5

                Label {
                    text: qsTr("Source text")
                    color: sysPalette.text
                    font.pixelSize: Math.max(11, parent && parent.font ? parent.font.pixelSize : Qt.application.font.pixelSize)
                }

                TextArea {
                    id: sourceInput
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    wrapMode: TextEdit.WordWrap
                    color: sysPalette.text
                    placeholderText: qsTr("Paste or type the text you want translated...")
                    background: Item {}
                    Keys.onPressed: (event) => {
                        if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && !(event.modifiers & Qt.ControlModifier)) {
                            root.sendTranslation();
                            event.accepted = true;
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.availableContentHeight * 0.75
            Layout.minimumHeight: 0
            radius: 0
            color: sysPalette.base
            border.color: sysPalette.mid
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 5

                Label {
                    text: qsTr("Translation result")
                    color: sysPalette.text
                    font.pixelSize: Math.max(11, parent && parent.font ? parent.font.pixelSize : Qt.application.font.pixelSize)
                }

                TextArea {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    readOnly: true
                    wrapMode: TextEdit.WordWrap
                    color: sysPalette.text
                    text: root.result || qsTr("")
                    background: Item {}
                }
            }
        }
    }
}
