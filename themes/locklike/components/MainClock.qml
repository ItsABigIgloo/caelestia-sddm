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

    Row {
        id: clock
        anchors.centerIn: parent

        Text {
            id: hourText

            renderType: Text.NativeRendering
            font.family: googleSansFlex.name
            font.variableAxes: root.fontAxesHours
            font.pixelSize: Math.round(224 * root.centerScale)
            color: Qt.lighter(config.primary, 1.6)
            // Qt only switches "hh" to 12-hour when the format contains AP
            text: root.ap ? Qt.formatTime(root.currentTime, "hh AP").split(" ")[0] : Qt.formatTime(root.currentTime, "hh")
        }

        Item {
            width: 5
            height: 1
        }

        Text {
            id: minuteText

            renderType: Text.NativeRendering
            font.family: googleSansFlex.name
            font.variableAxes: root.fontAxesMinutes
            font.pixelSize: Math.round(224 * root.centerScale)
            color: config.secondary
            text: Qt.formatTime(root.currentTime, "mm")
        }
    }

    Text {
        id: apText

        visible: root.ap
        anchors.left: clock.right
        anchors.leftMargin: Math.round(12 * root.centerScale)
        anchors.bottom: clock.bottom
        anchors.bottomMargin: Math.round(48 * root.centerScale)

        renderType: Text.NativeRendering
        font.family: googleSansFlex.name
        font.pixelSize: Math.round(48 * root.centerScale)
        font.weight: Font.Medium
        color: config.secondary
        text: Qt.formatTime(root.currentTime, "AP")
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutBack
        }
    }
}
