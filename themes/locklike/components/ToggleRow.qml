import QtQuick

Item {
    property string labelText: ""
    property bool toggleChecked: false
    property bool showWhen: true
    property int fontSize: parseInt(config.settingsFontSize) || 18

    signal toggled(bool value)

    visible: showWhen
    width: parent.width; height: Math.max(32, fontSize + 10)

    Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: labelText
        color: config.textDark; font.family: "Rubik"; font.pixelSize: fontSize
    }
    ToggleStyle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        checked: toggleChecked
        onToggled: parent.toggled(value)
    }
}
