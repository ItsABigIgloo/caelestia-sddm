import QtQuick

Item {
    id: root

    property bool firstInput
    property real mainCardComponentsOpacity
    property bool ap

    property real centerScale: 1
    property date currentTime: new Date()

    readonly property int hourPx: Math.round(224 * centerScale)
    readonly property int minutePx: Math.round((ap ? 121.6 : 224) * centerScale)
    readonly property int apPx: Math.round(48 * centerScale)

    readonly property var fontAxes: ({
            "wght": 500,
            "wdth": 30,
            "ROND": 25,
            "opsz": 224 * centerScale
        })

    function calcTopOff(metrics: TextMetrics): real {
        return metrics.tightBoundingRect.y - metrics.boundingRect.y;
    }

    Item {
        id: clockBox

        anchors.centerIn: parent

        implicitWidth: hourText.implicitWidth + spacer.width + minuteText.implicitWidth
        implicitHeight: hourMetrics.tightBoundingRect.height

        FontLoader {
            id: googleSansFlex

            source: "../assets/google-sans-flex/GoogleSansFlex.ttf"
        }

        Text {
            id: hourText

            y: -root.calcTopOff(hourMetrics)

            renderType: Text.NativeRendering
            font.family: googleSansFlex.name
            font.variableAxes: root.fontAxes
            font.pixelSize: root.hourPx
            color: Qt.lighter(config.primary, 1.6)
            text: root.ap ? Qt.formatTime(root.currentTime, "hh AP").split(" ")[0] : Qt.formatTime(root.currentTime, "hh")

            TextMetrics {
                id: hourMetrics

                text: hourText.text
                font: hourText.font
            }
        }

        Item {
            id: spacer

            width: 8
            height: 1
        }

        Text {
            id: minuteText

            x: hourText.implicitWidth + spacer.width
            y: -root.calcTopOff(minuteMetrics)

            renderType: Text.NativeRendering
            font.family: googleSansFlex.name
            font.variableAxes: root.fontAxes
            font.pixelSize: root.minutePx
            color: config.secondary
            text: Qt.formatTime(root.currentTime, "mm")

            TextMetrics {
                id: minuteMetrics

                text: minuteText.text
                font: minuteText.font
            }
        }

        Rectangle {
            visible: root.ap
            anchors.left: minuteText.left
            anchors.leftMargin: minuteMetrics.tightBoundingRect.x
            y: clockBox.implicitHeight - height

            radius: Math.round(16 * root.centerScale)
            color: config.subComponents
            implicitWidth: minuteMetrics.tightBoundingRect.width
            implicitHeight: apMetrics.tightBoundingRect.height + Math.round(32 * root.centerScale)

            Text {
                id: apText

                anchors.centerIn: parent
                width: apMetrics.tightBoundingRect.width
                height: apMetrics.tightBoundingRect.height
                transform: Translate {
                    x: -apMetrics.tightBoundingRect.x
                    y: -root.calcTopOff(apMetrics)
                }

                renderType: Text.NativeRendering
                font.family: googleSansFlex.name
                font.variableAxes: root.fontAxes
                font.pixelSize: root.apPx
                color: config.text
                text: Qt.formatTime(root.currentTime, "AP")

                TextMetrics {
                    id: apMetrics

                    text: apText.text
                    font: apText.font
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentTime = new Date()
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutBack
        }
    }
}
