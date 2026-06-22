import Qt5Compat.GraphicalEffects
import QtQuick 2.15
import "shapes"
import "shapes/material-shapes.js" as MaterialShapes

Item {
    id: root

    property string avatarShape: "hexagon"
    property string currentUser: ""
    property bool hovered: false
    property int hexIndex: 0
    property int animDuration: 300
    property int _activeAvatar: 0
    property var shapeGetters: [MaterialShapes.getClamShell, MaterialShapes.getCookie6Sided]
    property var fallbackCandidates: ["../assets/avatar.face.icon", "../assets/avatar.face", "../assets/avatar.jpg", "../assets/avatar.png"]
    property int fallbackIndex: -1

    function prepareNext() {
        if (currentUser === "")
            return ;

        fallbackIndex = -1;
        var next = currentUser !== "" ? "../assets/avatar-" + currentUser + ".face" : "";
        var hidden = _activeAvatar === 0 ? avatarB : avatarA;
        hidden.source = next;
    }

    function crossfade() {
        if (currentUser === "")
            return ;

        _activeAvatar = _activeAvatar === 0 ? 1 : 0;
    }

    z: 2
    onHoveredChanged: {
        if (root.avatarShape !== "hexagon")
            return ;

        if (hovered)
            root.hexIndex = 1;
        else
            root.hexIndex = 0;
    }
    onCurrentUserChanged: prepareNext()

    ShapeCanvas {
        id: hexMask

        anchors.fill: parent
        visible: root.avatarShape === "hexagon"
        roundedPolygon: root.shapeGetters[root.hexIndex]()
        color: "#000000"
        clip: true
    }

    Rectangle {
        id: circleMask

        anchors.fill: parent
        visible: root.avatarShape === "circle"
        radius: Math.min(width, height) / 2
        color: "#000000"
    }

    Image {
        id: avatarA

        mipmap: true
        smooth: true
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        layer.enabled: true
        opacity: _activeAvatar === 0 ? 1 : 0
        onStatusChanged: {
            if (status === Image.Error) {
                fallbackIndex++;
                if (fallbackIndex < fallbackCandidates.length)
                    source = fallbackCandidates[fallbackIndex];

            }
        }
        Component.onCompleted: {
            source = currentUser !== "" ? "../assets/avatar-" + currentUser + ".face" : "";
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.animDuration
                easing: Easing.InOutCubic
            }

        }

        layer.effect: OpacityMask {
            maskSource: root.avatarShape === "circle" ? circleMask : hexMask
        }

    }

    Image {
        id: avatarB

        mipmap: true
        smooth: true
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        layer.enabled: true
        opacity: _activeAvatar === 0 ? 0 : 1
        onStatusChanged: {
            if (status === Image.Error) {
                fallbackIndex++;
                if (fallbackIndex < fallbackCandidates.length)
                    source = fallbackCandidates[fallbackIndex];

            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.animDuration
                easing: Easing.InOutCubic
            }

        }

        layer.effect: OpacityMask {
            maskSource: root.avatarShape === "circle" ? circleMask : hexMask
        }

    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: hovered = true
        onExited: hovered = false
    }

}
