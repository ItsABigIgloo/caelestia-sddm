import QtQuick

Item {
    id: root

    property real value: 0
    property real maxValue: 1000
    property int stepSize: 50

    height: 32

    Rectangle {
        y: 13; width: parent.width; height: 6; radius: 3
        color: config.surfaceContainerHigh || Qt.rgba(1, 1, 1, 0.1)
        Behavior on color { ColorAnimation { duration: config.animDuration !== undefined ? config.animDuration : 300 } }

        Rectangle {
            width: (root.value / root.maxValue) * parent.width
            height: parent.height; radius: 3
            color: config.primary
            Behavior on color { ColorAnimation { duration: config.animDuration !== undefined ? config.animDuration : 300 } }
        }
    }

    Rectangle {
        x: (root.value / root.maxValue) * parent.width - 3
        y: (parent.height - 28) / 2; width: 6; height: 28; radius: 3
        color: config.primary
        Behavior on color { ColorAnimation { duration: config.animDuration !== undefined ? config.animDuration : 300 } }
    }

    MouseArea {
        anchors.fill: parent; preventStealing: true

        property real px: 0
        property real sv: 0

        onPressed: {
            px = mouse.x; sv = root.value;
            var p = mouse.x / width;
            var v = Math.round(p * root.maxValue / root.stepSize) * root.stepSize;
            v = Math.min(root.maxValue, Math.max(0, v));
            root.value = v;
        }

        onPositionChanged: if (pressed) {
            var d = (mouse.x - px) / width * root.maxValue;
            var v = Math.round((sv + d) / root.stepSize) * root.stepSize;
            v = Math.min(root.maxValue, Math.max(0, v));
            root.value = v;
        }
    }
}
