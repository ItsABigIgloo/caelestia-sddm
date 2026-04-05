import "../singletons"
import Qt5Compat.GraphicalEffects
import QtQuick 2.15

Text {
    id: root

    property string userName: ""
    property bool isActive: true

    renderType: Text.NativeRendering
    anchors.centerIn: parent
    text: userName ? "Welcome, " + userName : "Welcome"
    font.family: Theme.fontFamily
    font.pixelSize: Math.round(Theme.baseFontSize * 8)
    font.weight: Font.DemiBold
    color: Theme.mOnSurface
    opacity: isActive ? 1 : 0
    scale: isActive ? 1 : 0.8
    layer.enabled: true

    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 0
        verticalOffset: 6
        radius: 24
        samples: 40
        color: Theme.withAlpha(Theme.mShadow, 0.65)
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.animDurationNormal
            easing.type: Easing.OutCubic
        }

    }

    Behavior on scale {
        NumberAnimation {
            duration: Theme.animDurationNormal
            easing.type: Easing.OutCubic
        }

    }

}
