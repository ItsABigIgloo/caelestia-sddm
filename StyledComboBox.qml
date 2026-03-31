import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    id: root

    property color backgroundColor: withAlpha(mSurface, cardOpacity)
    property color borderColor: mOutline
    property color textColor: mOnSurface
    property color highlightColor: mPrimary
    property color highlightTextColor: mOnPrimary
    property real itemRadius: passwordInputRadius
    property var onRestoreFocus: function() {
    }

    focusPolicy: Qt.ClickFocus
    onActivated: onRestoreFocus()
    Keys.onPressed: function(event) {
        if (!popup.visible) {
            if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                event.accepted = true;
                onRestoreFocus();
            }
        }
    }

    background: Rectangle {
        color: root.backgroundColor
        radius: root.itemRadius
        border.color: root.borderColor
        border.width: 1
    }

    contentItem: Text {
        text: root.displayText
        font: root.font
        color: root.textColor
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Qt.AlignHCenter
        leftPadding: 0
        rightPadding: 0
        anchors.fill: parent
    }

    indicator: Canvas {
        x: root.width - 30
        y: (root.height - 6) / 2
        width: 12
        height: 6
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.moveTo(0, 0);
            ctx.lineTo(width, 0);
            ctx.lineTo(width / 2, height);
            ctx.closePath();
            ctx.fillStyle = mPrimary;
            ctx.fill();
        }
    }

    delegate: ItemDelegate {
        // Fixed inset to fit inside popup borders and rounded corners
        width: root.width - 16

        contentItem: Text {
            text: model[root.textRole]
            font: root.font
            color: root.highlightedIndex === index ? root.highlightTextColor : root.textColor
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            anchors.fill: parent
        }

        background: Rectangle {
            color: root.highlightedIndex === index ? root.highlightColor : "transparent"
            radius: root.itemRadius
        }

    }

    popup: Popup {
        y: root.height - 1
        width: root.width
        implicitHeight: contentItem.implicitHeight

        contentItem: ListView {
            implicitHeight: Math.min(contentHeight, 250)
            // add some margin so it doesn't look cramped
            leftMargin: 2
            rightMargin: 2
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator {
            }

        }

        background: Rectangle {
            color: root.backgroundColor
            border.color: root.borderColor
            border.width: 1
            radius: root.itemRadius
        }

    }

}
