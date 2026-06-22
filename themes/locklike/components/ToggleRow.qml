import QtQuick

Item {
    property string labelText: ""
    property bool toggleChecked: false
    property bool showWhen: true
    readonly property int _rowH: 24
    readonly property int _fontS: 13

    signal toggled(bool value)

    visible: showWhen
    width: parent.width
    height: _rowH

    Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: labelText
        color: config.textDark
        font.family: "Rubik"
        font.pixelSize: _fontS
    }

    ToggleStyle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        checked: toggleChecked
        onToggled: parent.toggled(value)
    }

}
