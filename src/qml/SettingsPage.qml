import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import "components" as Components

Item {
    id: root

    SystemPalette { id: sysPalette }

    function persistConfig()
    {
        if (root.config) {
            deepSeekConfigManager.saveConfig(root.config);
            root.settingsChanged();
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
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            StackLayout {
                width: Math.max(parent.width, 680)
                currentIndex: root.currentSection

                ColumnLayout {
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
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    spacing: 6

                    Components.SettingsSectionPanel {
                        sectionTitle: "API Settings"

                        Components.SettingFieldRow {
                            label: "Base URL"

                            TextField {
                                Layout.fillWidth: true
                                text: root.config.base_url ?? "https://api.deepseek.com"
                                placeholderText: "https://api.deepseek.com"
                                background: Rectangle {
                                    color: sysPalette.base
                                    border.color: sysPalette.mid
                                    radius: 4
                                }
                                onTextEdited: {
                                    if (root.config) root.config.base_url = text;
                                    root.persistConfig();
                                }
                            }
                        }

                        Components.SettingFieldRow {
                            label: "API Key"

                            TextField {
                                Layout.fillWidth: true
                                echoMode: TextInput.Password
                                text: root.config.api_key ?? ""
                                placeholderText: "Enter your DeepSeek API key"
                                background: Rectangle {
                                    color: sysPalette.base
                                    border.color: sysPalette.mid
                                    radius: 4
                                }
                                onTextEdited: {
                                    if (root.config) root.config.api_key = text;
                                    root.persistConfig();
                                }
                            }
                        }
                    }

                    Components.SettingsSectionPanel {
                        sectionTitle: "Models and Prompts"

                        Components.SettingFieldRow {
                            label: "Model"

                            TextField {
                                Layout.fillWidth: true
                                text: root.config.model ?? ""
                                background: Rectangle {
                                    color: sysPalette.base
                                    border.color: sysPalette.mid
                                    radius: 4
                                }
                                onTextEdited: {
                                    if (root.config) root.config.model = text;
                                    root.persistConfig();
                                }
                            }
                        }

                        Components.SettingFieldRow {
                            label: "System prompt"

                            TextArea {
                                Layout.fillWidth: true
                                implicitHeight: 96
                                wrapMode: TextEdit.WordWrap
                                text: root.config.system_prompt ?? ""
                                background: Rectangle {
                                    color: sysPalette.base
                                    border.color: sysPalette.mid
                                    radius: 4
                                }
                                onTextChanged: {
                                    if (root.config) root.config.system_prompt = text;
                                    root.persistConfig();
                                }
                            }
                        }
                    }

                    GroupBox {
                        title: "Generation Controls"
                        label: Label {
                            text: parent.title
                            font.bold: true
                            font.pixelSize: 14
                            color: sysPalette.windowText
                        }
                        Layout.fillWidth: true

                        GridLayout {
                            columns: 2
                            columnSpacing: 6
                            rowSpacing: 6
                            width: parent.width

                            Label { text: "Temperature"; color: sysPalette.text }
                            Slider {
                                from: 0
                                to: 1
                                stepSize: 0.01
                                value: root.config.temperature ?? 0.2
                                Layout.fillWidth: true
                                onMoved: {
                                    if (root.config) root.config.temperature = value;
                                    root.persistConfig();
                                }
                            }

                            Label { text: "Top P"; color: sysPalette.text }
                            Slider {
                                from: 0
                                to: 1
                                stepSize: 0.01
                                value: root.config.top_p ?? 1.0
                                Layout.fillWidth: true
                                onMoved: {
                                    if (root.config) root.config.top_p = value;
                                    root.persistConfig();
                                }
                            }

                            Label { text: "Max tokens"; color: sysPalette.text }
                            SpinBox {
                                from: 256
                                to: 8192
                                value: root.config.max_tokens ?? 4096
                                onValueModified: {
                                    if (root.config) root.config.max_tokens = value;
                                    root.persistConfig();
                                }
                            }
                        }
                    }

                    GroupBox {
                        title: "Style and Context"
                        label: Label {
                            text: parent.title
                            font.bold: true
                            font.pixelSize: 14
                            color: sysPalette.windowText
                        }
                        Layout.fillWidth: true

                        GridLayout {
                            columns: 2
                            columnSpacing: 6
                            rowSpacing: 6
                            width: parent.width

                            Label { text: "Style"; color: sysPalette.text }
                            ComboBox {
                                model: ["fluent", "precise", "formal"]
                                currentIndex: ["fluent", "precise", "formal"].indexOf(root.config.style ?? "fluent")
                                Layout.fillWidth: true
                                onActivated: {
                                    if (root.config) root.config.style = currentText;
                                    root.persistConfig();
                                }
                            }

                            Label { text: "Context mode"; color: sysPalette.text }
                            ComboBox {
                                model: ["document", "conversation", "mixed"]
                                currentIndex: ["document", "conversation", "mixed"].indexOf(root.config.context_mode ?? "document")
                                Layout.fillWidth: true
                                onActivated: {
                                    if (root.config) root.config.context_mode = currentText;
                                    root.persistConfig();
                                }
                            }

                            Label { text: "Chunk size"; color: sysPalette.text }
                            SpinBox {
                                from: 200
                                to: 4000
                                stepSize: 50
                                value: root.config.chunk_size ?? 1000
                                onValueModified: {
                                    if (root.config) root.config.chunk_size = value;
                                    root.persistConfig();
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
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
