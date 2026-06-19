import "../singletons"
import QtQuick 2.15
import QtQuick.Controls 2.15
import "shapes"
import "shapes/material-shapes.js" as MaterialShapes

Button {
    id: root

    property string iconText: ""
    property var onClickedAction: null
    property var onRestoreFocus: null

    implicitWidth: 64
    implicitHeight: 64
    hoverEnabled: true
    focusPolicy: Qt.ClickFocus
    onClicked: {
        if (onClickedAction)
            onClickedAction();

        if (root.onRestoreFocus)
            root.onRestoreFocus();

    }

    background: ShapeCanvas {
        id: bgShape

        color: (root.hovered || root.down) ? Theme.mPrimary : Theme.withAlpha(Theme.mSurface, Theme.elementOpacity)
        roundedPolygon: (root.hovered || root.down) ? MaterialShapes.getCookie9Sided() : MaterialShapes.getCircle()

        Behavior on color {
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
        color: (root.hovered || root.down) ? Theme.mOnPrimary : Theme.mOnSurface

        Behavior on color {
            ColorAnimation {
                duration: 200
            }

        }

    }

}
