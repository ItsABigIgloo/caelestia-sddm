import QtQuick

Item {
    id: root

    property bool firstInput
    property real mainCardComponentsOpacity
    property bool ap

    property real centerScale: 1
    property date currentTime: new Date()

    readonly property var fontAxesHours: ({
            "wght": 500,
            "wdth": 30,
            "ROND": 25,
            "opsz": 224 * centerScale
        })
    readonly property var fontAxesMinutes: ({
            "wght": 500,
            "wdth": 30,
            "ROND": 25,
            "opsz": 224 * centerScale
        })

    FontLoader {
        id: googleSansFlex

        source: "../assets/google-sans-flex/GoogleSansFlex.ttf"
    }

    Item {
        id: clock
        anchors.centerIn: parent
        opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity
        implicitWidth: ampmText.visible
            ? hourText.implicitWidth + 5 + minuteText.implicitWidth + 8 + ampmText.implicitWidth
            : hourText.implicitWidth + 5 + minuteText.implicitWidth
        implicitHeight: Math.max(hourText.implicitHeight, minuteText.implicitHeight)

        Text {
            id: hourText
            x: 0
            y: 0

            renderType: Text.NativeRendering
            font.family: googleSansFlex.name
            font.variableAxes: root.fontAxesHours
            font.pixelSize: Math.round(224 * root.centerScale)
            color: Qt.lighter(config.primary, 1.6)
            Behavior on color { ColorAnimation { duration: config.animDuration !== undefined ? config.animDuration : 300 } }
            text: {
                var d = root.currentTime;
                if (root.ap) {
                    var h = d.getHours() % 12;
                    if (h === 0) h = 12;
                    return h.toString();
                }
                return d.getHours().toString().padStart(2, '0');
            }
        }

        Item {
            x: hourText.x + hourText.width + 2
            y: 0
            width: 3
            height: 1
        }

        Text {
            id: minuteText
            x: hourText.x + hourText.width + 2 + 3

            renderType: Text.NativeRendering
            font.family: googleSansFlex.name
            font.variableAxes: root.fontAxesMinutes
            font.pixelSize: Math.round(224 * root.centerScale)
            color: config.secondary
            Behavior on color { ColorAnimation { duration: config.animDuration !== undefined ? config.animDuration : 300 } }
            text: root.currentTime.getMinutes().toString().padStart(2, '0')
        }

        Text {
            id: ampmText
            x: minuteText.x + minuteText.width + 8
            y: minuteText.baselineOffset - baselineOffset
            visible: root.ap

            renderType: Text.NativeRendering
            font.family: googleSansFlex.name
            font.pixelSize: Math.round(60 * root.centerScale)
            color: config.secondary
            text: root.currentTime.getHours() >= 12 ? "PM" : "AM"
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutBack
        }
    }
}
