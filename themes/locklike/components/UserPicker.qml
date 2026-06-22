import QtQuick
import QtQuick.Controls

ComboBox {
    id: root

    width: 190; height: 50
    anchors.right: parent.right; anchors.top: parent.top
    model: userModel
    currentIndex: userModel.lastIndex
    textRole: "name"
    font.family: "Rubik"; font.pixelSize: parseInt(config.userPickerSize) || 20
    visible: false

    background: Rectangle {
        color: "#BF131313"; radius: 30
        border.color: "#353535"; border.width: 1
    }

    contentItem: Text {
        renderType: Text.NativeRendering
        text: root.displayText
        font: root.font; color: "#e2e2e2"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.fill: parent
    }

    indicator: Canvas {
        x: root.width - 30
        y: (root.height - 6) / 2
        width: 12; height: 6
        onPaint: {
            var context = getContext("2d");
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = "#4cdadb";
            context.fill();
        }
    }
}
