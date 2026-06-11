import "../singletons"
import Qt5Compat.GraphicalEffects
import QtQuick 2.15
import "shapes"
import "shapes/material-shapes.js" as MaterialShapes

Item {
    id: root

    property var userPicker: null
    property var userModel: null
    property var shapeGetters: [MaterialShapes.getClamShell]
    // Calculate actual visual dimensions based on the shape bounds
    readonly property var bounds: bgShape.bounds
    readonly property real shapeHeightMultiplier: bounds ? (bounds[3] - bounds[1]) : 1
    readonly property real shapeWidthMultiplier: bounds ? (bounds[2] - bounds[0]) : 1

    implicitWidth: Theme.avatarFrameSize * shapeWidthMultiplier
    implicitHeight: Theme.avatarFrameSize * shapeHeightMultiplier
    clip: true

    Item {
        id: shapeContainer

        width: Theme.avatarFrameSize
        height: Theme.avatarFrameSize
        x: root.bounds ? -root.bounds[0] * Theme.avatarFrameSize : 0
        y: root.bounds ? -root.bounds[1] * Theme.avatarFrameSize : 0

        ShapeCanvas {
            id: bgShape

            anchors.fill: parent
            roundedPolygon: root.shapeGetters[0]()
            color: "#000000"
        }

        Image {
            id: avatarImage

            property var avatarCandidates: ["../assets/logo.png"]
            property int avatarCandidateIndex: 0
            property int roleHomeDir: Qt.UserRole + 3
            property int roleIcon: Qt.UserRole + 4

            function toSourceUrl(pathOrUrl) {
                if (!pathOrUrl || pathOrUrl === "")
                    return "";

                var value = String(pathOrUrl);
                if (value.startsWith("file://") || value.startsWith("qrc:/") || value.startsWith(":/") || value.startsWith("http://") || value.startsWith("https://"))
                    return value;

                if (value.startsWith("/"))
                    return "file://" + value;

                return value;
            }

            function appendCandidate(list, value) {
                var normalized = toSourceUrl(value);
                if (normalized !== "" && list.indexOf(normalized) === -1)
                    list.push(normalized);

            }

            function rebuildAvatarCandidates() {
                var list = [];
                appendCandidate(list, "../assets/avatar.face.icon");
                appendCandidate(list, "../assets/avatar.face");
                if (root.userPicker && root.userModel) {
                    if (root.userPicker.currentIndex >= 0 && root.userPicker.currentIndex < root.userModel.count) {
                        var modelIndex = root.userModel.index(root.userPicker.currentIndex, 0);
                        var icon = root.userModel.data(modelIndex, roleIcon);
                        var homeDir = root.userModel.data(modelIndex, roleHomeDir);
                        appendCandidate(list, icon);
                        if (homeDir && homeDir !== "") {
                            appendCandidate(list, homeDir + "/.face.icon");
                            appendCandidate(list, homeDir + "/.face");
                        }
                    }
                }
                appendCandidate(list, "../assets/logo.png");
                avatarCandidates = list;
                avatarCandidateIndex = 0;
            }

            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            smooth: true
            mipmap: true
            layer.enabled: true
            source: avatarCandidates.length > 0 ? avatarCandidates[avatarCandidateIndex] : "../assets/logo.png"
            onStatusChanged: {
                if (status === Image.Error && avatarCandidateIndex < avatarCandidates.length - 1)
                    avatarCandidateIndex += 1;

            }
            Component.onCompleted: rebuildAvatarCandidates()

            Connections {
                function onCurrentIndexChanged() {
                    avatarImage.rebuildAvatarCandidates();
                }

                target: root.userPicker
            }

            layer.effect: OpacityMask {
                maskSource: bgShape
            }

        }

    }

}
