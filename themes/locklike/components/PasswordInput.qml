import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property real mainCardComponentsOpacity
    property bool firstInput
    property bool isLoading
    property string buffer
    property string currentUser
    property int currentSession

    Layout.alignment: Qt.AlignHCenter
    color: config.subComponents
    radius: 30
    width: 340
    height: 40
    opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity

    Text {
        renderType: Text.NativeRendering
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 17
        font.family: "Material Symbols Rounded"
        font.pointSize: 15
        text: "\ue897"
        color: '#a8a8a8'

        Behavior on opacity {
            ColorAnimation {
                duration: 100
            }

        }

    }

    SequentialAnimation {
        id: shakeRotation

        running: false

        NumberAnimation {
            target: inputRect
            property: "rotation"
            to: -6
            duration: 50
        }

        NumberAnimation {
            target: inputRect
            property: "rotation"
            to: 6
            duration: 50
        }

        NumberAnimation {
            target: inputRect
            property: "rotation"
            to: -4
            duration: 50
        }

        NumberAnimation {
            target: inputRect
            property: "rotation"
            to: 4
            duration: 50
        }

        NumberAnimation {
            target: inputRect
            property: "rotation"
            to: -2
            duration: 50
        }

        NumberAnimation {
            target: inputRect
            property: "rotation"
            to: 2
            duration: 50
        }

        NumberAnimation {
            target: inputRect
            property: "rotation"
            to: 0
            duration: 50
        }

    }

    SequentialAnimation {
        id: pulseColorRect1

        loops: Animation.Infinite
        running: root.isLoading

        ColorAnimation {
            target: root
            property: "color"
            to: config.inverseOnSurface
            duration: 350
        }

        ColorAnimation {
            target: root
            property: "color"
            to: config.subComponents
            duration: 350
        }

    }

    SequentialAnimation {
        id: pulseColorRect2

        loops: Animation.Infinite
        running: root.isLoading

        ColorAnimation {
            target: inputBorders
            property: "color"
            to: config.inverseOnSurface
            duration: 350
        }

        ColorAnimation {
            target: inputBorders
            property: "color"
            to: config.subComponents
            duration: 350
        }

    }

    Rectangle {
        id: inputBorders

        anchors.centerIn: parent
        color: config.subComponents
        radius: 30
        width: 250
        height: 40
        clip: true

        Text {
            renderType: Text.NativeRendering
            anchors.centerIn: parent
            font.pointSize: 12
            text: "Enter your password"
            color: '#6e6e6e'
            font.family: "CaskaydiaCove NF"
            opacity: root.buffer === "" ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 100
                }

            }

        }

        RowLayout {
            anchors.centerIn: parent

            Repeater {
                id: characters

                model: root.buffer.length

                delegate: Rectangle {
                    radius: 30
                    width: 12
                    height: 12
                    color: config.text
                }

            }

            Rectangle {
                id: textIndicator

                property bool invisible: true

                visible: root.buffer === "" ? false : true
                width: 1
                height: 21
                color: config.text
                opacity: invisible ? 0 : 1

                Timer {
                    running: true
                    repeat: true
                    interval: 500
                    onTriggered: textIndicator.invisible = !textIndicator.invisible
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }

                }

            }

        }

    }

    Rectangle {
        id: inputButton

        radius: 30
        width: 30
        height: 30
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 8
        color: root.buffer === "" ? config.inverseOnSurface : config.primary

        Text {
            renderType: Text.NativeRendering
            anchors.centerIn: parent
            font.family: "Material Symbols Rounded"
            font.pointSize: 17
            text: "\ue941"
            color: root.buffer === "" ? config.text : config.mainCard

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }

            }

        }

        MouseArea {
            anchors.fill: parent
            cursorShape: root.buffer === "" ? Qt.ArrowCursor : Qt.PointingHandCursor
            onClicked: {
                sddm.login(userPicker.currentText, root.buffer, sessionPicker.currentIndex);
                root.isLoading = true;
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
            }

        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutBack
        }

    }

}
