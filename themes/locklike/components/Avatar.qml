import QtQuick 2.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root

    radius: 120
    color: "black"
    clip: true

    Image {
        id: avatarImage

        property var avatarCandidates: ["../assets/avatar.face.icon", "../assets/avatar.face", "../assets/avatar.jpg"]
        property int avatarCandidateIndex: 0

        Timer {
            id: retryTimer
            interval: 0
            onTriggered: avatarImage.loadNextAvatar()
        }

        function loadNextAvatar() {
            if (avatarCandidateIndex < avatarCandidates.length) {
                source = avatarCandidates[avatarCandidateIndex];
                avatarCandidateIndex++;
            }
        }

        anchors.fill: parent
        source: ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: parent
        }

        onStatusChanged: {
            if (status === Image.Error)
                retryTimer.start();
        }

        Component.onCompleted: loadNextAvatar()
    }
}
