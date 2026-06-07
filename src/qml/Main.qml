import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root

    property var deepSeekConfig: deepSeekConfigManager.loadConfig()
    property var homeWindowGeometry: deepSeekConfigManager.loadWindowGeometry("home")

    x: root.homeWindowGeometry.x ?? 100
    y: root.homeWindowGeometry.y ?? 100
    width: root.homeWindowGeometry.width ?? 330
    height: root.homeWindowGeometry.height ?? 600
    minimumWidth: 330
    minimumHeight: 600
    visible: true
    title: qsTr("AI Translation Studio")

    function saveWindowGeometry() {
        deepSeekConfigManager.saveWindowGeometry(
            "home",
            root.x,
            root.y,
            Math.max(root.width, root.minimumWidth),
            Math.max(root.height, root.minimumHeight)
        );
    }

    Component.onCompleted: {
        deepSeekConfigManager.saveConfig(root.deepSeekConfig);
        root.saveWindowGeometry();
    }

    onXChanged: if (root.visible) root.saveWindowGeometry()
    onYChanged: if (root.visible) root.saveWindowGeometry()
    onWidthChanged: if (root.visible) root.saveWindowGeometry()
    onHeightChanged: if (root.visible) root.saveWindowGeometry()

    Shortcut {
        sequence: "Ctrl+,"
        context: Qt.ApplicationShortcut
        onActivated: root.openSettingsWindow()
    }

    function openSettingsWindow() {
        const savedSettingsGeometry = deepSeekConfigManager.loadWindowGeometry("settings");
        const settingsWindow = settingsWindowComponent.createObject(root, {
            x: savedSettingsGeometry.x ?? Math.max(24, root.x + 32),
            y: savedSettingsGeometry.y ?? Math.max(24, root.y + 32),
            width: savedSettingsGeometry.width ?? Math.min(root.width, 980),
            height: savedSettingsGeometry.height ?? Math.min(root.height, 760)
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
            minimumWidth: 330
            minimumHeight: 600
            visible: true
            flags: Qt.Dialog

            function saveWindowGeometry() {
                deepSeekConfigManager.saveWindowGeometry(
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
                onBackRequested: settingsWindow.close()
            }
        }
    }

    HomePage {
        id: homePage
        anchors.fill: parent
        onOpenSettings: root.openSettingsWindow()
    }
}
