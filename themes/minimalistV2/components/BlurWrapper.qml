import "../singletons"
import Qt5Compat.GraphicalEffects
import QtQuick 2.15
import QtQuick.Effects

Item {
    id: blurCard

    property real targetWidth: 200
    property real targetHeight: 200

    property real startWidth: targetWidth / 10
    property real startHeight: targetHeight / 10

    property int animDuration: 600

    property real radius: 20

    property bool blurEnabled: true
    property real blurAmount: 0.6

    property bool visibleState: true
    property url source: Qt.resolvedUrl("../assets/background")

        Rectangle {
            id: rootRect
            width: blurCard.startWidth
            height: blurCard.startHeight
            radius: blurCard.radius
            color: "transparent"
            opacity: blurCard.visibleState ? 1 : 0

            anchors.centerIn: parent
            clip: true

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: rootRect.width
                    height: rootRect.height
                    radius: rootRect.radius
                }
            }

            Image {
            id: backgroundBlur
            anchors.centerIn: parent
            width: 1920
            height: 1080
            source: blurCard.source
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            smooth: true
            mipmap: true

            onStatusChanged: {
                if (status === Image.Error) {
                    console.log("BlurWrapper: Background missing, using fallback color");
                }
            }
        }

        MultiEffect {
            anchors.fill: backgroundBlur
            source: backgroundBlur

            blurEnabled: blurCard.blurEnabled
            blur: blurCard.blurAmount
            blurMax: 64
            blurMultiplier: 1
            autoPaddingEnabled: false

            opacity: blurCard.visibleState ? 1 : 0
        }
    }

    PropertyAnimation {
        id: widthAnim
        target: rootRect
        property: "width"
        from: blurCard.startWidth
        to: blurCard.targetWidth
        duration: blurCard.animDuration
        easing.type: Easing.OutBack
    }

    PropertyAnimation {
        id: heightAnim
        target: rootRect
        property: "height"
        from: blurCard.startHeight
        to: blurCard.targetHeight
        duration: blurCard.animDuration
        easing.type: Easing.OutBack
    }

    function startAnimation() {
        widthAnim.start();
        heightAnim.start();
    }

    Component.onCompleted: startAnimation()
}
