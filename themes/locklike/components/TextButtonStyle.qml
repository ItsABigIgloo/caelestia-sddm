import QtQuick

ButtonStyle {
    id: root

    property string text: ""

    width: 100
    height: 44

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: root._hovered || (root.isFocused && root.noHoverActive) ? config.primary : config.subComponents
        border.width: root._hovered || (root.isFocused && root.noHoverActive) ? 2 : 0
        border.color: root._hovered || (root.isFocused && root.noHoverActive) ? Qt.lighter(config.primary, 1.3) : "transparent"

        Text {
            anchors.centerIn: parent
            text: root.text
            color: root._hovered || (root.isFocused && root.noHoverActive) ? config.onPrimary : config.text
            font.family: "Rubik"
            font.pixelSize: 14
            font.bold: root._hovered || (root.isFocused && root.noHoverActive)
            horizontalAlignment: Text.AlignHCenter

            Behavior on color {
                ColorAnimation {
                    duration: root.animDuration
                }

            }

        }

        Behavior on color {
            ColorAnimation {
                duration: root.animDuration
            }

        }

        Behavior on border.color {
            ColorAnimation {
                duration: root.animDuration
            }

        }

    }

}
