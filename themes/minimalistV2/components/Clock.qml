import "../singletons"
import QtQuick 2.15

Column {
    id: root

    property real centerScale: 0.90
    property bool useTwelveHourClock: false
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
        "opsz": (useTwelveHourClock ? 121.6 : 224) * centerScale
    })
    readonly property var fontAxesAmPm: ({
        "wght": 500,
        "wdth": 30,
        "ROND": 25,
        "opsz": 48 * centerScale
    })

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentTime = new Date()
    }

    Row {
        id: timeRow

        height: Math.round(224 * root.centerScale)
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            id: hourText

            height: parent.height
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
            font.family: Theme.fontFamily
            font.variableAxes: root.fontAxesHours
            font.pixelSize: Math.round(224 * root.centerScale)
            color: Theme.mSecondary
            text: Qt.formatTime(root.currentTime, "hh")
        }

        Text {
            id: separatorText

            height: parent.height
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
            font.family: Theme.fontFamily
            font.variableAxes: root.fontAxesHours
            font.pixelSize: Math.round(224 * root.centerScale)
            color: Theme.mPrimary
            text: ":"
        }

        Text {
            id: minuteText

            height: parent.height
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
            font.family: Theme.fontFamily
            font.variableAxes: root.fontAxesMinutes
            font.pixelSize: Math.round(224 * root.centerScale)
            color: Theme.mSecondary
            text: Qt.formatTime(root.currentTime, "mm")
        }

    }

    Text {
        renderType: Text.NativeRendering
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDate(root.currentTime, "dddd, d MMMM yyyy")
        font.pixelSize: Math.round(Theme.baseFontSize * 1.83)
        font.family: Theme.fontFamily
        color: Theme.mPrimary
    }

}
