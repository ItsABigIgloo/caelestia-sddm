import "../singletons"
import Qt5Compat.GraphicalEffects
import QtQuick 2.15

Rectangle {
    id: root

    property var userPicker: null
    property var userModel: null

    implicitWidth: Theme.avatarFrameSize
    implicitHeight: Theme.avatarFrameSize
    radius: Theme.avatarFrameSize / 2
    color: Theme.withAlpha(Theme.mSurface, Theme.outerCardOpacity)
    clip: true

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

            maskSource: Rectangle {
                width: avatarImage.width
                height: avatarImage.height
                radius: Theme.avatarFrameSize / 2
            }

        }

    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.color: Theme.mPrimary
        border.width: 2
    }

}
