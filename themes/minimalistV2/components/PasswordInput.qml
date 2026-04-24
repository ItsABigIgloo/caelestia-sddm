import "../singletons"
import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property string buffer: ""
    property var onLogin: null
    property var onRestoreFocus: null
    property bool isError: false
    property bool isAuthenticating: false

    implicitWidth: 380
    implicitHeight: 55
    color: Theme.withAlpha(Theme.mSurface, Theme.outerCardOpacity)
    radius: Math.min(Theme.elementRadius, Math.min(root.width, root.height) / 2)
    border.color: {
        if (isError)
            return Theme.mError;

        if (isAuthenticating)
            return Theme.mPrimary;

        if (buffer !== "")
            return Theme.mPrimary;

        return Theme.mOutline;
    }
    border.width: 2

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
                    radius: Math.min(Theme.elementRadius, width / 2)
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

        radius: Math.min(Theme.elementRadius, Math.min(width, height) / 2)
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

    Connections {
        function onIsErrorChanged() {
            if (isError)
                authPulseAnim.stop();

        }

        target: root
    }

    SequentialAnimation {
        id: shakeAnim

        running: isError
        loops: 1

        NumberAnimation {
            target: shakeTransform
            property: "x"
            to: -8
            duration: 50
        }

        NumberAnimation {
            target: shakeTransform
            property: "x"
            to: 8
            duration: 50
        }

        NumberAnimation {
            target: shakeTransform
            property: "x"
            to: -6
            duration: 50
        }

        NumberAnimation {
            target: shakeTransform
            property: "x"
            to: 6
            duration: 50
        }

        NumberAnimation {
            target: shakeTransform
            property: "x"
            to: 0
            duration: 50
        }

    }

    transform: Translate {
        id: shakeTransform

        x: 0
    }

    Behavior on border.color {
        ColorAnimation {
            duration: Theme.animDurationFast
        }

    }

    SequentialAnimation on border.color {
        id: authPulseAnim

        running: isAuthenticating && !isError
        loops: Animation.Infinite

        // Pulses between lighter darker and base
        // Base
        ColorAnimation {
            to: Theme.mPrimary
            duration: 250
            easing.type: Easing.InSine
        }

        // Base → Lighter
        ColorAnimation {
            to: Qt.lighter(Theme.mPrimary, 1.3)
            duration: 400
            easing.type: Easing.InOutSine
        }

        // Lighter → Darker
        ColorAnimation {
            to: Qt.darker(Theme.mPrimary, 1.4)
            duration: 500
            easing.type: Easing.InOutSine
        }

        PauseAnimation {
            duration: 500
        }

    }

}
