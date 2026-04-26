import QtQuick

Text {
    id: clock
    property bool firstInput
    property real mainCardComponentsOpacity
    property bool ap

    textFormat: Text.RichText
    text: {
        var time = ap ? Qt.formatTime(new Date(), "hh:mm AP") : Qt.formatTime(new Date(), "hh:mm");

        return time.replace(":", "<span style='color:" + config.primary + "'>:</span>");
    }
    font.pixelSize: 84
    font.family: "Rubik"
    font.bold: true
    color: config.secondary
    opacity: firstInput ? 0.0 : mainCardComponentsOpacity
    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutBack
        }
    }
}
