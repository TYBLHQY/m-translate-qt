import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Qt.labs.platform

Item {
    id: root

    SystemPalette { id: sysPalette }

    property string result: ""
    property bool isSending: false
    property bool hasError: false
    signal openSettings()
    readonly property real contentMargin: 5
    readonly property real layoutSpacing: 5
    readonly property real availableContentHeight: Math.max(0, root.height - 2 * contentMargin - layoutSpacing)

    function sendTranslation()
    {
        if (!sourceInput.text || !sourceInput.text.trim()) {
            root.isSending = false;
            root.hasError = true;
            root.result = "Please enter some text to translate.";
            return;
        }

        root.isSending = true;
        root.hasError = false;
        root.result = "";

        var currentConfig = deepSeekConfigManager.loadConfig();
        var apiUrl = (currentConfig && currentConfig.base_url) ? currentConfig.base_url : "https://api.deepseek.com";
        apiUrl = apiUrl.replace(/\/+$/, "");
        if (!/\/chat\/completions$/i.test(apiUrl) && !/\/v1\/chat\/completions$/i.test(apiUrl))
            apiUrl += "/chat/completions";

        var xhr = new XMLHttpRequest();
        xhr.timeout = 30000;
        xhr.open("POST", apiUrl, true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Accept", "application/json");
        xhr.setRequestHeader("Authorization", "Bearer " + ((currentConfig && currentConfig.api_key) ? currentConfig.api_key : ""));

        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return;

            root.isSending = false;

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
                    root.hasError = false;
                    root.result = text || xhr.responseText || "No translation returned by the server.";
                } catch (e) {
                    root.hasError = true;
                    root.result = xhr.responseText || "Failed to parse the translation response.";
                }
            } else {
                root.hasError = true;
                root.result = "Request failed: " + xhr.status + " " + (xhr.statusText || "") + "\n" + (xhr.responseText || "Please check the API settings and try again.");
            }
        };

        xhr.onerror = function () {
            root.isSending = false;
            root.hasError = true;
            root.result = "Network error. Please check your connection and API settings, then try again.";
        };

        xhr.ontimeout = function () {
            root.isSending = false;
            root.hasError = true;
            root.result = "Request timed out. Please try again.";
        };

        var payload = {
            model: (currentConfig && currentConfig.model) ? currentConfig.model : "deepseek-v4-flash",
            messages: [
                {
                    role: "user",
                    content: sourceInput.text
                }
            ],
            temperature: (currentConfig && currentConfig.temperature !== undefined) ? currentConfig.temperature : 0.2
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
                z: 1
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: 36

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
                    id: sendButton
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 4
                    text: "➤"
                    font.pixelSize: Math.max(11, parent && parent.font ? parent.font.pixelSize : Qt.application.font.pixelSize)
                    flat: true
                    focusPolicy: Qt.NoFocus
                    padding: 4
                    enabled: !root.isSending
                    onClicked: root.sendTranslation()
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 5

                Label {
                    text: "Source text"
                    color: sysPalette.text
                    font.pixelSize: Math.max(11, parent && parent.font ? parent.font.pixelSize : Qt.application.font.pixelSize)
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    TextArea {
                        id: sourceInput
                        width: parent.width
                        height: parent.height
                        wrapMode: TextEdit.WordWrap
                        color: sysPalette.text
                        enabled: !root.isSending
                        placeholderText: "type here ..."
                        focus: true
                        activeFocusOnPress: true
                        Keys.onPressed: (event) => {
                            if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) &&
                                !(event.modifiers & Qt.ShiftModifier) &&
                                !(event.modifiers & Qt.ControlModifier)) {
                                root.sendTranslation();
                                event.accepted = true;
                            }
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
                    text: "Translation result"
                    color: sysPalette.text
                    font.pixelSize: Math.max(11, parent && parent.font ? parent.font.pixelSize : Qt.application.font.pixelSize)
                }

                RowLayout {
                    visible: root.isSending || root.hasError
                    spacing: 6

                    BusyIndicator {
                        visible: root.isSending
                        running: root.isSending
                        implicitWidth: 24
                        implicitHeight: 24
                    }

                    Label {
                        text: root.isSending ? "Translating..." : "Translation failed"
                        color: root.hasError ? "#c0392b" : sysPalette.text
                        font.pixelSize: Math.max(11, parent && parent.font ? parent.font.pixelSize : Qt.application.font.pixelSize)
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    TextArea {
                        width: parent.width
                        height: parent.height
                        readOnly: true
                        wrapMode: TextEdit.WordWrap
                        color: sysPalette.text
                        text: root.result || ""
                    }
                }
            }
        }
    }
}
