import "../widgets"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root

    property bool firstInput: false
    property real mainCardComponentsOpacity: 1
    property int animDuration: 300
    property real midRadius: 50
    property real mainCardRadius: 70
    property string currentUser: ""
    property string currentSession: ""
    property bool powerConfirmEnabled: false
    readonly property alias welcomeString: greeting.welcomeString

    signal powerRequested()
    signal rebootRequested()

    function crossfadeGreeting() {
        greeting.crossfadeText();
    }

    function crossfadeFetchPanel() {
        fetchPanel.crossfadeUserName();
    }

    function refreshGreeting() {
        greeting.getPhase();
    }

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

        WelcomeText {
            id: greeting

            animDuration: root.animDuration
            anchors.centerIn: parent
        }

        Behavior on color {
            ColorAnimation {
                duration: root.animDuration
            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.animDuration
                easing.type: Easing.OutBack
            }

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

        CaelestiaFetch {
            id: fetchPanel

            firstInput: root.firstInput
            currentUser: root.currentUser
            currentSession: root.currentSession
            rectHeight: middleLeftRect.height
            animDuration: root.animDuration
        }

        Behavior on color {
            ColorAnimation {
                duration: root.animDuration
            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.animDuration
                easing.type: Easing.OutBack
            }

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
            id: sysBtns
            anchors.horizontalCenter: parent.horizontalCenter
            rectHeight: bottomLeftRect.height
            rectWidth: bottomLeftRect.height - 1
            rectRadius: bottomLeftRect.radius
            rectBigRadius: root.mainCardRadius / 1.9
            powerConfirmEnabled: root.powerConfirmEnabled
            onPowerClicked: {
                if (root.powerConfirmEnabled)
                    root.powerRequested();
                else
                    sddm.powerOff();
            }
            onRebootClicked: {
                if (root.powerConfirmEnabled)
                    root.rebootRequested();
                else
                    sddm.reboot();
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.animDuration
                easing.type: Easing.OutBack
            }

        }

    }

}
