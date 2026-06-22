import QtQuick

Item {
    id: root

    property var model: []
    property int currentIndex: 0
    property string iconChar: "language"
    property string displayText: ""
    property int animDuration: 200
    signal activated(int index)

    width: 260; height: 40

    property bool _open: false

    Rectangle {
        id: labelRect

        radius: height / 2
        anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
        topLeftRadius: height / 2; bottomLeftRadius: height / 2
        topRightRadius: 5; bottomRightRadius: 5
        color: config.subComponents
        Behavior on color { ColorAnimation { duration: root.animDuration } }

        width: 210

        Row {
            anchors.verticalCenter: labelRect.verticalCenter
            anchors.left: labelRect.left; anchors.leftMargin: 15; spacing: 6

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: "Material Symbols Rounded"; font.pointSize: 16
                text: root.iconChar; color: config.primary
                Behavior on color { ColorAnimation { duration: root.animDuration } }
            }

            Text {
                id: labelText

                anchors.verticalCenter: parent.verticalCenter
                text: root.displayText || (root.model[root.currentIndex] || "")
                color: config.text; font.pixelSize: root.model.length > 0 ? 14 : 13
                Behavior on color { ColorAnimation { duration: root.animDuration } }
                font.family: "Rubik"
                elide: Text.ElideRight
            }
        }
    }

    Rectangle {
        id: expandBtn

        property real rad: root._open ? height / 2 : 5

        radius: height / 2
        anchors.left: labelRect.right; anchors.top: parent.top; anchors.bottom: parent.bottom
        topLeftRadius: rad; bottomLeftRadius: rad
        color: config.primary
        Behavior on color { ColorAnimation { duration: root.animDuration } }

        width: height

        Behavior on topLeftRadius {
            NumberAnimation { duration: 200; easing.type: Easing.InOutCubic }
        }

        Behavior on bottomLeftRadius {
            NumberAnimation { duration: 200; easing.type: Easing.InOutCubic }
        }

        Text {
            anchors.centerIn: expandBtn
            anchors.horizontalCenterOffset: root._open ? 0 : -2
            font.family: "Material Symbols Rounded"; font.pointSize: 18
            text: "expand_more"; color: config.onPrimary
            Behavior on color { ColorAnimation { duration: root.animDuration } }
            rotation: root._open ? 180 : 0

            Behavior on anchors.horizontalCenterOffset {
                NumberAnimation { duration: 200; easing.type: Easing.InOutCubic }
            }

            Behavior on rotation {
                NumberAnimation { duration: 200; easing.type: Easing.InOutCubic }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root._open = !root._open
        }
    }

    Rectangle {
        id: menuRect

        visible: root._open
        color: config.subComponents
        Behavior on color { ColorAnimation { duration: root.animDuration } }
        radius: 8
        border.color: config.outline; border.width: 1
        Behavior on border.color { ColorAnimation { duration: root.animDuration } }

        anchors.top: labelRect.bottom; anchors.topMargin: 4
        anchors.left: labelRect.left; anchors.leftMargin: -10
        width: 260; height: Math.min(160, root.model.length * 36)

        clip: true; z: 999

        opacity: root._open ? 1 : 0
        transform: Translate { y: root._open ? 0 : -10 }

        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.InOutCubic }
        }

        ListView {
            id: listView

            anchors.fill: parent; anchors.margins: 4
            model: root.model
            currentIndex: root.currentIndex
            clip: true; boundsBehavior: ListView.StopAtBounds

            delegate: Rectangle {
                width: parent.width; height: 32; radius: 4
                color: index === listView.currentIndex ? config.primary : "transparent"
                opacity: index === listView.currentIndex ? 0.2 : 1

                Behavior on color { ColorAnimation { duration: root.animDuration } }

                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.currentIndex = index;
                        root._open = false;
                        root.activated(index);
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.model[index]
                    color: config.text
                    Behavior on color { ColorAnimation { duration: root.animDuration } }
                    font.pixelSize: 13; font.family: "Rubik"
                    elide: Text.ElideRight
                    leftPadding: 4; rightPadding: 4
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent; z: -1
        enabled: root._open
        onClicked: root._open = false
    }
}
