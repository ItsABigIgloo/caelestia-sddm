import Qt5Compat.GraphicalEffects
import QtQuick 2.15
import "shapes"
import "shapes/material-shapes.js" as MaterialShapes

ShapeCanvas {
    id: root

    anchors.left: parent.left
    anchors.leftMargin: 35

    z: 2
    implicitWidth: root.height / 2 * 2.1
    implicitHeight: root.height / 2 * 2.1
    roundedPolygon: root.shapeGetters[0]()
    color: "#000000"

    clip: true

    property var shapeGetters: [MaterialShapes.getClamShell]

    Image {
        id: avatarImage

        property var avatarCandidates: ["../assets/avatar.face.icon", "../assets/avatar.face", "../assets/avatar.jpg", "../assets/avatar.png"]
        property int avatarCandidateIndex: 0

        function loadNextAvatar() {
            if (avatarCandidateIndex < avatarCandidates.length) {
                source = avatarCandidates[avatarCandidateIndex];
                avatarCandidateIndex++;
            }
        }

        mipmap: true
        smooth: true
        anchors.fill: root
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        layer.enabled: true
        onStatusChanged: {
            if (status === Image.Error)
                retryTimer.start();
        }
        Component.onCompleted: loadNextAvatar()

        Timer {
            id: retryTimer

            interval: 0
            onTriggered: avatarImage.loadNextAvatar()
        }

        layer.effect: OpacityMask {
            maskSource: root
        }
    }
}
