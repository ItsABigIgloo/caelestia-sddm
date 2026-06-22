import QtQuick

ButtonStyle {
    id: root

    property string icon: ""
    property int iconSize: 20
    property string iconColor: "#e0e0e0"
    property string iconColorHovered: "#ffffff"
    property color bgNormal: Qt.rgba(1, 1, 1, 0.06)
    property color bgHovered: Qt.rgba(1, 1, 1, 0.15)

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root._hovered || root.isFocused ? root.bgHovered : root.bgNormal

        Behavior on color {
            ColorAnimation {
                duration: root.animDuration
            }

        }

    }

    Text {
        anchors.centerIn: parent
        font.family: "Material Symbols Rounded"
        font.pointSize: root.iconSize
        text: root.icon
        color: root._hovered || root.isFocused ? root.iconColorHovered : root.iconColor

        Behavior on color {
            ColorAnimation {
                duration: root.animDuration
            }

        }

    }

}
