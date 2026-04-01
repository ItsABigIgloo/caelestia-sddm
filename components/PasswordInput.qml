import "../singletons"
import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property string buffer: ""
    property var onLogin: null
    property var onRestoreFocus: null

    implicitWidth: 380
    implicitHeight: 55
    color: Theme.withAlpha(Theme.mSurface, Theme.cardOpacity)
    radius: Theme.passwordInputRadius
    border.color: Theme.mOutline
    border.width: 1

    Text {
        renderType: Text.NativeRendering
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 17
        font.family: "Material Symbols Outlined"
        font.pixelSize: Math.round(Theme.baseFontSize * 1.5)
        text: "\ue897"
        color: Theme.mOnSurfaceVariant
    }

    Rectangle {
        anchors.centerIn: parent
        color: "transparent"
        width: 250
        height: 50
        clip: true

        Text {
            renderType: Text.NativeRendering
            anchors.centerIn: parent
            font.family: Theme.fontFamily
            font.pixelSize: Math.round(Theme.baseFontSize * 1.5)
            text: "Enter your password"
            color: Theme.mOnSurfaceVariant
            opacity: root.buffer === "" ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animDurationFast
                }

            }

        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                id: passwordDots

                model: root.buffer.length

                Rectangle {
                    radius: Theme.passwordInputRadius
                    width: 12
                    height: 12
                    color: Theme.mOnSurface
                }

            }

            Rectangle {
                id: cursorIndicator

                property bool blink: true

                visible: root.buffer !== ""
                width: 2
                height: 25
                color: Theme.mOnSurface
                opacity: blink ? 1 : 0

                Timer {
                    running: cursorIndicator.visible
                    repeat: true
                    interval: 530
                    onTriggered: cursorIndicator.blink = !cursorIndicator.blink
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animDurationFast
                    }

                }

            }

        }

    }

    Rectangle {
        id: loginButton

        radius: Theme.passwordInputRadius
        width: 35
        height: 35
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 8
        color: root.buffer === "" ? Theme.mSurfaceVariant : Theme.mPrimary

        Text {
            anchors.centerIn: parent
            font.family: "Material Symbols Outlined"
            font.pixelSize: Math.round(Theme.baseFontSize * 1.67)
            text: "\ue5c8"
            color: root.buffer === "" ? Theme.mOnSurface : Theme.mOnPrimary

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animDurationFast
                }

            }

        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.onLogin)
                    root.onLogin();

                if (root.onRestoreFocus)
                    root.onRestoreFocus();

            }
        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.animDurationFast
            }

        }

    }

}
