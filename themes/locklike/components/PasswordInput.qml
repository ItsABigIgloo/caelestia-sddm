import QtQuick
import QtQuick.Layouts
import "shapes"
import "shapes/material-shapes.js" as MaterialShapes

Rectangle {
    id: root
    color: "transparent"

    property alias currentSession: inputRect.currentSession
    property alias currentUser: inputRect.currentUser
    property alias buffer: inputRect.buffer
    property alias isLoading: inputRect.isLoading
    property alias firstInput: inputRect.firstInput
    property alias mainCardComponentsOpacity: inputRect.mainCardComponentsOpacity
    property int animDuration: 300

    signal focusRequested

    readonly property list<var> shapeGetters: [MaterialShapes.getCircle, MaterialShapes.getSlanted, MaterialShapes.getArch, MaterialShapes.getFan, MaterialShapes.getArrow, MaterialShapes.getSemiCircle, MaterialShapes.getTriangle, MaterialShapes.getDiamond, MaterialShapes.getClamShell, MaterialShapes.getGem, MaterialShapes.getSunny, MaterialShapes.getCookie4Sided, MaterialShapes.getCookie6Sided, MaterialShapes.getGhostish, MaterialShapes.getSoftBurst]

    readonly property list<var> shapeQueue: {
        var arr = [MaterialShapes.getSlanted, MaterialShapes.getArch, MaterialShapes.getFan, MaterialShapes.getArrow, MaterialShapes.getSemiCircle, MaterialShapes.getTriangle, MaterialShapes.getDiamond, MaterialShapes.getClamShell, MaterialShapes.getGem, MaterialShapes.getSunny, MaterialShapes.getCookie4Sided, MaterialShapes.getCookie6Sided, MaterialShapes.getGhostish, MaterialShapes.getSoftBurst];
        for (var i = arr.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            var tmp = arr[i]; arr[i] = arr[j]; arr[j] = tmp;
        }
        return arr;
    }

    Rectangle {
        id: inputRect

        property real mainCardComponentsOpacity
        property bool firstInput
        property bool isLoading
        property string buffer
        property string currentUser
        property int currentSession
        property int lastLength: 0

        onBufferChanged: {
            if (buffer.length > lastLength) {
                var added = buffer.length - lastLength;
                for (var i = 0; i < added; i++)
                    charModel.append({});
            } else if (buffer.length < lastLength) {
                var removed = lastLength - buffer.length;
                for (var j = 0; j < removed; j++)
                    if (charModel.count > 0)
                        charModel.remove(charModel.count - 1);
            }
            lastLength = buffer.length;
        }
        anchors.horizontalCenter: parent.horizontalCenter

        onIsLoadingChanged: {
            if (!inputRect.isLoading) {
                inputRect.width = 365;
            }
        }

        color: config.subComponents
        Behavior on color { ColorAnimation { duration: root.animDuration } }
        radius: 30
        width: inputRect.buffer === "" ? 300 : 365
        height: 45
        opacity: inputRect.firstInput ? 0 : inputRect.mainCardComponentsOpacity

        MouseArea {
            anchors.fill: parent
            onClicked: root.focusRequested()
        }

        Behavior on width {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutBack
            }
        }

        function shake() {
            shakeRotation.start();
        }

        Text {
            id: lockIcon
            renderType: Text.NativeRendering
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 17
            font.family: "Material Symbols Rounded"
            font.pointSize: 15
            text: "\ue897"
            color: '#a8a8a8'
            visible: !inputRect.isLoading
        }

        ShapeCanvas {
            id: loadingShape
            property int index: 0
            property var shapeGetters: [MaterialShapes.getGem, MaterialShapes.getSunny, MaterialShapes.getCookie4Sided, MaterialShapes.getCookie6Sided, MaterialShapes.getVerySunny]
            opacity: inputRect.isLoading ? 1 : 0
            color: config.secondary
            Behavior on color { ColorAnimation { duration: root.animDuration } }

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 17

            implicitWidth: lockIcon.height / 2 * 2.1
            implicitHeight: lockIcon.height / 2 * 2.1
            roundedPolygon: loadingShape.shapeGetters[loadingShape.index]()

            Timer {
                running: inputRect.isLoading
                interval: 500
                onTriggered: {
                    if (loadingShape.index == 4) {
                        loadingShape.index = 0;
                    } else {
                        loadingShape.index = loadingShape.index + 1;
                    }
                    scaleAnim.running = true;
                }
                repeat: true
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 400
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

        SequentialAnimation {
            id: pulseColorRect1
            running: inputRect.isLoading

            NumberAnimation {
                target: inputRect
                property: "width"
                to: 300
                duration: 300
                easing.type: Easing.OutBack
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
                text: inputRect.isLoading ? config.loadingText : config.passwordPlaceholder
                color: '#6e6e6e'
                font.family: "Rubik"
                opacity: inputRect.buffer === "" ? 1 : 0
                Behavior on opacity {
                    NumberAnimation { duration: 100 }
                }
            }

            ListModel { id: charModel }

            Row {
                id: dots
                spacing: 3

                property real actualDotsWidth: inputRect.buffer.length * 15 + (inputRect.buffer.length - 1) * 3

                width: actualDotsWidth
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenterOffset: actualDotsWidth > parent.width ? (parent.width - actualDotsWidth) / 2 : 0
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: charModel

                    delegate: Item {
                        implicitWidth: 15
                        implicitHeight: 15

                        property int shapeIndex: Math.floor(Math.random() * (root.shapeQueue.length)) + 1

                        ShapeCanvas {
                            id: dotShape
                            anchors.centerIn: parent
                            implicitWidth: 15
                            implicitHeight: 15
                            color: "white"
                            scale: 1.0
                            opacity: 1.0
                            roundedPolygon: root.shapeGetters[parent.shapeIndex]()

                            SequentialAnimation {
                                running: true

                                ParallelAnimation {
                                    NumberAnimation {
                                        target: dotShape
                                        property: "opacity"
                                        from: 0; to: 1; duration: 300
                                        easing.type: Easing.OutCubic
                                    }
                                    NumberAnimation {
                                        target: dotShape
                                        property: "scale"
                                        from: 0; to: 1; duration: 250
                                        easing.type: Easing.OutCubic
                                    }
                                }
                                PauseAnimation {
                                    duration: 180
                                }
                                ParallelAnimation {
                                    NumberAnimation {
                                        target: dotShape
                                        property: "opacity"
                                        to: 0; duration: 50
                                    }
                                    NumberAnimation {
                                        target: dotShape
                                        property: "scale"
                                        to: 2 / 3; duration: 50
                                        easing.type: Easing.OutCubic
                                    }
                                }
                                PropertyAction {
                                    target: dotShape.parent
                                    property: "shapeIndex"
                                    value: 0
                                }
                                ParallelAnimation {
                                    NumberAnimation {
                                        target: dotShape
                                        property: "opacity"
                                        to: 1; duration: 50
                                    }
                                    NumberAnimation {
                                        target: dotShape
                                        property: "scale"
                                        to: 2 / 3; duration: 50
                                        easing.type: Easing.OutCubic
                                    }
                                }
                                NumberAnimation {
                                    target: dotShape
                                    property: "scale"
                                    to: 1.0; duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }
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
                    Behavior on color { ColorAnimation { duration: root.animDuration } }
                    opacity: inputRect.buffer === "" ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                }

                Behavior on color {
                    ColorAnimation { duration: root.animDuration; easing.type: Easing.OutCubic }
                }
                Behavior on scale {
                    NumberAnimation { duration: root.animDuration; easing.type: Easing.OutCubic }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: inputRect.buffer === "" ? false : true
                    onEntered: { shape.scale = 0.8; }
                    onExited: { shape.scale = 0.7; }
                    onClicked: {
                        sddm.login(inputRect.currentUser, inputRect.buffer, inputRect.currentSession);
                        inputRect.isLoading = true;
                        inputRect.buffer = "";
                    }
                }
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack }
        }
    }
}
