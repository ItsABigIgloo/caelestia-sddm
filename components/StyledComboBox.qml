import "../singletons"
import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    id: root

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
        color: Theme.withAlpha(Theme.mSurface, Theme.cardOpacity)
        radius: Theme.passwordInputRadius
        border.color: Theme.mOutline
        border.width: 1
    }

    contentItem: Text {
        text: root.displayText
        font: root.font
        color: Theme.mOnSurface
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
            ctx.fillStyle = Theme.mPrimary;
            ctx.fill();
        }
    }

    delegate: ItemDelegate {
        // Fixed inset to fit inside popup borders and rounded corners
        // Note: This 16px inset is required - making it dynamic breaks item width calculation
        width: root.width - 16

        contentItem: Text {
            text: root.textRole ? model[root.textRole] : modelData
            font: root.font
            color: root.highlightedIndex === index ? Theme.mOnPrimary : Theme.mOnSurface
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            anchors.fill: parent
        }

        background: Rectangle {
            color: root.highlightedIndex === index ? Theme.mPrimary : "transparent"
            radius: Theme.passwordInputRadius
        }

    }

    popup: Popup {
        y: root.height - 1
        width: root.width
        implicitHeight: popupList.implicitHeight

        contentItem: ListView {
            id: popupList

            // add some margin so it doesn't look cramped when there are few items
            topMargin: 6
            bottomMargin: 6
            leftMargin: 2
            rightMargin: 2
            implicitHeight: Math.min(contentHeight + topMargin + bottomMargin, 250)
            model: root.delegateModel
            currentIndex: root.highlightedIndex
            clip: true

            ScrollIndicator.vertical: ScrollIndicator {
            }

        }

        background: Rectangle {
            color: Theme.withAlpha(Theme.mSurface, Theme.cardOpacity)
            border.color: Theme.mOutline
            border.width: 1
            radius: Theme.passwordInputRadius
        }

    }

}
