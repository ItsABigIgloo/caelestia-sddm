import Qt5Compat.GraphicalEffects
import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: root

    property string iconText: ""
    property color normalColor: mOnSurface
    property color hoverColor: mPrimary
    property var onClickedAction: null

    implicitWidth: 64
    implicitHeight: 64
    hoverEnabled: true
    focusPolicy: Qt.ClickFocus
    onClicked: {
        if (onClickedAction)
            onClickedAction();

        restoreFocus();
    }
    states: [
        State {
            name: "hovered"
            when: root.hovered || root.down

            PropertyChanges {
                target: bgRect
                color: Qt.rgba(mSurface.r, mSurface.g, mSurface.b, 0.4)
                border.color: Qt.rgba(root.hoverColor.r, root.hoverColor.g, root.hoverColor.b, 0.7)
            }

        }
    ]

    background: Rectangle {
        id: bgRect

        width: Math.min(root.width, root.height)
        height: width
        anchors.centerIn: parent
        radius: width / 2
        color: Qt.rgba(mSurface.r, mSurface.g, mSurface.b, 0.2)
        border.color: Qt.rgba(mOutline.r, mOutline.g, mOutline.b, 0.4)
        border.width: 1

        Behavior on color {
            ColorAnimation {
                duration: 200
            }

        }

        Behavior on border.color {
            ColorAnimation {
                duration: 200
            }

        }

    }

    contentItem: Text {
        text: root.iconText
        font.family: "Material Symbols Outlined"
        font.pixelSize: 28
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: (root.hovered || root.down) ? root.hoverColor : root.normalColor
        layer.enabled: true

        Behavior on color {
            ColorAnimation {
                duration: 200
            }

        }

        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 2
            radius: 8
            samples: 16
            color: Qt.rgba(mShadow.r, mShadow.g, mShadow.b, 0.3)
        }

    }

}
