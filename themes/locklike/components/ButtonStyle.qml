import QtQuick

Item {
    id: root

    property bool isFocused: false
    property bool noHoverActive: true
    property int animDuration: 120
    property bool _hovered: false

    signal clicked()
    signal entered()
    signal exited()

    Keys.onPressed: {
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return || event.key === Qt.Key_Space) {
            root.clicked();
            event.accepted = true;
            return ;
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            root._hovered = true;
            root.entered();
        }
        onExited: {
            root._hovered = false;
            root.exited();
        }
        onClicked: root.clicked()
    }

}
