import QtQuick

Rectangle {
    id: settingsPanel
    z: 100

    property bool sOpen: false
    property int animDuration: 300
    property int syncDelay: 150
    property real bgBlur: 0.5
    property var localeManager: null
    property bool btnHov: false
    property bool _contentReady: false

    width: sOpen ? 320 : 44
    height: sOpen ? 440 : 44
    radius: sOpen ? 24 : 22
    Behavior on width { NumberAnimation { duration: 280; easing.type: Easing.OutQuint } }
    Behavior on height { NumberAnimation { duration: 280; easing.type: Easing.OutQuint } }
    Behavior on radius { NumberAnimation { duration: 220; easing.type: Easing.OutQuint } }
    Behavior on color { ColorAnimation { duration: settingsPanel.animDuration } }
    color: sOpen ? config.subComponents : Qt.rgba(0, 0, 0, btnHov ? 0.55 : 0.35)

    Timer {
        id: contentTimer
        onTriggered: settingsPanel._contentReady = true
    }

    onSOpenChanged: {
        if (!sOpen) settingsPanel._contentReady = false;
    }

    Item {
        anchors.left: parent.left; anchors.right: parent.right
        anchors.top: parent.top; anchors.topMargin: 8
        height: 28
        visible: sOpen

        Text {
            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 20
            text: config.settingsTitle; color: config.text
            Behavior on color { ColorAnimation { duration: settingsPanel.animDuration } }
            font.family: "Rubik"; font.pixelSize: 18; font.bold: true
        }

        Item {
            anchors.right: parent.right; anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 28; height: 28
            Rectangle {
                anchors.fill: parent; radius: 14
                color: Qt.rgba(1, 1, 1, settingsPanel.btnHov ? 0.15 : 0.06)
                Behavior on color { ColorAnimation { duration: 120 } }
            }
            Text {
                anchors.centerIn: parent
                font.family: "Material Symbols Rounded"
                font.pointSize: 16
                text: "\ue5cd"
                color: "#e0e0e0"
            }
            MouseArea {
                anchors.fill: parent; hoverEnabled: true
                onEntered: settingsPanel.btnHov = true
                onExited: settingsPanel.btnHov = false
                onClicked: {
                    contentTimer.stop();
                    settingsPanel._contentReady = false;
                    closeTimer.restart();
                }
            }
        }
    }

    Timer {
        id: closeTimer
        interval: 180
        onTriggered: settingsPanel.sOpen = false
    }

    Item {
        id: gearBtn
        anchors.right: parent.right; anchors.top: parent.top
        anchors.rightMargin: 8; anchors.topMargin: 8
        width: 28; height: 28
        visible: !sOpen
        Rectangle {
            anchors.fill: parent; radius: 14
            color: Qt.rgba(1, 1, 1, settingsPanel.btnHov ? 0.15 : 0.06)
            Behavior on color { ColorAnimation { duration: 120 } }
        }
        Text {
            anchors.centerIn: parent
            font.family: "Material Symbols Rounded"
            font.pointSize: 20
            text: "\ue8b8"
            color: "#e0e0e0"
        }
        MouseArea {
            anchors.fill: parent; hoverEnabled: true
            onEntered: settingsPanel.btnHov = true
            onExited: settingsPanel.btnHov = false
                onClicked: {
                    closeTimer.stop();
                    settingsPanel.sOpen = true;
                    contentTimer.interval = 280;
                    contentTimer.restart();
                }
        }
    }

    Item {
        id: panelContent
        visible: opacity > 0
        anchors.fill: parent
        anchors.leftMargin: 20; anchors.rightMargin: 20
        anchors.topMargin: 44; anchors.bottomMargin: 20
        opacity: _contentReady ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 180 } }

        Column {
            id: settingsColumn
            anchors.fill: parent
            spacing: 16
            Rectangle {
                height: 1
                anchors.left: parent.left; anchors.right: parent.right
                anchors.leftMargin: -20; anchors.rightMargin: -20
                color: config.surfaceVariant || Qt.rgba(1, 1, 1, 0.06)
            }

            Text {
                text: config.animationSpeed; color: config.textDark
                font.family: "Rubik"; font.pixelSize: 13
            }

            Row {
                spacing: 12; width: parent.width
                SliderStyle {
                    width: parent.width - 60
                    value: settingsPanel.animDuration
                    maxValue: 1000
                    onValueChanged: if (value !== settingsPanel.animDuration) settingsPanel.animDuration = value
                }
                Text {
                    text: settingsPanel.animDuration === 0 ? "off" : settingsPanel.animDuration + "ms"
                    color: config.primary
                    Behavior on color { ColorAnimation { duration: settingsPanel.animDuration } }
                    font.family: "Rubik"; font.pixelSize: 13
                    verticalAlignment: Text.AlignVCenter; height: 32
                }
            }

            Text {
                text: config.syncDelay
                color: settingsPanel.animDuration === 0 ? Qt.rgba(1, 1, 1, 0.25) : config.textDark
                Behavior on color { ColorAnimation { duration: settingsPanel.animDuration } }
                font.family: "Rubik"; font.pixelSize: 13
            }

            Row {
                spacing: 12; width: parent.width
                opacity: settingsPanel.animDuration === 0 ? 0.3 : 1
                enabled: settingsPanel.animDuration !== 0
                SliderStyle {
                    width: parent.width - 60
                    value: settingsPanel.syncDelay
                    maxValue: 500
                    onValueChanged: if (value !== settingsPanel.syncDelay) settingsPanel.syncDelay = value
                }
                Text {
                    text: settingsPanel.syncDelay + "ms"
                    color: config.primary
                    Behavior on color { ColorAnimation { duration: settingsPanel.animDuration } }
                    font.family: "Rubik"; font.pixelSize: 13
                    verticalAlignment: Text.AlignVCenter; height: 32
                }
            }

            Text {
                text: config.backgroundBlur; color: config.textDark
                font.family: "Rubik"; font.pixelSize: 13
            }

            Row {
                spacing: 12; width: parent.width
                SliderStyle {
                    width: parent.width - 60
                    value: settingsPanel.bgBlur * 100
                    maxValue: 100
                    stepSize: 1
                    onValueChanged: if (value !== settingsPanel.bgBlur * 100) settingsPanel.bgBlur = value / 100
                }
                Text {
                    text: Math.round(settingsPanel.bgBlur * 100) + "%"
                    color: config.primary
                    Behavior on color { ColorAnimation { duration: settingsPanel.animDuration } }
                    font.family: "Rubik"; font.pixelSize: 13
                    verticalAlignment: Text.AlignVCenter; height: 32
                }
            }

            Text {
                text: config.language; color: config.textDark
                font.family: "Rubik"; font.pixelSize: 13
            }
            LanguagePicker {
                localeManager: settingsPanel.localeManager
                animDuration: settingsPanel.animDuration
                width: parent.width - 20
            }
        }
    }
}
