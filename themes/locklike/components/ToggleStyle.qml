import QtQuick

Item {
    id: root

    property bool checked: false

    signal toggled(bool value)

    width: 48
    height: 28

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked
            ? (mouse.containsMouse ? Qt.lighter(config.primary, 1.1) : config.primary)
            : config.subComponents
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Rectangle {
        x: root.checked ? parent.width - width - 2 : 2
        y: (parent.height - height) / 2
        width: mouse.pressed ? height * 1.2 : height
        height: parent.height - 4
        radius: height / 2
        color: root.checked ? config.onPrimary : config.outline
        Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutQuint } }
        Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutQuint } }
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}
