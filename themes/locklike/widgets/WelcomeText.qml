import QtQuick

Item {
    id: topLeftRect

    property string welcomeString
    property int animDuration: 300
    property int _activeGreeting: 0

    function getPhase() {
        var now = new Date();
        var hour = now.getHours();
        if (hour >= 20 || hour < 4)
            welcomeString = "Good night";
        else if (hour >= 4 && hour < 10)
            welcomeString = "Good morning";
        else
            welcomeString = "Good afternoon";
    }

    function crossfadeText() {
        var hidden = _activeGreeting === 0 ? userNameB : userNameA;
        hidden.text = userPicker.displayText;
        _activeGreeting = _activeGreeting === 0 ? 1 : 0;
    }

    Component.onCompleted: {
        getPhase();
        userNameA.text = userPicker.displayText;
    }

    Column {
        anchors.centerIn: parent

        Text {
            renderType: Text.NativeRendering
            text: topLeftRect.welcomeString
            color: config.text
            Behavior on color { ColorAnimation { duration: topLeftRect.animDuration } }
            font.family: "Rubik"; font.bold: false; font.pixelSize: parseInt(config.welcomeFontSize) || 40
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item {
                width: 200
                height: userNameA.height
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: userNameA
                    anchors.horizontalCenter: parent.horizontalCenter
                    renderType: Text.NativeRendering
                    color: config.primary
                    Behavior on color { ColorAnimation { duration: topLeftRect.animDuration } }
                    font.family: "Rubik"; font.bold: false; font.pixelSize: parseInt(config.welcomeFontSize) || 40
                    opacity: _activeGreeting === 0 ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation { duration: root.animDuration; easing: Easing.InOutCubic }
                    }
                }

                Text {
                    id: userNameB
                    anchors.horizontalCenter: parent.horizontalCenter
                    renderType: Text.NativeRendering
                    color: config.primary
                    Behavior on color { ColorAnimation { duration: topLeftRect.animDuration } }
                    font.family: "Rubik"; font.bold: false; font.pixelSize: parseInt(config.welcomeFontSize) || 40
                    opacity: _activeGreeting === 0 ? 0 : 1
                    Behavior on opacity {
                        NumberAnimation { duration: root.animDuration; easing: Easing.InOutCubic }
                    }
                }
            }
    }

    Timer {
        interval: 60000
        running: true
        onTriggered: topLeftRect.getPhase()
        repeat: true
    }
}
