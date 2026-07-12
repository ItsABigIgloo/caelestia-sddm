import QtQuick
import M3Shapes

Item {
    id: root

    property string buffer: ""

    ListModel {
        id: dotModel
    }
    onBufferChanged: {
        while (dotModel.count < buffer.length)
            dotModel.append({
                shapeIdx: Math.floor(Math.random() * 5)
            });
        while (dotModel.count > buffer.length)
            dotModel.remove(dotModel.count - 1);
    }

    Row {
        id: dots
        spacing: 3

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
            model: dotModel

            delegate: MaterialShape {
                id: dot

                required property int shapeIdx

                implicitSize: 15
                width: 15
                height: 15
                color: "white"
                scale: 0
                opacity: 0

                property var shapeQueue: [MaterialShape.Gem, MaterialShape.Sunny, MaterialShape.Cookie4Sided, MaterialShape.VerySunny, MaterialShape.Cookie6Sided]
                fromShape: shapeQueue[shapeIdx]
                toShape: MaterialShape.Circle
                morphProgress: 0

                SequentialAnimation {
                    id: initAnim
                    running: true

                    ParallelAnimation {
                        NumberAnimation {
                            target: dot
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 150
                        }
                        SequentialAnimation {
                            NumberAnimation {
                                target: dot
                                property: "scale"
                                from: 0
                                to: 1.4
                                duration: 180
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: dot
                                property: "scale"
                                to: 1
                                duration: 150
                            }
                        }
                    }
                    PauseAnimation {
                        duration: 180
                    }
                    NumberAnimation {
                        target: dot
                        property: "morphProgress"
                        from: 0
                        to: 1
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
