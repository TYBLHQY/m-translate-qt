import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

GroupBox {
    id: root

    property string sectionTitle: ""

    default property alias content: contentLayout.data

    SystemPalette { id: sysPalette }

    title: root.sectionTitle
    label: Label {
        text: root.sectionTitle
        font.bold: true
        font.pixelSize: 14
        color: sysPalette.windowText
    }
    Layout.fillWidth: true
    Layout.minimumWidth: 0

    ColumnLayout {
        id: contentLayout
        width: parent.width
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        spacing: 6
    }
}
