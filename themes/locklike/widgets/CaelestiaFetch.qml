import QtQuick
import QtQuick.Layouts
import "../components"

Item {
    id: root
    required property bool firstInput
    required property string currentSession
    required property string currentUser
    required property int rectHeight

    RowLayout {
        Rectangle {
            width: 30
            height: 40
            radius: 12
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 30
            anchors.topMargin: 20
            color: config.primary
            Text {
                renderType: Text.NativeRendering
                anchors.centerIn: parent
                color: "#111111"
                text: ">"
                font.family: "CaskaydiaCove NF"
                font.pointSize: 15
            }
        }
        Text {
            renderType: Text.NativeRendering
            color: config.text
            text: "caelestiafetch.sh"
            font.family: "CaskaydiaCove NF"
            font.pointSize: 13
            Layout.leftMargin: 35
            Layout.topMargin: 29
        }
    }
    ColumnLayout {
        Item {
            width: 30
            height: 60
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Logo {
                skipIntroAnimation: root.firstInput
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.leftMargin: 25
                Layout.topMargin: 50
                Layout.preferredWidth: 130
                Layout.preferredHeight: 130
            }
            RowLayout {
                spacing: 10
                Text {
                    renderType: Text.NativeRendering
                    Layout.leftMargin: 12
                    Layout.topMargin: root.rectHeight / 10
                    text: "WM     :\nUSER   :\nUP     :\nBATTERY:"
                    color: config.text
                    font.pixelSize: 18
                    font.family: "CaskaydiaCove NF"
                    lineHeight: 30
                    lineHeightMode: Text.FixedHeight
                    Layout.preferredWidth: 80
                }
                Text {
                    renderType: Text.NativeRendering
                    property string displayText: root.currentSession.split(" ")[0] // idk if i want it like that, but i dont know DEs that have more than one word as a name, that avoids something like that "Plasma (Wayland)"
                    Layout.leftMargin: 0
                    Layout.topMargin: root.rectHeight / 10
                    text: displayText + "\n" + root.currentUser + "\n" + "WIP" + "\n" + "WIP"
                    color: config.text
                    font.pixelSize: 18
                    font.family: "CaskaydiaCove NF"
                    lineHeight: 30
                    lineHeightMode: Text.FixedHeight
                    Layout.preferredWidth: 100
                }
            }
        }
        RowLayout {
            spacing: 20
            Layout.alignment: Qt.AlignHCenter
            Layout.leftMargin: 30
            Layout.topMargin: 20
            Rectangle {
                width: 30
                height: 30
                color: config.background
                radius: 12
            }
            Rectangle {
                width: 30
                height: 30
                color: config.primary
                radius: 12
            }
            Rectangle {
                width: 30
                height: 30
                color: config.text
                radius: 12
            }
            Rectangle {
                width: 30
                height: 30
                color: config.textDark
                radius: 12
            }
            Rectangle {
                width: 30
                height: 30
                color: config.secondary
                radius: 12
            }
            Rectangle {
                width: 30
                height: 30
                color: config.onSuccess
                radius: 12
            }
            Rectangle {
                width: 30
                height: 30
                color: config.inverseOnSurface
                radius: 12
            }
        }
    }
}
