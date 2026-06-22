import "../widgets"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root

    property bool firstInput: false
    property real mainCardComponentsOpacity: 1
    property int animDuration: 300
    property real smallRadius: 35
    property real mainCardRadius: 70
    property string locale: "en"

    spacing: 13
    Layout.alignment: Qt.AlignRight

    Rectangle {
        width: 390
        height: 355
        color: config.subComponents
        radius: root.smallRadius
        opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity

        RandomQuote {
            maxWidth: parent.width - 40
            color: config.text
            locale: root.locale
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
        width: 390
        height: 355
        color: config.subComponents
        bottomRightRadius: root.mainCardRadius / 1.9
        radius: root.mainCardRadius / 4
        opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity

        Image {
            id: dino

            width: 300
            height: 150
            source: "../assets/dino.png"
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectCrop
            layer.enabled: true

            layer.effect: ColorOverlay {
                color: config.inverseOnSurface

                Behavior on color {
                    ColorAnimation {
                        duration: root.animDuration
                    }

                }

            }

        }

        Text {
            renderType: Text.NativeRendering
            text: config.unlockForNotifications
            color: config.inverseOnSurface
            font.family: "CaskaydiaCove NF"
            font.pointSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50

            Behavior on color {
                ColorAnimation {
                    duration: root.animDuration
                }

            }

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

}
