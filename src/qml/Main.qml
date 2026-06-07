import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root

    property var deepSeekConfig: deepSeekConfigManager.loadConfig()
    property var savedWindowGeometry: deepSeekConfigManager.loadWindowGeometry()

    x: root.savedWindowGeometry.x ?? 100
    y: root.savedWindowGeometry.y ?? 100
    width: root.savedWindowGeometry.width ?? 330
    height: root.savedWindowGeometry.height ?? 600
    minimumWidth: 330
    minimumHeight: 600
    visible: true
    title: qsTr("AI Translation Studio")

    function saveWindowGeometry() {
        deepSeekConfigManager.saveWindowGeometry(
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

    HomePage {
        id: homePage
        anchors.fill: parent
        onOpenSettings: settingsPopup.open()
    }

    Popup {
        id: settingsPopup
        modal: false
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.OnPressOutside
        x: Math.max(16, (root.width - width) / 2)
        y: Math.max(16, (root.height - height) / 2)
        width: Math.min(root.width - 32, 980)
        height: Math.min(root.height - 32, 760)
        padding: 0

        background: Rectangle {
            color: palette.window
            border.color: palette.mid
            radius: 8
        }

        contentItem: SettingsPage {
            config: root.deepSeekConfig
            onBackRequested: settingsPopup.close()
        }
    }
}
