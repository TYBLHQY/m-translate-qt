import QtQuick
import QtQuick.Controls
import m.translate.qt 1.0

ApplicationWindow {
    id: root

    property var deepSeekConfig: DeepSeekConfigManager.loadConfig()
    property var homeWindowGeometry: DeepSeekConfigManager.loadWindowGeometry("home")
    property int uiFontSize: root.deepSeekConfig ? (root.deepSeekConfig.font_size ?? 13) : 13

    x: root.homeWindowGeometry.x ?? 100
    y: root.homeWindowGeometry.y ?? 100
    width: root.homeWindowGeometry.width ?? 330
    height: root.homeWindowGeometry.height ?? 600
    minimumWidth: 330
    minimumHeight: 600
    visible: true
    title: qsTr("AI Translation Studio")
    font.pixelSize: root.uiFontSize

    function saveWindowGeometry() {
        DeepSeekConfigManager.saveWindowGeometry(
            "home",
            root.x,
            root.y,
            Math.max(root.width, root.minimumWidth),
            Math.max(root.height, root.minimumHeight)
        );
    }

    function refreshConfig() {
        root.deepSeekConfig = DeepSeekConfigManager.loadConfig();
        root.uiFontSize = root.deepSeekConfig.font_size ?? 13;

        if (homePage) {
            homePage.currentConfig = root.deepSeekConfig;
        }
    }

    Component.onCompleted: {
        root.refreshConfig();
        DeepSeekConfigManager.saveConfig(root.deepSeekConfig);
        root.saveWindowGeometry();
    }

    onXChanged: if (root.visible) root.saveWindowGeometry()
    onYChanged: if (root.visible) root.saveWindowGeometry()
    onWidthChanged: if (root.visible) root.saveWindowGeometry()
    onHeightChanged: if (root.visible) root.saveWindowGeometry()

    function toggleMainWindow() {
        if (root.visible) {
            root.hide();
        } else {
            root.show();
            root.raise();
            root.requestActivate();
        }
    }

    Shortcut {
        sequence: root.deepSeekConfig && root.deepSeekConfig.shortcuts
            ? (root.deepSeekConfig.shortcuts.main_window_toggle || "Ctrl+Shift+Space")
            : "Ctrl+Shift+Space"
        context: Qt.ApplicationShortcut
        enabled: !(root.deepSeekConfig && root.deepSeekConfig.shortcuts && root.deepSeekConfig.shortcuts.main_window_toggle_enabled === false)
        onActivated: root.toggleMainWindow()
    }

    Shortcut {
        sequence: "Ctrl+,"
        context: Qt.ApplicationShortcut
        onActivated: root.openSettingsWindow()
    }

    function openSettingsWindow() {
        const savedSettingsGeometry = DeepSeekConfigManager.loadWindowGeometry("settings");
        const settingsWindow = settingsWindowComponent.createObject(root, {
            x: savedSettingsGeometry.x ?? Math.max(24, root.x + 32),
            y: savedSettingsGeometry.y ?? Math.max(24, root.y + 32),
            width: Math.max(savedSettingsGeometry.width ?? 980, 800),
            height: Math.max(savedSettingsGeometry.height ?? 760, 600)
        });

        if (settingsWindow) {
            settingsWindow.show();
        }
    }

    Component {
        id: settingsWindowComponent

        ApplicationWindow {
            id: settingsWindow
            title: qsTr("设置")
            minimumWidth: 800
            minimumHeight: 600
            visible: true
            flags: Qt.Dialog

            function saveWindowGeometry() {
                DeepSeekConfigManager.saveWindowGeometry(
                    "settings",
                    settingsWindow.x,
                    settingsWindow.y,
                    Math.max(settingsWindow.width, settingsWindow.minimumWidth),
                    Math.max(settingsWindow.height, settingsWindow.minimumHeight)
                );
            }

            Component.onCompleted: settingsWindow.saveWindowGeometry()
            onXChanged: if (settingsWindow.visible) settingsWindow.saveWindowGeometry()
            onYChanged: if (settingsWindow.visible) settingsWindow.saveWindowGeometry()
            onWidthChanged: if (settingsWindow.visible) settingsWindow.saveWindowGeometry()
            onHeightChanged: if (settingsWindow.visible) settingsWindow.saveWindowGeometry()

            onClosing: destroy()

            SettingsPage {
                anchors.fill: parent
                config: root.deepSeekConfig
                onSettingsChanged: root.refreshConfig()
                onBackRequested: settingsWindow.close()
            }
        }
    }

    HomePage {
        id: homePage
        anchors.fill: parent
        currentConfig: root.deepSeekConfig
        onOpenSettings: root.openSettingsWindow()
    }
}
