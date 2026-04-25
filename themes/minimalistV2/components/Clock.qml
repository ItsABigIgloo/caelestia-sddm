import "../singletons"
import QtQuick 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root

    spacing: 10

    Text {
        id: clock

        renderType: Text.NativeRendering
        Layout.alignment: Qt.AlignHCenter
        textFormat: Text.RichText
        text: {
            var time = Qt.formatTime(new Date(), "hh:mm")
            return time.replace(":", "<span style='color:" + Theme.mPrimary + "'>:</span>")
        }
        font.pixelSize: Math.round(Theme.baseFontSize * 7.6)
        font.family: Theme.fontFamily
        font.bold: true
        color: Theme.mSecondary
    }

    Text {
        renderType: Text.NativeRendering
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatDate(new Date(), "dddd, d MMMM yyyy")
        font.pixelSize: Math.round(Theme.baseFontSize * 1.83)
        font.family: Theme.fontFamily
        color: Theme.mPrimary
    }

}
