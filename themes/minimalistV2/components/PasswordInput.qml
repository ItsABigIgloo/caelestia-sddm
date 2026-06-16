import "../singletons"
import QtQuick 2.15
import QtQuick.Layouts 1.15
import "shapes"
import "shapes/material-shapes.js" as MaterialShapes

Item {
    id: root

    property string buffer: ""
    property var onLogin: null
    property var onRestoreFocus: null
    property bool isError: false
    property bool isAuthenticating: false
    property bool capsLockOn: false

    implicitWidth: 365
    implicitHeight: 48

    Rectangle {
        id: inputRect

        anchors.centerIn: parent
        width: root.isAuthenticating ? 300 : (root.buffer === "" ? 300 : 365)
        height: 48
        color: Theme.withAlpha(Theme.mSurface, Theme.elementOpacity)
        radius: Math.min(Theme.elementRadius, height / 2)

        Item {
            id: lockIconContainer

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 17 - (width - lockIcon.font.pixelSize) / 2
            width: lockIcon.font.pixelSize * 1.6
            height: lockIcon.font.pixelSize * 1.6
            visible: !root.isAuthenticating

            Rectangle {
                id: capsLockCircle

                anchors.fill: parent
                radius: width / 2
                color: Theme.mPrimary
                opacity: root.capsLockOn ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animDurationFast
                    }

                }

            }

            Text {
                id: lockIcon

                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                renderType: Text.NativeRendering
                font.family: "Material Symbols Outlined"
                font.pixelSize: Math.round(Theme.baseFontSize * 1.5)
                text: "lock"
                color: capsLockCircle.opacity > 0.5 ? Theme.mOnPrimary : Theme.mOnSurfaceVariant

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animDurationFast
                    }

                }

            }

        }

        ShapeCanvas {
            id: loadingShape

            property int index: 0
            property var shapeGetters: [MaterialShapes.getGem, MaterialShapes.getSunny, MaterialShapes.getCookie4Sided, MaterialShapes.getCookie6Sided, MaterialShapes.getVerySunny]

            opacity: root.isAuthenticating ? 1 : 0
            color: Theme.mPrimary
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 17
            implicitWidth: lockIcon.font.pixelSize * 1.2
            implicitHeight: lockIcon.font.pixelSize * 1.2
            roundedPolygon: loadingShape.shapeGetters[loadingShape.index]()

            Timer {
                running: root.isAuthenticating
                interval: 500
                onTriggered: {
                    if (loadingShape.index === 4)
                        loadingShape.index = 0;
                    else
                        loadingShape.index = loadingShape.index + 1;
                    scaleAnim.running = true;
                }
                repeat: true
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animDurationFast
                }

            }

        }

        SequentialAnimation {
            id: scaleAnim

            running: false

            NumberAnimation {
                target: loadingShape
                property: "scale"
                to: 1.2
                duration: 100
            }

            NumberAnimation {
                target: loadingShape
                property: "scale"
                to: 1
                duration: 100
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

        Rectangle {
            id: inputBorders

            anchors.centerIn: parent
            color: "transparent"
            radius: Math.min(Theme.elementRadius, height / 2)
            width: 250
            height: parent.height - 8
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
                        radius: width / 2
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
            id: inputButtonShape

            property var shapeGetters: [MaterialShapes.getCircle, MaterialShapes.getArrow]

            radius: width / 2
            width: parent.height - 8
            height: parent.height - 8
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 4
            color: "transparent"

            ShapeCanvas {
                id: buttonShape

                rotation: 90
                scale: {
                    if (root.buffer === "")
                        return 0.9;

                    return buttonShapeMouseArea.containsMouse ? 0.8 : 0.7;
                }
                implicitWidth: inputButtonShape.height * 1.05
                implicitHeight: inputButtonShape.height * 1.05
                roundedPolygon: root.buffer === "" ? inputButtonShape.shapeGetters[0]() : inputButtonShape.shapeGetters[1]()
                color: root.buffer === "" ? Theme.mSurfaceVariant : Theme.mPrimary
                y: -1

                Text {
                    renderType: Text.NativeRendering
                    anchors.centerIn: parent
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: Math.round(Theme.baseFontSize * 1.6)
                    rotation: -90
                    text: "arrow_forward"
                    color: root.buffer === "" ? Theme.mOnSurface : Theme.mOnPrimary
                    opacity: root.buffer === "" ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.animDurationFast
                            easing.type: Easing.OutCubic
                        }

                    }

                }

                MouseArea {
                    id: buttonShapeMouseArea

                    anchors.fill: parent
                    hoverEnabled: root.buffer !== ""
                    cursorShape: root.buffer !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (root.buffer !== "") {
                            if (root.onLogin)
                                root.onLogin();

                            if (root.onRestoreFocus)
                                root.onRestoreFocus();

                        }
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animDurationFast
                        easing.type: Easing.OutCubic
                    }

                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Theme.animDurationFast
                        easing.type: Easing.OutCubic
                    }

                }

            }

        }

        Behavior on width {
            NumberAnimation {
                duration: Theme.animDurationNormal
                easing.type: Easing.OutBack
            }

        }

    }

    Connections {
        function onIsErrorChanged() {
            if (root.isError)
                shakeRotation.start();

        }

        target: root
    }

}
