import "../components"
import QtQuick

Item {
    property real rectHeight
    property real rectRadius
    property real rectBigRadius

    anchors.fill: parent

    Rectangle {
        id: powerBtn

        anchors.left: parent.left
        anchors.top: parent.top
        height: parent.rectHeight
        width: parent.rectHeight + 10
        radius: parent.rectRadius
        bottomLeftRadius: parent.rectBigRadius
        color: config.subComponents
        clip: true

        MaterialIcon {
            id: powerIcon

            property bool hovered: false

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 50
            anchors.topMargin: 30
            text: "\ue8ac"
            color: config.primary
            pointSize: 70
        }

        LayerState {
            anchors.fill: parent
            onClicked: {
                sddm.powerOff();
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
            }

        }

    }

    Rectangle {
        id: rebootBtn

        anchors.right: parent.right
        anchors.top: parent.top
        height: bottomLeftRect.height
        width: bottomLeftRect.height + 10
        radius: bottomLeftRect.radius
        color: config.subComponents
        clip: true

        MaterialIcon {
            id: restartIcon

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 47
            anchors.topMargin: 30
            text: "\ue863"
            color: config.secondary
            pointSize: 70
        }

        LayerState {
            anchors.fill: parent
            onClicked: {
                sddm.reboot();
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
            }

        }

    }

}
