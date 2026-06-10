import QtQuick
import QtQuick.Layouts
import "shapes"
import "shapes/material-shapes.js" as MaterialShapes

Rectangle {
    id: inputRect

    anchors.horizontalCenter: parent.horizontalCenter

    property real mainCardComponentsOpacity
    property bool firstInput
    property bool isLoading
    property string buffer
    property string currentUser
    property int currentSession

    Layout.alignment: Qt.AlignHCenter
    color: config.subComponents
    radius: 30
    width: inputRect.buffer === "" ? 300 : 365
    height: 45
    opacity: inputRect.firstInput ? 0 : inputRect.mainCardComponentsOpacity

    Behavior on width {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutBack
        }
    }

    function shake() {
        shakeRotation.start();
    }

    LayerState {
        anchors.fill: parent
        parentWidth: inputRect.width
        parentHeight: inputRect.height
        parentRadius: inputRect.radius
    }

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
        running: inputRect.isLoading

        ColorAnimation {
            target: inputRect
            property: "color"
            to: config.inverseOnSurface
            duration: 350
        }

        ColorAnimation {
            target: inputRect
            property: "color"
            to: config.subComponents
            duration: 350
        }
    }

    Rectangle {
        id: inputBorders

        anchors.centerIn: parent
        color: "transparent"
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
            font.family: "Rubik"
            opacity: inputRect.buffer === "" ? 1 : 0

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

                model: inputRect.buffer.length

                delegate: Rectangle {
                    radius: 30
                    width: 15
                    height: 15
                    color: config.text
                }
            }

            Rectangle {
                id: textIndicator

                property bool invisible: true

                visible: inputRect.buffer === "" ? false : true
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
        id: inputButtonShape

        radius: 48
        width: inputRect.height - 7
        height: inputRect.height - 7
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 4
        color: "transparent"

        property var shapeGetters: [MaterialShapes.getCircle, MaterialShapes.getArrow]

        ShapeCanvas {
            id: shape
            rotation: 90
            scale: inputRect.buffer === "" ? 0.9 : 0.7
            implicitWidth: inputButtonShape.height / 2 * 2.1
            implicitHeight: inputButtonShape.height / 2 * 2.1
            roundedPolygon: inputRect.buffer === "" ? inputButtonShape.shapeGetters[0]() : inputButtonShape.shapeGetters[1]()
            color: inputRect.buffer === "" ? config.inverseOnSurface : config.secondary
            y: -1

            Text {
                renderType: Text.NativeRendering
                anchors.centerIn: parent
                font.family: "Material Symbols Rounded"
                font.pointSize: 24
                rotation: -90
                text: "\ue941"
                color: config.text
                opacity: inputRect.buffer === "" ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: inputRect.buffer === "" ? false : true
                onEntered: {
                    shape.scale = 0.8;
                }
                onExited: {
                    shape.scale = 0.7;
                }
                onClicked: {
                    sddm.login(inputRect.currentUser, inputRect.buffer, inputRect.currentSession);
                    inputRect.isLoading = true;
                }
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
