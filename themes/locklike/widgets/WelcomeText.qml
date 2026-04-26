import QtQuick

Item {
    id: topLeftRect
    property string welcomeString

    function getPhase() {
        var now = new Date();
        var hour = now.getHours();

        if (hour >= 20 || hour < 4) {
            welcomeString = "Good night";
        } else if (hour >= 4 && hour < 10) {
            welcomeString = "Good morning";
        } else {
            welcomeString = "Good day";
        }
    }
    Text {
        renderType: Text.NativeRendering
        width: topLeftRect.width - 40

        text: "<span style='color:" + config.text + ";'>" + topLeftRect.welcomeString + " </span>" + "<span style='color:" + config.primary + ";'>" + userPicker.displayText + "</span>"

        textFormat: Text.RichText

        anchors.centerIn: parent
        font.family: "Rubik"
        font.bold: false
        font.pixelSize: 40
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Timer {
        interval: 60000
        running: true
        onTriggered: topLeftRect.getPhase()
        repeat: true
    }
    Component.onCompleted: getPhase()
}
