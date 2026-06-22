import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

Item {
    id: root

    property int actionType: 0
    property int animDuration: 300
    property real overlayOpacity: 0.8
    property real powerBlur: 1
    property bool powerConfirmEnabled: true
    property int _focusIndex: 0
    property int _hoveredIndex: -1
    property real _dialogOpacity: 0

    signal confirmed(string cmd)

    function show(act) {
        root.actionType = act;
        root._focusIndex = 1;
        root._dialogOpacity = 0;
        root.visible = true;
        root.forceActiveFocus();
        showAnim.restart();
    }

    function hide() {
        hideAnim.restart();
        hideTimer.restart();
    }

    visible: false
    anchors.fill: parent
    focus: visible
    Keys.onPressed: {
        if (event.key === Qt.Key_Escape && root.visible) {
            root.hide();
            event.accepted = true;
            return ;
        }
        if (event.key === Qt.Key_Tab || event.key === Qt.Key_Right) {
            if (root._hoveredIndex < 0)
                root._focusIndex = (root._focusIndex + 1) % 2;

            event.accepted = true;
            return ;
        }
        if (event.key === Qt.Key_Left) {
            if (root._hoveredIndex < 0)
                root._focusIndex = (root._focusIndex - 1 + 2) % 2;

            event.accepted = true;
            return ;
        }
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            if (root._focusIndex === 0)
                root.hide();
            else
                root.confirmed(root.actionType === 0 ? "poweroff" : "reboot");
            event.accepted = true;
            return ;
        }
    }

    Timer {
        id: hideTimer

        interval: root.animDuration
        onTriggered: root.visible = false
    }

    SequentialAnimation {
        id: showAnim

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "_dialogOpacity"
                from: 0
                to: 1
                duration: root.animDuration
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: bgOverlay
                property: "opacity"
                from: 0
                to: root.overlayOpacity
                duration: root.animDuration
                easing.type: Easing.OutCubic
            }

        }

    }

    SequentialAnimation {
        id: hideAnim

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "_dialogOpacity"
                to: 0
                duration: root.animDuration
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: bgOverlay
                property: "opacity"
                to: 0
                duration: root.animDuration
                easing.type: Easing.OutCubic
            }

        }

    }

    Rectangle {
        id: bgOverlay

        anchors.fill: parent
        color: "#000000"
        opacity: 0
        layer.enabled: true

        MouseArea {
            anchors.fill: parent
            onClicked: root.hide()
        }

        layer.effect: MultiEffect {
            blurEnabled: true
            blur: root.powerBlur
            blurMax: 32
        }

    }

    BackgroundCardStyle {
        anchors.centerIn: parent
        width: 400
        height: 220
        radius: 24
        opacity: root._dialogOpacity
        z: 1

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 24
            width: parent.width - 60

            Text {
                text: config.confirmTitle
                color: config.text
                font.family: "Rubik"
                font.pixelSize: 20
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true

                Behavior on color {
                    ColorAnimation {
                        duration: root.animDuration
                    }

                }

            }

            Text {
                text: actionType === 0 ? config.confirmShutdown : config.confirmReboot
                color: config.textDark
                font.family: "Rubik"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true

                Behavior on color {
                    ColorAnimation {
                        duration: root.animDuration
                    }

                }

            }

            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                TextButtonStyle {
                    isFocused: root._focusIndex === 0
                    noHoverActive: root._hoveredIndex < 0
                    text: config.cancel
                    onEntered: {
                        root._hoveredIndex = 0;
                        root._focusIndex = 0;
                    }
                    onExited: {
                        if (root._hoveredIndex === 0)
                            root._hoveredIndex = -1;

                    }
                    onClicked: root.hide()
                }

                TextButtonStyle {
                    isFocused: root._focusIndex === 1
                    noHoverActive: root._hoveredIndex < 0
                    text: actionType === 0 ? config.shutdown : config.reboot
                    onEntered: {
                        root._hoveredIndex = 1;
                        root._focusIndex = 1;
                    }
                    onExited: {
                        if (root._hoveredIndex === 1)
                            root._hoveredIndex = -1;

                    }
                    onClicked: root.confirmed(root.actionType === 0 ? "poweroff" : "reboot")
                }

            }

        }

        Behavior on color {
            ColorAnimation {
                duration: root.animDuration
            }

        }

    }

}
