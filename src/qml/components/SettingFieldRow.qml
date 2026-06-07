import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root

    property string label: ""
    property int labelWidth: 120

    Layout.fillWidth: true
    Layout.minimumWidth: 0

    default property alias content: contentContainer.data

    SystemPalette { id: sysPalette }

    spacing: 6

    Label {
        text: root.label
        color: sysPalette.text
        Layout.preferredWidth: root.labelWidth
        Layout.maximumWidth: root.labelWidth
        Layout.minimumWidth: root.labelWidth
    }

    ColumnLayout {
        id: contentContainer
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.preferredWidth: 1
        spacing: 0
    }
}
