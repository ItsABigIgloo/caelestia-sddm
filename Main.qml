import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: mSurface

    function toNumber(value, fallbackValue) {
        var num = Number(value);
        return isFinite(num) ? num : fallbackValue;
    }

    function boundedNumber(value, fallbackValue, minValue, maxValue) {
        var num = toNumber(value, fallbackValue);

        if (num < minValue) {
            return minValue;
        }

        if (num > maxValue) {
            return maxValue;
        }

        return num;
    }

    function toBool(value, fallbackValue) {
        if (value === undefined || value === null || value === "") {
            return fallbackValue;
        }

        var normalized = String(value).toLowerCase();
        return normalized === "true" || normalized === "1" || normalized === "yes" || normalized === "on";
    }

    property string backgroundSource: {
        var source = config.background ? config.background.toString().trim() : "";
        if (!source || source === "") {
            return "assets/background.png"; // Absolute fallback
        }
        return source;
    }
    property string fontFamily: {
        var availableFonts = Qt.fontFamilies();

        function firstAvailable(candidates) {
            for (var i = 0; i < candidates.length; i++) {
                if (availableFonts.indexOf(candidates[i]) !== -1) {
                    return candidates[i];
                }
            }
            return "sans-serif";
        }

        var family = config.fontFamily;
        if (!family || family === "") {
            family = config.Font;
        }

        if (family && family !== "") {
            family = family.toString().replace(/^"|"$/g, "");
            if (availableFonts.indexOf(family) !== -1) {
                return family;
            }
        }

        return firstAvailable(["Rubik", "Sans"]);
    }
    property real baseFontSize: boundedNumber(config.FontSize, 12, 10, 24)
    property real avatarBaseSize: boundedNumber(config.AvatarSize, 128, 64, 320)
    property real avatarFrameSize: Math.max(96, Math.round(avatarBaseSize * 1.72))
    property real avatarInset: Math.max(8, Math.round(avatarFrameSize * 0.09))
    property bool dropShadows: toBool(config.dropShadows, false)
    property real blurRadius: boundedNumber(config.blurRadius, 0, 0, 64)
    property real cardOpacity: boundedNumber(config.cardOpacity, 0.95, 0.0, 1.0)
    property real buttonRadius: boundedNumber(config.buttonRadius, 20, 0, 64)
    property real passwordInputRadius: boundedNumber(config.passwordInputRadius, 20, 0, 64)
    property real cardRadius: boundedNumber(config.cardRadius, 30, 0, 80)

    property color mPrimary: config.mPrimary ? config.mPrimary : (config.accent ? config.accent : "#4cdadb")
    property color mOnPrimary: config.mOnPrimary ? config.mOnPrimary : "#002022"
    property color mSecondary: config.mSecondary ? config.mSecondary : "#95f4f5"
    property color mOnSecondary: config.mOnSecondary ? config.mOnSecondary : "#003738"
    property color mTertiary: config.mTertiary ? config.mTertiary : "#86d0ff"
    property color mOnTertiary: config.mOnTertiary ? config.mOnTertiary : "#00344d"
    property color mError: config.mError ? config.mError : (config.error ? config.error : "#ffb4ab")
    property color mOnError: config.mOnError ? config.mOnError : "#690005"
    property color mSurface: config.mSurface ? config.mSurface : (config.surface ? config.surface : "#131313")
    property color mOnSurface: config.mOnSurface ? config.mOnSurface : (config.text ? config.text : "#e2e2e2")
    property color mSurfaceVariant: config.mSurfaceVariant ? config.mSurfaceVariant : (config.surfaceVariant ? config.surfaceVariant : "#353535")
    property color mOnSurfaceVariant: config.mOnSurfaceVariant ? config.mOnSurfaceVariant : (config.subtext ? config.subtext : "#919191")
    property color mOutline: config.mOutline ? config.mOutline : "#7d7d7d"
    property color mShadow: config.mShadow ? config.mShadow : "#000000"
    property color mHover: config.mHover ? config.mHover : mPrimary
    property color mOnHover: config.mOnHover ? config.mOnHover : mOnPrimary

    property real overlayOpacity: 0.4
    property real cardShadowOpacity: 0.55

    function withAlpha(baseColor, alphaValue) {
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, alphaValue);
    }

    Item {
        id: backgroundContainer
        anchors.fill: parent

        property string src: backgroundSource
        property bool isVideo: src.endsWith(".mp4") || src.endsWith(".webm")
        property bool isGif: src.endsWith(".gif")

        // Static Image (Fallback & Standard)
        Image {
            anchors.fill: parent
            source: backgroundContainer.src
            fillMode: Image.PreserveAspectCrop
            visible: !backgroundContainer.isVideo && !backgroundContainer.isGif
            asynchronous: true
        }
        
    }

    Rectangle {
        anchors.fill: parent
        color: mShadow
        opacity: overlayOpacity
    }

    Item {
        id: cardContainer
        width: 550
        height: 800
        anchors.centerIn: parent

        Rectangle {
            anchors.fill: mainCard
            anchors.leftMargin: 0
            anchors.topMargin: 10
            radius: cardRadius
            color: withAlpha(mShadow, cardShadowOpacity)
            visible: dropShadows
        }

        Rectangle {
            id: mainCard
            anchors.fill: parent
            radius: cardRadius
            border.color: withAlpha(mPrimary, cardOpacity)
            border.width: 1
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                radius: cardRadius
                opacity: cardOpacity
                gradient: Gradient {
                    GradientStop {
                        position: 0.5
                        color: withAlpha(mSurface, 0.92)
                    }
                    GradientStop {
                        position: 1.0
                        color: withAlpha(mPrimary, 0.36)
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 40
                spacing: 30

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10
                    Text {
                        id: clock
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatTime(new Date(), "hh:mm AP")
                        style: Text.Outline
                        styleColor: mShadow
                        font.pixelSize: Math.round(baseFontSize * 7)
                        font.family: fontFamily
                        color: mOnSurface
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDate(new Date(), "dddd, d MMMM yyyy")
                        style: Text.Outline
                        styleColor: mShadow
                        font.pixelSize: Math.round(baseFontSize * 1.83)
                        font.family: fontFamily
                        color: mOnSurfaceVariant
                    }
                }

                Rectangle {
                    id: avatarFrame
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: avatarFrameSize
                    Layout.preferredHeight: avatarFrameSize
                    radius: avatarFrameSize / 2
                    color: withAlpha(mSurface, cardOpacity)
                    border.color: mPrimary
                    border.width: 2
                    clip: true

                    Image {
                        id: avatarImage
                        anchors.fill: parent
                        anchors.margins: avatarInset
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true

                        source: {
                            if (userPicker.currentIndex !== -1) {
                                var userName = userModel.data(userModel.index(userPicker.currentIndex, 0), Qt.UserRole + 1);

                                var faceIcon = "file:///home/" + userName + "/.face.icon";
                                var faceFile = "file:///home/" + userName + "/.face";

                                var modelIcon = userModel.data(userModel.index(userPicker.currentIndex, 0), Qt.UserRole + 2);

                                if (modelIcon && modelIcon !== "") {
                                    return "file://" + modelIcon;
                                } else {
                                    return faceIcon;
                                }
                            }
                            return "assets/logo.png";
                        }

                        onStatusChanged: {
                            if (status === Image.Error && source.toString().includes(".face.icon")) {
                                var userName = userModel.data(userModel.index(userPicker.currentIndex, 0), Qt.UserRole + 1);
                                source = "file:///home/" + userName + "/.face";
                            } else if (status === Image.Error) {
                                source = "assets/logo.png";
                            }
                        }
                    }
                }

                ComboBox {
                    id: userPicker
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 380
                    Layout.preferredHeight: 55
                    model: userModel
                    currentIndex: userModel.lastIndex
                    textRole: "name"
                    font.family: fontFamily
                    font.pixelSize: Math.round(baseFontSize * 1.67)

                    background: Rectangle {
                        color: withAlpha(mSurface, cardOpacity)
                        radius: passwordInputRadius
                        border.color: mOutline
                        border.width: 1
                    }

                    contentItem: Text {
                        text: userPicker.displayText
                        font: userPicker.font
                        color: mOnSurface
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        leftPadding: 0
                        rightPadding: 0
                        topPadding: 0
                        bottomPadding: 0

                        anchors.fill: parent
                    }

                    indicator: Canvas {
                        x: userPicker.width - 30
                        y: (userPicker.height - 6) / 2
                        width: 12
                        height: 6
                        onPaint: {
                            var context = getContext("2d");
                            context.reset();
                            context.moveTo(0, 0);
                            context.lineTo(width, 0);
                            context.lineTo(width / 2, height);
                            context.closePath();
                            context.fillStyle = mPrimary;
                            context.fill();
                        }
                    }
                }

                TextField {
                    id: passwordField
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 380
                    Layout.preferredHeight: 55
                    echoMode: TextInput.Password
                    placeholderText: "Password"
                    placeholderTextColor: mOnSurface
                    font.family: fontFamily
                    font.pixelSize: Math.round(baseFontSize * 1.83)
                    color: mOnSurface
                    horizontalAlignment: TextInput.AlignHCenter

                    background: Rectangle {
                        color: withAlpha(mSurface, cardOpacity)
                        radius: passwordInputRadius
                        border.color: passwordField.activeFocus ? mPrimary : mOutline
                    }
                    onAccepted: sddm.login(userPicker.currentText, text, sessionPicker.currentIndex)
                }

                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 50
                    Button {
                        id: shutBtn
                        onClicked: sddm.powerOff()
                        background: Rectangle {
                            radius: buttonRadius
                            color: "transparent"
                        }
                        contentItem: Text {

                            text: "\ue8ac"
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: Math.round(baseFontSize * 3.5)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: shutBtn.hovered ? mError : mOnSurface
                        }
                    }

                    Button {
                        id: rebBtn
                        onClicked: sddm.reboot()
                        background: Rectangle {
                            radius: buttonRadius
                            color: "transparent"
                        }
                        contentItem: Text {
                            text: "\uf053"
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: Math.round(baseFontSize * 3.5)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: rebBtn.hovered ? mHover : mOnSurface
                        }
                    }
                }

                ComboBox {
                    id: sessionPicker
                    Layout.alignment: Qt.AlignHCenter

                    implicitWidth: contentItem.implicitWidth + (indicator.width * 2) + 20
                    Layout.preferredHeight: 40

                    model: sessionModel
                    currentIndex: sessionModel.lastIndex
                    textRole: "name"
                    font.family: fontFamily
                    font.pixelSize: Math.round(baseFontSize * 1.5)

                    background: Rectangle {
                        color: withAlpha(mSurface, cardOpacity)
                        radius: passwordInputRadius
                        border.color: mOutline
                        border.width: 1
                    }

                    contentItem: Text {
                        text: sessionPicker.displayText
                        font: sessionPicker.font
                        color: mOnSurface
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        leftPadding: 15
                        rightPadding: 15
                    }

                    indicator: Canvas {
                        id: canvas
                        x: sessionPicker.width - width - 10
                        y: (sessionPicker.height - height) / 2
                        width: 10
                        height: 6
                        onPaint: {
                            var context = getContext("2d");
                            context.reset();
                            context.moveTo(0, 0);
                            context.lineTo(width, 0);
                            context.lineTo(width / 2, height);
                            context.closePath();
                            context.fillStyle = mPrimary;
                            context.fill();
                        }
                    }
                }
            }
        }
    }
}
