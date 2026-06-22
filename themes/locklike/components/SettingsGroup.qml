import QtQuick

Column {
    id: root

    property string groupTitle: ""
    property bool groupVisible: true
    property int fontSize: parseInt(config.settingsFontSize) || 18
    property int animDuration: parseInt(config.animDuration) || 300
    default property alias content: contentItem.children

    visible: groupVisible
    width: parent.width
    spacing: 8

    Text {
        text: root.groupTitle
        color: config.textDark
        font.family: "Rubik"; font.pixelSize: root.fontSize; font.bold: true
    }

    Rectangle {
        width: parent.width; height: 1
        color: config.outline; opacity: 0.25
    }

    Column {
        id: contentItem
        width: parent.width
        spacing: 8
    }
}