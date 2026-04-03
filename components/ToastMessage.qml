import "../singletons"
import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property string message: ""
    property bool isOpen: false

    signal dismissed()

    function show(msg) {
        root.message = msg;
        root.isOpen = true;
        dismissTimer.restart();
    }

    function dismiss() {
        root.isOpen = false;
    }

    implicitWidth: toastContent.implicitWidth + 48
    implicitHeight: toastContent.implicitHeight + 24
    color: Theme.withAlpha(Theme.mError, 0.95)
    radius: Math.min(Theme.elementRadius, Math.min(root.width, root.height) / 2)
    opacity: isOpen ? 1 : 0
    scale: isOpen ? 1 : 0.6
    visible: opacity > 0

    RowLayout {
        id: toastContent

        anchors.centerIn: parent
        spacing: 12

        Text {
            renderType: Text.NativeRendering
            font.family: "Material Symbols Outlined"
            font.pixelSize: Math.round(Theme.baseFontSize * 1.55)
            text: "\ue000"
            color: Theme.mOnError
        }

        Text {
            renderType: Text.NativeRendering
            font.family: Theme.fontFamily
            font.pixelSize: Math.round(Theme.baseFontSize * 1.45)
            text: root.message
            color: Theme.mOnError
        }

    }

    Timer {
        id: dismissTimer

        interval: 3000
        onTriggered: {
            root.dismiss();
        }
    }

    Connections {
        function onIsOpenChanged() {
            if (!root.isOpen)
                root.dismissed();

        }

        target: root
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.animDurationNormal
            easing.type: isOpen ? Easing.OutCubic : Easing.InCubic
        }

    }

    Behavior on scale {
        NumberAnimation {
            duration: Theme.animDurationNormal
            easing.type: isOpen ? Easing.OutCubic : Easing.InBack
        }

    }

}
