import "../singletons"
import Qt5Compat.GraphicalEffects
import QtQuick 2.15
import "shapes"
import "shapes/material-shapes.js" as MaterialShapes

Item {
    id: root

    property int currentUserIndex: 0
    property var userModel: null
    // Calculate actual visual dimensions based on the shape bounds
    readonly property var bounds: bgShape.bounds

    onCurrentUserIndexChanged: {
        if (avatarImage.status !== Image.Null) {
            avatarImage.rebuildAvatarCandidates();
        }
    }

    implicitWidth: Theme.avatarFrameSize
    implicitHeight: Theme.avatarFrameSize
    clip: true

    Item {
        id: shapeContainer

        width: Theme.avatarFrameSize
        height: Theme.avatarFrameSize
        x: root.bounds ? (root.implicitWidth / 2 - (root.bounds[0] + root.bounds[2]) / 2 * Theme.avatarFrameSize) : 0
        y: root.bounds ? (root.implicitHeight / 2 - (root.bounds[1] + root.bounds[3]) / 2 * Theme.avatarFrameSize) : 0

        ShapeCanvas {
            id: bgShape

            anchors.fill: parent
            roundedPolygon: {
                if (Theme.avatarShape === "circle")
                    return MaterialShapes.getCircle();
                if (Theme.avatarShape === "cookie4sided" || Theme.avatarShape === "cookie4")
                    return MaterialShapes.getCookie4Sided();
                return MaterialShapes.getClamShell();
            }
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
                if (root.userModel) {
                    if (root.currentUserIndex >= 0 && root.currentUserIndex < root.userModel.count) {
                        var modelIndex = root.userModel.index(root.currentUserIndex, 0);
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

            layer.effect: OpacityMask {
                maskSource: bgShape
            }

        }

    }

}
