import QtQuick

Item {
    id: root

    property var model: []
    property int currentIndex: 0
    property string iconChar: "language"
    property string displayText: ""
    property int animDuration: 200
    signal activated(int index)

    readonly property int _ddW: 260
    readonly property int _ddH: 40
    readonly property int _iconS: 16
    readonly property int _iconL: 18
    readonly property int _radius: 8
    readonly property int _labelW: 210
    readonly property int _itemH: 32
    readonly property int _menuMax: 160
    readonly property int _gap: 10
    readonly property int _marg: 4
    readonly property int _fontS: parseInt(config.dropdownItemSize) || 13
    readonly property int _fontM: parseInt(config.dropdownLabelSize) || 14
    readonly property int _radiusS: 5
    readonly property int _rowPad: 15
    readonly property int _rowSpacing: 6
    readonly property int _offset: -2
    readonly property int _itemPad: 4

    width: _ddW; height: _ddH

    property bool _open: false

    Rectangle {
        id: labelRect

        radius: height / 2
        anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
        topLeftRadius: height / 2; bottomLeftRadius: height / 2
        topRightRadius: _radiusS; bottomRightRadius: _radiusS
        color: config.subComponents
        Behavior on color { ColorAnimation { duration: root.animDuration } }

        width: _labelW

        Row {
            anchors.verticalCenter: labelRect.verticalCenter
            anchors.left: labelRect.left; anchors.leftMargin: _rowPad; spacing: _rowSpacing

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: "Material Symbols Rounded"; font.pointSize: _iconS
                text: root.iconChar; color: config.primary
                Behavior on color { ColorAnimation { duration: root.animDuration } }
            }

            Text {
                id: labelText

                anchors.verticalCenter: parent.verticalCenter
                text: root.displayText || (root.model[root.currentIndex] || "")
                color: config.text; font.pixelSize: root.model.length > 0 ? _fontM : _fontS
                Behavior on color { ColorAnimation { duration: root.animDuration } }
                font.family: "Rubik"
                elide: Text.ElideRight
            }
        }
    }

    Rectangle {
        id: expandBtn

        property real rad: root._open ? height / 2 : _radiusS

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
            anchors.horizontalCenterOffset: root._open ? 0 : _offset
            font.family: "Material Symbols Rounded"; font.pointSize: _iconL
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
        radius: _radius
        border.color: config.outline; border.width: 1
        Behavior on border.color { ColorAnimation { duration: root.animDuration } }

        anchors.top: labelRect.bottom; anchors.topMargin: _marg
        anchors.left: labelRect.left; anchors.leftMargin: -_gap
        width: _ddW; height: Math.min(_menuMax, root.model.length * (_itemH + _marg))

        clip: true; z: 999

        opacity: root._open ? 1 : 0
        transform: Translate { y: root._open ? 0 : -_gap }

        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.InOutCubic }
        }

        ListView {
            id: listView

            anchors.fill: parent; anchors.margins: _marg
            model: root.model
            currentIndex: root.currentIndex
            onModelChanged: currentIndex = Qt.binding(function() { return root.currentIndex; })
            clip: true; boundsBehavior: ListView.StopAtBounds

            delegate: Rectangle {
                width: parent.width; height: _itemH; radius: _marg
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
                    font.pixelSize: _fontS; font.family: "Rubik"
                    elide: Text.ElideRight
                    leftPadding: _itemPad; rightPadding: _itemPad
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
