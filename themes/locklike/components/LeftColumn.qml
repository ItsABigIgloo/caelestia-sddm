import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../widgets"

ColumnLayout {
    id: root

    property bool firstInput: false
    property real mainCardComponentsOpacity: 1
    property int animDuration: 300
    property real midRadius: 50
    property real mainCardRadius: 70
    property string currentUser: ""
    property string currentSession: ""

    readonly property alias welcomeString: greeting.welcomeString

    function crossfadeGreeting() { greeting.crossfadeText(); }
    function crossfadeFetchPanel() { fetchPanel.crossfadeUserName(); }
    function refreshGreeting() { greeting.getPhase(); }

    spacing: 13
    Layout.alignment: Qt.AlignLeft

    Rectangle {
        id: topLeftRect
        width: 390
        height: 220
        color: config.subComponents
        radius: root.midRadius
        opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity
        clip: true

        Behavior on color {
            ColorAnimation { duration: root.animDuration }
        }

        WelcomeText {
            id: greeting
            animDuration: root.animDuration
            anchors.centerIn: parent
        }

        Behavior on opacity {
            NumberAnimation { duration: root.animDuration; easing.type: Easing.OutBack }
        }
    }

    Rectangle {
        id: middleLeftRect
        width: 390
        Layout.fillHeight: true
        color: config.subComponents
        radius: root.mainCardRadius / 4
        opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity
        clip: true

        Behavior on color {
            ColorAnimation { duration: root.animDuration }
        }

        CaelestiaFetch {
            id: fetchPanel
            firstInput: root.firstInput
            currentUser: root.currentUser
            currentSession: root.currentSession
            rectHeight: middleLeftRect.height
            animDuration: root.animDuration
        }

        Behavior on opacity {
            NumberAnimation { duration: root.animDuration; easing.type: Easing.OutBack }
        }
    }

    Rectangle {
        id: bottomLeftRect
        width: 390
        height: 190
        color: "transparent"
        bottomLeftRadius: root.mainCardRadius / 1.9
        radius: root.midRadius / 1.7
        opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity

        SystemButtons {
            anchors.horizontalCenter: parent.horizontalCenter
            rectHeight: bottomLeftRect.height
            rectWidth: bottomLeftRect.height - 1
            rectRadius: bottomLeftRect.radius
            rectBigRadius: root.mainCardRadius / 1.9
        }

        Behavior on opacity {
            NumberAnimation { duration: root.animDuration; easing.type: Easing.OutBack }
        }
    }
}
