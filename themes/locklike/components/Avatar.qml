import Qt5Compat.GraphicalEffects
import QtQuick 2.15

Rectangle {
    id: root

    radius: root.height / 2
    color: "black"
    clip: true

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
            maskSource: parent
        }

    }

}
