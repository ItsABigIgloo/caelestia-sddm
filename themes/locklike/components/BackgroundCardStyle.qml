import QtQuick

Rectangle {
    color: Qt.rgba(
        parseInt(config.background.substring(1, 3), 16) / 255,
        parseInt(config.background.substring(3, 5), 16) / 255,
        parseInt(config.background.substring(5, 7), 16) / 255,
        parseFloat(config.mainCardColorOpacity) || 0.9
    )
}
