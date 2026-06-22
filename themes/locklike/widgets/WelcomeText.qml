import QtQuick

Item {
    id: topLeftRect

    property string welcomeString

    function getPhase() {
        var now = new Date();
        var hour = now.getHours();
        if (hour >= 20 || hour < 4)
            welcomeString = config.greetingNight;
        else if (hour >= 4 && hour < 10)
            welcomeString = config.greetingMorning;
        else
            welcomeString = config.greetingAfternoon;
    }

    Component.onCompleted: getPhase()

    Text {
        renderType: Text.NativeRendering
        width: 370
        text: "<span style='color:" + config.text + ";'>" + topLeftRect.welcomeString + " </span>" + "<span style='color:" + config.primary + ";'>" + userPicker.displayText + "</span>"
        textFormat: Text.RichText
        wrapMode: Text.WordWrap
        anchors.centerIn: parent

        Text {
            renderType: Text.NativeRendering
            text: topLeftRect.welcomeString
            color: config.text
            Behavior on color { ColorAnimation { duration: topLeftRect.animDuration } }
            font.family: "Rubik"; font.bold: false; font.pixelSize: 40
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
                    font.family: "Rubik"; font.bold: false; font.pixelSize: 40
                    opacity: _activeGreeting === 0 ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation { duration: topLeftRect.animDuration; easing: Easing.InOutCubic }
                    }
                }

                Text {
                    id: userNameB
                    anchors.horizontalCenter: parent.horizontalCenter
                    renderType: Text.NativeRendering
                    color: config.primary
                    Behavior on color { ColorAnimation { duration: topLeftRect.animDuration } }
                    font.family: "Rubik"; font.bold: false; font.pixelSize: 40
                    opacity: _activeGreeting === 0 ? 0 : 1
                    Behavior on opacity {
                        NumberAnimation { duration: topLeftRect.animDuration; easing: Easing.InOutCubic }
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
