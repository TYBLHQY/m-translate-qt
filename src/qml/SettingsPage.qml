import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform

Item {
    id: root

    SystemPalette { id: sysPalette }

    function persistConfig()
    {
        if (root.config)
            deepSeekConfigManager.saveConfig(root.config);
    }

    property int currentSection: 0
    property var config: ({})

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

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                text: qsTr("返回")
                onClicked: root.backRequested()
            }

            Label {
                text: qsTr("配置中心")
                color: sysPalette.windowText
                font.pixelSize: 28
                font.bold: true
            }

            Item {
                Layout.fillWidth: true
            }
        }

        ButtonGroup {
            id: configSectionGroup
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    qsTr("软件通用配置"),
                    qsTr("API 配置"),
                    qsTr("快捷键配置")
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

                    GroupBox {
                        title: qsTr("通用")
                        Layout.fillWidth: true

                        ColumnLayout {
                            width: parent.width
                            spacing: 6

                            CheckBox {
                                text: qsTr("自动保存翻译结果")
                                checked: true
                            }

                            CheckBox {
                                text: qsTr("启动时显示欢迎页")
                                checked: true
                            }

                            CheckBox {
                                text: qsTr("显示实时字数统计")
                                checked: false
                            }
                        }
                    }

                    GroupBox {
                        title: qsTr("界面")
                        Layout.fillWidth: true

                        ColumnLayout {
                            width: parent.width
                            spacing: 6

                            Label {
                                text: qsTr("主题与显示习惯可在后续版本中继续扩展。")
                                color: sysPalette.text
                                wrapMode: Label.WordWrap
                            }
                        }
                    }
                }

                ColumnLayout {
                    spacing: 6

                    GroupBox {
                        title: qsTr("API 配置")
                        Layout.fillWidth: true

                        ColumnLayout {
                            width: parent.width
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Label {
                                    text: qsTr("Base URL")
                                    color: sysPalette.text
                                    Layout.preferredWidth: 120
                                }

                                TextField {
                                    Layout.fillWidth: true
                                    text: root.config.base_url ?? "https://api.deepseek.com"
                                    placeholderText: qsTr("https://api.deepseek.com")
                                    onTextEdited: {
                                        if (root.config) root.config.base_url = text;
                                        root.persistConfig();
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Label {
                                    text: qsTr("API Key")
                                    color: sysPalette.text
                                    Layout.preferredWidth: 120
                                }

                                TextField {
                                    Layout.fillWidth: true
                                    echoMode: TextInput.Password
                                    text: root.config.api_key ?? ""
                                    placeholderText: qsTr("Enter your DeepSeek API key")
                                    onTextEdited: {
                                        if (root.config) root.config.api_key = text;
                                        root.persistConfig();
                                    }
                                }
                            }
                        }
                    }

                    GroupBox {
                        title: qsTr("模型与提示词")
                        Layout.fillWidth: true

                        ColumnLayout {
                            width: parent.width
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Label {
                                    text: qsTr("Model")
                                    color: sysPalette.text
                                    Layout.preferredWidth: 120
                                }

                                TextField {
                                    Layout.fillWidth: true
                                    text: root.config.model ?? ""
                                    onTextEdited: {
                                        if (root.config) root.config.model = text;
                                        root.persistConfig();
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Label {
                                    text: qsTr("System prompt")
                                    color: sysPalette.text
                                    Layout.preferredWidth: 120
                                }

                                TextArea {
                                    Layout.fillWidth: true
                                    implicitHeight: 96
                                    wrapMode: TextEdit.WordWrap
                                    text: root.config.system_prompt ?? ""
                                    onTextChanged: {
                                        if (root.config) root.config.system_prompt = text;
                                        root.persistConfig();
                                    }
                                    background: Item {}
                                }
                            }
                        }
                    }

                    GroupBox {
                        title: qsTr("生成控制")
                        Layout.fillWidth: true

                        GridLayout {
                            columns: 2
                            columnSpacing: 6
                            rowSpacing: 6
                            width: parent.width

                            Label { text: qsTr("Temperature"); color: sysPalette.text }
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

                            Label { text: qsTr("Top P"); color: sysPalette.text }
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

                            Label { text: qsTr("Max tokens"); color: sysPalette.text }
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
                        title: qsTr("风格与上下文")
                        Layout.fillWidth: true

                        GridLayout {
                            columns: 2
                            columnSpacing: 6
                            rowSpacing: 6
                            width: parent.width

                            Label { text: qsTr("Style"); color: sysPalette.text }
                            ComboBox {
                                model: ["fluent", "precise", "formal"]
                                currentIndex: ["fluent", "precise", "formal"].indexOf(root.config.style ?? "fluent")
                                Layout.fillWidth: true
                                onActivated: {
                                    if (root.config) root.config.style = currentText;
                                    root.persistConfig();
                                }
                            }

                            Label { text: qsTr("Context mode"); color: sysPalette.text }
                            ComboBox {
                                model: ["document", "conversation", "mixed"]
                                currentIndex: ["document", "conversation", "mixed"].indexOf(root.config.context_mode ?? "document")
                                Layout.fillWidth: true
                                onActivated: {
                                    if (root.config) root.config.context_mode = currentText;
                                    root.persistConfig();
                                }
                            }

                            Label { text: qsTr("Chunk size"); color: sysPalette.text }
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

                    GroupBox {
                        title: qsTr("特性开关")
                        Layout.fillWidth: true

                        ColumnLayout {
                            width: parent.width
                            spacing: 6

                            CheckBox {
                                text: qsTr("Glossary")
                                checked: root.config.glossary ?? true
                                onToggled: {
                                    if (root.config) root.config.glossary = checked;
                                    root.persistConfig();
                                }
                            }

                            CheckBox {
                                text: qsTr("Preserve format")
                                checked: root.config.preserve_format ?? true
                                onToggled: {
                                    if (root.config) root.config.preserve_format = checked;
                                    root.persistConfig();
                                }
                            }

                            CheckBox {
                                text: qsTr("Consistency mode")
                                checked: root.config.consistency_mode ?? true
                                onToggled: {
                                    if (root.config) root.config.consistency_mode = checked;
                                    root.persistConfig();
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    spacing: 6

                    GroupBox {
                        title: qsTr("快捷键")
                        Layout.fillWidth: true

                        ColumnLayout {
                            width: parent.width
                            spacing: 6

                            Label {
                                text: qsTr("Ctrl + Enter：开始翻译")
                                color: sysPalette.text
                            }

                            Label {
                                text: qsTr("Esc：返回主页面")
                                color: sysPalette.text
                            }

                            Label {
                                text: qsTr("Ctrl + ,：打开设置页")
                                color: sysPalette.text
                            }
                        }
                    }

                    GroupBox {
                        title: qsTr("建议")
                        Layout.fillWidth: true

                        Label {
                            text: qsTr("后续可继续补充自定义快捷键与按键冲突提示。")
                            color: sysPalette.text
                            wrapMode: Label.WordWrap
                        }
                    }
                }
            }
        }
    }
}
