import QtQuick
import QtQuick.Controls
import m.translate.qt 1.0
import QtQuick.Layouts
import Qt.labs.platform

Item {
    id: root

    SystemPalette { id: sysPalette }

    property string result: ""
    property bool isSending: false
    property bool hasError: false
    property var currentConfig: DeepSeekConfigManager.loadConfig()
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

        var currentConfig = root.currentConfig || DeepSeekConfigManager.loadConfig();
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

        var firstLanguage = (currentConfig && currentConfig.first_language) ? currentConfig.first_language : "en";
        var secondLanguage = (currentConfig && currentConfig.second_language) ? currentConfig.second_language : "en";

        var payload = {
            model: (currentConfig && currentConfig.model) ? currentConfig.model : "deepseek-v4-flash",
            messages: [
                {
                    role: "system",
                    content: "You are a professional translation assistant. Use " + firstLanguage + " as the primary language context and " + secondLanguage + " as the target language. Preserve the original meaning, tone, and formatting."
                },
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

        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: root.availableContentHeight * 0.25
            Layout.minimumHeight: 0
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            TextArea {
                id: sourceInput
                anchors.fill: parent
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

        Rectangle {
            id: actionBar
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "transparent"
            border.color: "transparent"
            border.width: 0

            RowLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 5

                ToolButton {
                    id: settingsButton
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    Layout.alignment: Qt.AlignVCenter
                    text: "⚙"
                    flat: true
                    focusPolicy: Qt.NoFocus
                    background: Rectangle {
                        color: sysPalette.button
                        border.color: sysPalette.mid
                        border.width: 1
                        radius: 4
                    }
                    onClicked: root.openSettings()
                }

                ComboBox {
                    id: providerCombo
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    implicitHeight: 32
                    background: Rectangle {
                        color: sysPalette.base
                        border.color: sysPalette.mid
                        border.width: 1
                        radius: 4
                    }
                    model: (root.currentConfig && root.currentConfig.providers) ? root.currentConfig.providers
                        .filter(function (item) { return item.enabled !== false; })
                        .map(function (item) { return item.name || item.id || "Provider"; }) : ["DeepSeek"]
                    currentIndex: (() => {
                        var providers = (root.currentConfig && root.currentConfig.providers) ? root.currentConfig.providers.filter(function (item) { return item.enabled !== false; }) : [];
                        var activeId = root.currentConfig && root.currentConfig.active_provider ? root.currentConfig.active_provider : (providers[0] && (providers[0].id || providers[0].uuid));
                        var index = providers.findIndex(function (item) {
                            return item.id === activeId || item.uuid === activeId;
                        });
                        return index >= 0 ? index : 0;
                    })()
                    onActivated: {
                        var providers = (root.currentConfig && root.currentConfig.providers) ? root.currentConfig.providers.filter(function (item) { return item.enabled !== false; }) : [];
                        var selected = providers[currentIndex];
                        if (!selected) return;
                        root.currentConfig.active_provider = selected.id || selected.uuid;
                        DeepSeekConfigManager.saveConfig(root.currentConfig);
                        root.currentConfig = DeepSeekConfigManager.loadConfig();
                    }
                }

                ToolButton {
                    id: sendButton
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    Layout.alignment: Qt.AlignVCenter
                    text: "➤"
                    flat: true
                    focusPolicy: Qt.NoFocus
                    enabled: !root.isSending
                    background: Rectangle {
                        color: sysPalette.button
                        border.color: sysPalette.mid
                        border.width: 1
                        radius: 4
                    }
                    onClicked: root.sendTranslation()
                }
            }
        }

        RowLayout {
            visible: root.isSending || root.hasError
            spacing: 5

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
            Layout.minimumHeight: 0
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            TextArea {
                anchors.fill: parent
                readOnly: true
                wrapMode: TextEdit.WordWrap
                color: sysPalette.text
                text: root.result || ""
            }
        }
    }
}
