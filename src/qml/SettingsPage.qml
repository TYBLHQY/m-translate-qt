import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import "components" as Components

Item {
    id: root

    SystemPalette { id: sysPalette }

    function generateUuid()
    {
        return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function (c) {
            var r = Math.random() * 16 | 0;
            var v = c === "x" ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    function providerTemplateDefaults(templateName)
    {
        if (templateName === "openai") {
            return {
                id: "openai",
                name: "OpenAI",
                description: "OpenAI chat models",
                base_url: "https://api.openai.com/v1",
                api_key: "",
                model: "gpt-4o-mini",
                temperature: 0.2,
                provider_options: "",
                headers: "{}",
                features: {
                    page_translation: true,
                    video_subtitles: true,
                    selection_toolbar_translation: true,
                    input_translation: true,
                    language_detection: true,
                    dictionary: true
                }
            };
        }

        return {
            id: "deepseek",
            name: "DeepSeek",
            description: "DeepSeek chat and reasoning models",
            base_url: "https://api.deepseek.com",
            api_key: "",
            model: "deepseek-v4-flash",
            temperature: 0.2,
            provider_options: "",
            headers: "{}",
            features: {
                page_translation: true,
                video_subtitles: true,
                selection_toolbar_translation: true,
                input_translation: true,
                language_detection: true,
                dictionary: true
            }
        };
    }

    function createProviderInstance(templateName)
    {
        if (!root.config) return;

        var template = providerTemplateDefaults(templateName);
        var providers = (root.config.providers || []).slice();
        var candidateName = template.name;
        var suffix = 1;

        while (providers.some(function (item) {
            return (item.name || item.id || "").toLowerCase() === candidateName.toLowerCase();
        })) {
            suffix += 1;
            candidateName = template.name + " " + suffix;
        }

        var provider = {
            id: generateUuid(),
            uuid: generateUuid(),
            name: candidateName,
            description: template.description,
            base_url: template.base_url,
            api_key: template.api_key,
            model: template.model,
            temperature: template.temperature,
            provider_options: template.provider_options,
            headers: template.headers,
            enabled: true,
            features: JSON.parse(JSON.stringify(template.features || {}))
        };

        providers.push(provider);
        root.config.providers = providers;
        root.config.active_provider = provider.id;
        root.persistConfig();
    }

    function currentProviderIndex()
    {
        if (!root.config || !root.config.providers) return -1;

        var activeId = root.config.active_provider || "deepseek";
        return root.config.providers.findIndex(function (item) {
            return item.id === activeId || item.uuid === activeId;
        });
    }

    function selectedProvider()
    {
        var index = root.currentProviderIndex();
        if (index >= 0 && root.config && root.config.providers && root.config.providers[index])
            return root.config.providers[index];

        return root.activeProvider();
    }

    function removeSelectedProvider()
    {
        if (!root.config || !root.config.providers) return;

        var index = root.currentProviderIndex();
        if (index < 0) return;

        var providers = root.config.providers.slice();
        providers.splice(index, 1);
        if (providers.length === 0) {
            root.config.providers = [];
            root.config.active_provider = "deepseek";
            root.persistConfig();
            return;
        }

        root.config.providers = providers;
        root.config.active_provider = providers[0].id || providers[0].uuid || "deepseek";
        root.persistConfig();
    }

    function activeProvider()
    {
        if (!root.config) return null;

        var providers = root.config.providers || [];
        if (providers.length === 0) {
            providers = [{
                id: "deepseek",
                name: "DeepSeek",
                description: "DeepSeek chat and reasoning models",
                base_url: root.config.base_url || "https://api.deepseek.com",
                api_key: root.config.api_key || "",
                model: root.config.model || "deepseek-v4-flash",
                temperature: root.config.temperature ?? 0.2,
                provider_options: root.config.provider_options || "",
                headers: root.config.headers || "{}",
                features: {
                    page_translation: true,
                    video_subtitles: true,
                    selection_toolbar_translation: true,
                    input_translation: true,
                    language_detection: true,
                    dictionary: true
                }
            }];
            root.config.providers = providers;
        }

        var activeId = root.config.active_provider || "deepseek";
        for (var i = 0; i < providers.length; ++i) {
            if (providers[i].id === activeId || providers[i].uuid === activeId)
                return providers[i];
        }

        providers.forEach(function (item) {
            if (item.enabled !== false) item.enabled = true;
        });

        return providers[0] || null;
    }

    function updateActiveProvider(field, value)
    {
        var provider = root.activeProvider();
        if (!provider || !root.config) return;

        provider[field] = value;
        root.config.providers = (root.config.providers || []).slice();
        root.persistConfig();
    }

    function setFeature(key, value)
    {
        var provider = root.activeProvider();
        if (!provider || !root.config) return;

        provider.features = provider.features || {};
        provider.features[key] = value;
        root.config.providers = (root.config.providers || []).slice();
        root.persistConfig();
    }

    function testConnection()
    {
        var provider = root.activeProvider();
        if (!provider) {
            connectionStatus.text = "No provider is available to test.";
            return;
        }

        var apiUrl = (provider.base_url || "https://api.deepseek.com").replace(/\/+$/, "");
        if (!/\/chat\/completions$/i.test(apiUrl) && !/\/v1\/chat\/completions$/i.test(apiUrl))
            apiUrl += "/chat/completions";

        var xhr = new XMLHttpRequest();
        xhr.timeout = 30000;
        xhr.open("POST", apiUrl, true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Accept", "application/json");
        xhr.setRequestHeader("Authorization", "Bearer " + (provider.api_key || ""));

        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return;

            if (xhr.status >= 200 && xhr.status < 300) {
                connectionStatus.text = "Connection test succeeded.";
            } else {
                connectionStatus.text = "Connection test failed: " + xhr.status + " " + (xhr.statusText || "");
            }
        };

        xhr.onerror = function () {
            connectionStatus.text = "Connection test failed: network error.";
        };

        xhr.ontimeout = function () {
            connectionStatus.text = "Connection test failed: request timed out.";
        };

        xhr.send(JSON.stringify({
            model: provider.model || "deepseek-v4-flash",
            messages: [{ role: "user", content: "ping" }],
            max_tokens: 8
        }));
    }

    function persistConfig()
    {
        if (root.config) {
            deepSeekConfigManager.saveConfig(root.config);
        }
    }

    property int currentSection: 0
    property var config: ({})

    signal settingsChanged()
    signal backRequested()

    Shortcut {
        sequence: "Esc"
        onActivated: root.backRequested()
    }

    Rectangle {
        anchors.fill: parent
        color: sysPalette.window
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 8

        Components.SettingsHeader {
            Layout.fillWidth: true
            title: "Settings Center"
            onBackRequested: root.backRequested()
        }

        ButtonGroup {
            id: configSectionGroup
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    "General Settings",
                    "API Settings",
                    "Shortcuts"
                ]

                Button {
                    id: sectionButton
                    checkable: true
                    checked: index === root.currentSection
                    ButtonGroup.group: configSectionGroup
                    Layout.fillWidth: true
                    text: modelData
                    onClicked: root.currentSection = index
                }
            }
        }

        ScrollView {
            id: settingsScrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth

            StackLayout {
                anchors.fill: parent
                width: parent ? parent.width : 680
                currentIndex: root.currentSection

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Components.SettingsSectionPanel {
                        sectionTitle: "Interface"

                        Components.SettingFieldRow {
                            label: "Font size"

                            SpinBox {
                                from: 9
                                to: 18
                                stepSize: 1
                                value: root.config.font_size ?? 13
                                Layout.fillWidth: true
                                onValueModified: {
                                    if (root.config) root.config.font_size = value;
                                    root.persistConfig();
                                    root.settingsChanged();
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Components.SettingsSectionPanel {
                        sectionTitle: "API Providers"

                        Components.SettingFieldRow {
                            label: "Create provider"

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                ComboBox {
                                    id: providerTemplateCombo
                                    Layout.fillWidth: true
                                    model: ["DeepSeek", "OpenAI"]
                                    currentIndex: 0
                                }

                                Button {
                                    text: "Create"
                                    onClicked: root.createProviderInstance(providerTemplateCombo.currentText.toLowerCase())
                                }
                            }
                        }

                        Components.SettingFieldRow {
                            label: "Provider instances"

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                ComboBox {
                                    id: providerCombo
                                    Layout.fillWidth: true
                                    model: (root.config && root.config.providers) ? root.config.providers.map(function (item) {
                                        var label = item.name || item.id || "Provider";
                                        return item.enabled === false ? label + " (disabled)" : label;
                                    }) : ["DeepSeek"]
                                    currentIndex: Math.max(0, ((root.config && root.config.providers) ? root.config.providers.findIndex(function (item) {
                                        return item.id === (root.config.active_provider || "deepseek") || item.uuid === (root.config.active_provider || "deepseek");
                                    }) : 0))
                                    onActivated: {
                                        if (!root.config || !root.config.providers || !root.config.providers[currentIndex]) return;
                                        root.config.active_provider = root.config.providers[currentIndex].id;
                                        root.persistConfig();
                                    }
                                }

                                CheckBox {
                                    id: providerEnabledCheckBox
                                    text: "Enabled"
                                    checked: !!(root.selectedProvider() && root.selectedProvider().enabled !== false)
                                    onToggled: {
                                        var provider = root.selectedProvider();
                                        if (!provider || !root.config) return;
                                        provider.enabled = checked;
                                        root.config.providers = (root.config.providers || []).slice();
                                        root.persistConfig();
                                    }
                                }

                                Button {
                                    text: "Delete"
                                    enabled: (root.config && root.config.providers && root.config.providers.length > 1)
                                    onClicked: root.removeSelectedProvider()
                                }
                            }
                        }

                        Components.SettingFieldRow {
                            label: "Name"

                            TextField {
                                Layout.fillWidth: true
                                text: root.activeProvider() ? root.activeProvider().name : "DeepSeek"
                                placeholderText: "DeepSeek"
                                background: Rectangle {
                                    color: sysPalette.base
                                    border.color: sysPalette.mid
                                    radius: 4
                                }
                                onTextEdited: root.updateActiveProvider("name", text)
                            }
                        }

                        Components.SettingFieldRow {
                            label: "Description"

                            TextField {
                                Layout.fillWidth: true
                                text: root.activeProvider() ? root.activeProvider().description : "DeepSeek chat and reasoning models"
                                placeholderText: "Provider description"
                                background: Rectangle {
                                    color: sysPalette.base
                                    border.color: sysPalette.mid
                                    radius: 4
                                }
                                onTextEdited: root.updateActiveProvider("description", text)
                            }
                        }

                        Components.SettingFieldRow {
                            label: "API Key"

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                TextField {
                                    id: apiKeyField
                                    Layout.fillWidth: true
                                    echoMode: showApiKeyCheckBox.checked ? TextInput.Normal : TextInput.Password
                                    text: root.activeProvider() ? root.activeProvider().api_key || "" : ""
                                    placeholderText: "Enter your DeepSeek API key"
                                    background: Rectangle {
                                        color: sysPalette.base
                                        border.color: sysPalette.mid
                                        radius: 4
                                    }
                                    onTextEdited: root.updateActiveProvider("api_key", text)
                                }

                                CheckBox {
                                    id: showApiKeyCheckBox
                                    text: "Show API Key"
                                }

                                Button {
                                    text: "Test Connection"
                                    onClicked: root.testConnection()
                                }
                            }
                        }

                        Label {
                            id: connectionStatus
                            text: ""
                            color: sysPalette.text
                            wrapMode: Text.WordWrap
                        }

                        Components.SettingFieldRow {
                            label: "Base URL"

                            TextField {
                                Layout.fillWidth: true
                                text: root.activeProvider() ? root.activeProvider().base_url || "https://api.deepseek.com" : "https://api.deepseek.com"
                                placeholderText: "https://api.deepseek.com"
                                background: Rectangle {
                                    color: sysPalette.base
                                    border.color: sysPalette.mid
                                    radius: 4
                                }
                                onTextEdited: root.updateActiveProvider("base_url", text)
                            }
                        }

                        Components.SettingFieldRow {
                            label: "Model"

                            ComboBox {
                                Layout.fillWidth: true
                                model: ["deepseek-v4-flash", "deepseek-v4-pro", "deepseek-chat", "deepseek-reasoner"]
                                editable: true
                                currentIndex: Math.max(0, ["deepseek-v4-flash", "deepseek-v4-pro", "deepseek-chat", "deepseek-reasoner"].indexOf(root.activeProvider() ? root.activeProvider().model || "deepseek-v4-flash" : "deepseek-v4-flash"))
                                onActivated: root.updateActiveProvider("model", currentText)
                                onEditTextChanged: root.updateActiveProvider("model", editText)
                            }
                        }
                    }

                    Components.SettingsSectionPanel {
                        sectionTitle: "Feature Provides"

                        GridLayout {
                            columns: 2
                            columnSpacing: 10
                            rowSpacing: 6
                            Layout.fillWidth: true

                            Repeater {
                                model: [
                                    ["page_translation", "Page Translation"],
                                    ["video_subtitles", "Video Subtitles"],
                                    ["selection_toolbar_translation", "Selection Toolbar Translation"],
                                    ["input_translation", "Input Translation"],
                                    ["language_detection", "Language Detection"],
                                    ["dictionary", "Dictionary"]
                                ]

                                CheckBox {
                                    text: modelData[1]
                                    checked: !!(root.activeProvider() && root.activeProvider().features && root.activeProvider().features[modelData[0]])
                                    onToggled: root.setFeature(modelData[0], checked)
                                }
                            }
                        }
                    }

                    Components.SettingsSectionPanel {
                        sectionTitle: "Advanced Options"

                        Components.SettingFieldRow {
                            label: "Temperature"

                            TextField {
                                Layout.fillWidth: true
                                text: (root.activeProvider() && root.activeProvider().temperature !== undefined) ? String(root.activeProvider().temperature) : "0.2"
                                placeholderText: "0.2"
                                background: Rectangle {
                                    color: sysPalette.base
                                    border.color: sysPalette.mid
                                    radius: 4
                                }
                                onEditingFinished: root.updateActiveProvider("temperature", parseFloat(text) || 0.2)
                            }
                        }

                        Components.SettingFieldRow {
                            label: "Provider Options"

                            TextField {
                                Layout.fillWidth: true
                                text: root.activeProvider() ? root.activeProvider().provider_options || "" : ""
                                placeholderText: "{\"thinking\": true}"
                                background: Rectangle {
                                    color: sysPalette.base
                                    border.color: sysPalette.mid
                                    radius: 4
                                }
                                onTextEdited: root.updateActiveProvider("provider_options", text)
                            }
                        }

                        Components.SettingFieldRow {
                            label: "Headers"

                            TextField {
                                Layout.fillWidth: true
                                text: root.activeProvider() ? root.activeProvider().headers || "{}" : "{}"
                                placeholderText: "{}"
                                background: Rectangle {
                                    color: sysPalette.base
                                    border.color: sysPalette.mid
                                    radius: 4
                                }
                                onTextEdited: root.updateActiveProvider("headers", text)
                            }
                        }
                    }

                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    GroupBox {
                        title: "Shortcuts"
                        label: Label {
                            text: parent.title
                            font.bold: true
                            font.pixelSize: 14
                            color: sysPalette.windowText
                        }
                        Layout.fillWidth: true

                        ColumnLayout {
                            width: parent.width
                            spacing: 6

                            Label {
                                text: "Ctrl + Enter: start translation"
                                color: sysPalette.text
                            }

                            Label {
                                text: "Ctrl + ,: open settings"
                                color: sysPalette.text
                            }
                        }
                    }
                }
            }
        }
    }
}
