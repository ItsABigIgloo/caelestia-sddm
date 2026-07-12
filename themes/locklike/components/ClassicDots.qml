import QtQuick
import "shapes"
import "shapes/material-shapes.js" as MaterialShapes

Item {
    id: root

    property string buffer: ""

    property int lastLength: 0
    onBufferChanged: {
        if (buffer.length > lastLength)
            dots.currentIndex = buffer.length - 1;
        lastLength = buffer.length;
    }

    Row {
        id: dots
        spacing: 3

        property int currentIndex: -1
        property real fullWidth: root.buffer.length * 15 + (root.buffer.length - 1) * 3 + parent.height

        width: fullWidth
        anchors.centerIn: parent

        Behavior on width {
            NumberAnimation {
                duration: 150
                easing: Easing.OutCubic
            }
        }

        Repeater {
            model: root.buffer.length

            delegate: ShapeCanvas {
                implicitWidth: 15
                implicitHeight: 15
                color: "white"
                scale: 1.0
                opacity: 1.0

                property int shapeIndex: isNew ? Math.floor(Math.random() * (4 - 1 + 1)) + 1 : 0
                property bool isNew: index === dots.currentIndex
                property var shapeGetters: [MaterialShapes.getCircle, MaterialShapes.getGem, MaterialShapes.getSunny, MaterialShapes.getCookie4Sided, MaterialShapes.getCookie6Sided, MaterialShapes.getVerySunny]
                roundedPolygon: shapeGetters[shapeIndex]()

                SequentialAnimation on scale {
                    running: isNew
                    NumberAnimation {
                        from: 0
                        to: 1.4
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        to: 1.0
                        duration: 150
                    }
                }

                SequentialAnimation on opacity {
                    running: isNew
                    NumberAnimation {
                        from: 0
                        to: 1
                        duration: 200
                    }
                }
                Component.onCompleted: {
                    timerShape.running = true;
                }
                Timer {
                    id: timerShape
                    interval: 300
                    repeat: false
                    running: false
                    onTriggered: {
                        shapeIndex = 0;
                    }
                }
            }
        }
    }
}
