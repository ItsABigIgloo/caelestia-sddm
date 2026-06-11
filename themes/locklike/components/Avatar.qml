import Qt5Compat.GraphicalEffects
import QtQuick 2.15
import "shapes"
import "shapes/material-shapes.js" as MaterialShapes

ShapeCanvas {
    id: root

    z: 2
    implicitWidth: root.height / 2 * 2.1
    implicitHeight: root.height / 2 * 2.1
    roundedPolygon: root.shapeGetters[index]()
    color: "#000000"

    property bool hovered: false
    property int index: 0

    MouseArea {
        anchors.fill: avatarImage
        hoverEnabled: true
        onEntered: hovered = true
        onExited: hovered = false
    }

    onHoveredChanged: {
        if (hovered) {
            root.index = 1;
        } else {
            root.index = 0;
        }
    }

    clip: true

    property var shapeGetters: [MaterialShapes.getClamShell, MaterialShapes.getCookie6Sided]

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
