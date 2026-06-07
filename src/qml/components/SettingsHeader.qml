import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root

    property string title: "Settings"

    signal backRequested()

    SystemPalette { id: sysPalette }

    spacing: 8

    Button {
        text: "Back"
        onClicked: root.backRequested()
    }

    Label {
        text: root.title
        color: sysPalette.windowText
        font.pixelSize: 28
        font.bold: true
    }

    Item {
        Layout.fillWidth: true
    }
}
