import QtQuick

Item {
    id: root

    property int animDuration: 300
    property string currentUser: ""
    property int _activeLayer: 0

    function prepareForUser(user) {
        var hidden = _activeLayer === 0 ? wallpaperB : wallpaperA;
        hidden.source = "../assets/background-" + user;
    }

    function switchLayer() {
        _activeLayer = _activeLayer === 0 ? 1 : 0;
    }

    anchors.fill: parent

    AnimatedImage {
        id: wallpaperA

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        opacity: _activeLayer === 0 ? 1 : 0
        onStatusChanged: {
            if (status === Image.Error)
                source = "../assets/background";

        }
        Component.onCompleted: {
            source = "../assets/background-" + root.currentUser;
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.animDuration
                easing: Easing.InOutCubic
            }

        }

    }

    AnimatedImage {
        id: wallpaperB

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        opacity: _activeLayer === 1 ? 1 : 0
        onStatusChanged: {
            if (status === Image.Error)
                source = "../assets/background";

        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.animDuration
                easing: Easing.InOutCubic
            }

        }

    }

}
