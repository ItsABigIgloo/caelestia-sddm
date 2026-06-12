import Qt5Compat.GraphicalEffects
import QtQuick 2.15
import "shapes"
import "shapes/material-shapes.js" as MaterialShapes

Item {
    id: root

    z: 2

    /// Avatar shape: "hexagon" (Material Design blob) or "circle"
    property string avatarShape: "hexagon"

    // Hexagon mode properties
    property bool hovered: false
    property int hexIndex: 0
    property var shapeGetters: [MaterialShapes.getClamShell, MaterialShapes.getCookie6Sided]

    // Hover interaction (switches hexagon shape on hover; no-op in circle mode)
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: hovered = true
        onExited: hovered = false
    }

    onHoveredChanged: {
        if (root.avatarShape !== "hexagon")
            return;
        if (hovered) {
            root.hexIndex = 1;
        } else {
            root.hexIndex = 0;
        }
    }

    // --- Mask sources for OpacityMask ---

    // Hexagon shape (used as mask in hexagon mode)
    ShapeCanvas {
        id: hexMask
        anchors.fill: parent
        visible: root.avatarShape === "hexagon"
        roundedPolygon: root.shapeGetters[root.hexIndex]()
        color: "#000000"
        clip: true
    }

    // Circular mask (used as mask in circle mode)
    Rectangle {
        id: circleMask
        anchors.fill: parent
        visible: root.avatarShape === "circle"
        radius: Math.min(width, height) / 2
        color: "#000000"
    }

    // --- Profile picture ---

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
        anchors.fill: parent
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
            maskSource: root.avatarShape === "circle" ? circleMask : hexMask
        }
    }
}
