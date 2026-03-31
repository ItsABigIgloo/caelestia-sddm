import Qt5Compat.GraphicalEffects
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Effects
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    // ---- Custom properties from config ---- //
    property string backgroundSource: {
        var source = config.background ? config.background.toString().trim() : "";
        if (!source || source === "")
            return "assets/background.png";

        return source;
    }
    property string fontFamily: {
        var availableFonts = Qt.fontFamilies();
        var family = config.fontFamily;
        if (family && family !== "") {
            family = family.toString().replace(/^"|"$/g, "");
            if (availableFonts.indexOf(family) !== -1)
                return family;

        }
        return firstAvailable(["Rubik", "Sans"]);
    }
    // Sizes and dimensions
    property real baseFontSize: boundedNumber(config.FontSize, 12, 10, 24)
    property real avatarBaseSize: boundedNumber(config.AvatarSize, 128, 64, 320)
    property real avatarFrameSize: Math.max(96, Math.round(avatarBaseSize * 1.72))
    property real avatarInset: Math.max(8, Math.round(avatarFrameSize * 0.09))
    property real buttonRadius: boundedNumber(config.buttonRadius, 20, 0, 64)
    property real passwordInputRadius: boundedNumber(config.passwordInputRadius, 20, 0, 64)
    property real cardRadius: boundedNumber(config.cardRadius, 30, 0, 80)
    // Colors
    property color mPrimary: config.mPrimary || "#4cdadb"
    property color mOnPrimary: config.mOnPrimary || "#002022"
    property color mSecondary: config.mSecondary || "#95f4f5"
    property color mOnSecondary: config.mOnSecondary || "#003738"
    property color mTertiary: config.mTertiary || "#86d0ff"
    property color mOnTertiary: config.mOnTertiary || "#00344d"
    property color mError: config.mError || "#ffb4ab"
    property color mOnError: config.mOnError || "#690005"
    property color mSurface: config.mSurface || "#131313"
    property color mOnSurface: config.mOnSurface || "#e2e2e2"
    property color mSurfaceVariant: config.mSurfaceVariant || "#353535"
    property color mOnSurfaceVariant: config.mOnSurfaceVariant || "#919191"
    property color mOutline: config.mOutline || "#7d7d7d"
    property color mShadow: config.mShadow || "#000000"
    property color mHover: config.mHover || mPrimary
    property color mOnHover: config.mOnHover || mOnPrimary
    // Effects
    property bool dropShadows: toBool(config.dropShadows, true)
    property bool blurEnabled: toBool(config.blurEnabled, true)
    property real blurStrength: boundedNumber(config.blurStrength, 1, 0, 1)
    property real cardOpacity: boundedNumber(config.cardOpacity, 0.95, 0, 1)
    property real overlayOpacity: boundedNumber(config.overlayOpacity, 0.4, 0, 1)
    // Animation durations
    property int animDurationFast: 200
    property int animDurationNormal: 300
    property int animDurationSlow: 400
    // State
    property bool firstInput: true
    property string buffer: ""

    // ---- Utility functions ---- //
    function firstAvailable(candidates) {
        for (var i = 0; i < candidates.length; i++) {
            if (availableFonts.indexOf(candidates[i]) !== -1)
                return candidates[i];

        }
        return "sans-serif";
    }

    function toNumber(value, fallbackValue) {
        var num = Number(value);
        return isFinite(num) ? num : fallbackValue;
    }

    function boundedNumber(value, fallbackValue, minValue, maxValue) {
        var num = toNumber(value, fallbackValue);
        if (num < minValue)
            return minValue;

        if (num > maxValue)
            return maxValue;

        return num;
    }

    function toBool(value, fallbackValue) {
        if (value === undefined || value === null || value === "")
            return fallbackValue;

        var normalized = String(value).toLowerCase();
        return normalized === "true" || normalized === "1" || normalized === "yes" || normalized === "on";
    }

    function withAlpha(baseColor, alphaValue) {
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, alphaValue);
    }

    function restoreFocus() {
        keyHandler.forceActiveFocus();
    }

    // ---- Basic Properties ---- //
    width: 1920
    height: 1080
    color: mSurface

    Item {
        id: keyHandler

        focus: true
        Keys.onPressed: function(event) {
            if (root.firstInput) {
                root.firstInput = false;
                return ;
            }
            if (event.key === Qt.Key_Escape) {
                root.firstInput = true;
                root.buffer = "";
                return ;
            }
            if (event.key === Qt.Key_Right) {
                if (userModel.count > 0 && userPicker.currentIndex < userModel.count - 1) {
                    userPicker.currentIndex += 1;
                    root.buffer = "";
                }
                return ;
            }
            if (event.key === Qt.Key_Left) {
                if (userModel.count > 0 && userPicker.currentIndex > 0) {
                    userPicker.currentIndex -= 1;
                    root.buffer = "";
                }
                return ;
            }
            if (event.key === Qt.Key_Up) {
                if (sessionModel.count > 0 && sessionPicker.currentIndex > 0)
                    sessionPicker.currentIndex -= 1;

                return ;
            }
            if (event.key === Qt.Key_Down) {
                if (sessionModel.count > 0 && sessionPicker.currentIndex < sessionModel.count - 1)
                    sessionPicker.currentIndex += 1;

                return ;
            }
            if (event.key === Qt.Key_Backspace) {
                root.buffer = root.buffer.slice(0, -1);
                return ;
            }
            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                sddm.login(userPicker.currentText, root.buffer, sessionPicker.currentIndex);
                root.buffer = "";
                return ;
            }
            if (!root.firstInput && event.text && event.text !== "" && event.text.length === 1)
                root.buffer += event.text;

        }
    }

    Image {
        id: background

        property string src: backgroundSource
        property bool isVideo: src.endsWith(".mp4") || src.endsWith(".webm")
        property bool isGif: src.endsWith(".gif")

        anchors.fill: parent
        source: background.src
        fillMode: Image.PreserveAspectCrop
        visible: !background.isVideo && !background.isGif
        asynchronous: true
        smooth: true
        mipmap: true
        layer.enabled: true
        layer.smooth: true
        layer.mipmap: true

        Rectangle {
            anchors.fill: parent
            color: mShadow
            opacity: firstInput ? 0 : overlayOpacity

            Behavior on opacity {
                NumberAnimation {
                    duration: root.animDurationNormal
                }

            }

        }

    }

    MultiEffect {
        source: background
        anchors.fill: background
        blurEnabled: root.blurEnabled
        blur: firstInput ? 0 : root.blurStrength
        blurMax: 64
        blurMultiplier: 1
        autoPaddingEnabled: false

        Behavior on blur {
            NumberAnimation {
                duration: root.animDurationSlow
            }

        }

    }

    Item {
        id: cardContainer

        width: 550
        height: 800
        anchors.centerIn: parent
        scale: firstInput ? 0.5 : 1
        opacity: firstInput ? 0 : 1

        DropShadow {
            anchors.fill: mainCard
            horizontalOffset: 0
            verticalOffset: 10
            radius: 16
            samples: 32
            spread: 0.2
            color: withAlpha(mShadow, 0.55)
            source: mainCard
            visible: dropShadows
            transparentBorder: true
        }

        Rectangle {
            id: mainCard

            anchors.fill: parent
            radius: cardRadius
            border.color: withAlpha(mPrimary, cardOpacity)
            border.width: 1
            opacity: cardOpacity

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 40
                spacing: 30

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10

                    Text {
                        id: clock

                        renderType: Text.NativeRendering
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatTime(new Date(), "hh:mm AP")
                        font.pixelSize: Math.round(baseFontSize * 7)
                        font.family: fontFamily
                        color: mOnSurface
                    }

                    Text {
                        renderType: Text.NativeRendering
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDate(new Date(), "dddd, d MMMM yyyy")
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
                    clip: true

                    Image {
                        id: avatarImage

                        property var avatarCandidates: ["assets/logo.png"]
                        property int avatarCandidateIndex: 0
                        property int roleHomeDir: Qt.UserRole + 3
                        property int roleIcon: Qt.UserRole + 4

                        function toSourceUrl(pathOrUrl) {
                            if (!pathOrUrl || pathOrUrl === "")
                                return "";

                            var value = String(pathOrUrl);
                            if (value.startsWith("file://") || value.startsWith("qrc:/") || value.startsWith(":/") || value.startsWith("http://") || value.startsWith("https://"))
                                return value;

                            if (value.startsWith("/"))
                                return "file://" + value;

                            return value;
                        }

                        function appendCandidate(list, value) {
                            var normalized = toSourceUrl(value);
                            if (normalized !== "" && list.indexOf(normalized) === -1)
                                list.push(normalized);

                        }

                        function rebuildAvatarCandidates() {
                            var list = [];
                            appendCandidate(list, "assets/avatar.face.icon");
                            appendCandidate(list, "assets/avatar.face");
                            if (userPicker.currentIndex >= 0 && userPicker.currentIndex < userModel.count) {
                                var modelIndex = userModel.index(userPicker.currentIndex, 0);
                                var icon = userModel.data(modelIndex, roleIcon);
                                var homeDir = userModel.data(modelIndex, roleHomeDir);
                                appendCandidate(list, icon);
                                if (homeDir && homeDir !== "") {
                                    appendCandidate(list, homeDir + "/.face.icon");
                                    appendCandidate(list, homeDir + "/.face");
                                }
                            }
                            appendCandidate(list, "assets/logo.png");
                            avatarCandidates = list;
                            avatarCandidateIndex = 0;
                        }

                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        smooth: true
                        mipmap: true
                        layer.enabled: true
                        source: avatarCandidates.length > 0 ? avatarCandidates[avatarCandidateIndex] : "assets/logo.png"
                        onStatusChanged: {
                            if (status === Image.Error && avatarCandidateIndex < avatarCandidates.length - 1)
                                avatarCandidateIndex += 1;

                        }
                        Component.onCompleted: rebuildAvatarCandidates()

                        Connections {
                            function onCurrentIndexChanged() {
                                avatarImage.rebuildAvatarCandidates();
                            }

                            target: userPicker
                        }

                        layer.effect: OpacityMask {

                            maskSource: Rectangle {
                                width: avatarImage.width
                                height: avatarImage.height
                                radius: avatarFrameSize / 2
                            }

                        }

                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: avatarFrame.radius
                        color: "transparent"
                        border.color: mPrimary
                        border.width: 2
                    }

                }

                StyledComboBox {
                    id: userPicker

                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 380
                    Layout.preferredHeight: 55
                    model: userModel
                    currentIndex: userModel.lastIndex
                    textRole: "name"
                    font.family: fontFamily
                    font.pixelSize: Math.round(baseFontSize * 1.67)
                    onRestoreFocus: restoreFocus
                }

                Rectangle {
                    id: passwordInput

                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 380
                    Layout.preferredHeight: 55
                    color: withAlpha(mSurface, cardOpacity)
                    radius: passwordInputRadius
                    border.color: mOutline
                    border.width: 1

                    Text {
                        renderType: Text.NativeRendering
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 17
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: Math.round(baseFontSize * 1.5)
                        text: "\ue897"
                        color: mOnSurfaceVariant
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        color: "transparent"
                        width: 250
                        height: 50
                        clip: true

                        Text {
                            renderType: Text.NativeRendering
                            anchors.centerIn: parent
                            font.family: fontFamily
                            font.pixelSize: Math.round(baseFontSize * 1.5)
                            text: "Enter your password"
                            color: mOnSurfaceVariant
                            opacity: root.buffer === "" ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: root.animDurationFast
                                }

                            }

                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Repeater {
                                id: passwordDots

                                model: root.buffer.length

                                Rectangle {
                                    radius: passwordInputRadius
                                    width: 12
                                    height: 12
                                    color: mOnSurface
                                }

                            }

                            Rectangle {
                                id: cursorIndicator

                                property bool blink: true

                                visible: root.buffer !== ""
                                width: 2
                                height: 25
                                color: mOnSurface
                                opacity: blink ? 1 : 0

                                Timer {
                                    running: cursorIndicator.visible
                                    repeat: true
                                    interval: 530
                                    onTriggered: cursorIndicator.blink = !cursorIndicator.blink
                                }

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: root.animDurationFast
                                    }

                                }

                            }

                        }

                    }

                    Rectangle {
                        id: loginButton

                        radius: passwordInputRadius
                        width: 35
                        height: 35
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 8
                        color: root.buffer === "" ? mSurfaceVariant : mPrimary

                        Text {
                            anchors.centerIn: parent
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: Math.round(baseFontSize * 1.67)
                            text: "\ue5c8"
                            color: root.buffer === "" ? mOnSurface : mOnPrimary

                            Behavior on color {
                                ColorAnimation {
                                    duration: root.animDurationFast
                                }

                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                sddm.login(userPicker.currentText, root.buffer, sessionPicker.currentIndex);
                                root.buffer = "";
                                restoreFocus();
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: root.animDurationFast
                            }

                        }

                    }

                }

                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 50

                    PowerButton {
                        id: shutBtn

                        iconText: "\ue8ac"
                        normalColor: mOnSurface
                        hoverColor: mError
                        onClickedAction: function() {
                            sddm.powerOff();
                        }
                    }

                    PowerButton {
                        id: rebBtn

                        iconText: "\uf053"
                        normalColor: mOnSurface
                        hoverColor: mHover
                        onClickedAction: function() {
                            sddm.reboot();
                        }
                    }

                }

                StyledComboBox {
                    id: sessionPicker

                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 380
                    Layout.preferredHeight: 40
                    model: sessionModel
                    currentIndex: sessionModel.lastIndex
                    textRole: "name"
                    font.family: fontFamily
                    font.pixelSize: Math.round(baseFontSize * 1.5)
                    onRestoreFocus: restoreFocus
                }

            }

            gradient: Gradient {
                GradientStop {
                    position: 0.5
                    color: withAlpha(mSurface, 0.92)
                }

                GradientStop {
                    position: 1
                    color: withAlpha(mPrimary, 0.36)
                }

            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: root.animDurationNormal
                easing.type: Easing.OutBack
            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.animDurationNormal
                easing.type: Easing.OutBack
            }

        }

    }

    Text {
        renderType: Text.NativeRendering
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        font.family: fontFamily
        font.pixelSize: Math.round(baseFontSize * 1.5)
        font.italic: true
        opacity: root.firstInput ? 1 : 0
        color: mOnSurfaceVariant
        text: "Press any key to login"

        Behavior on opacity {
            NumberAnimation {
                duration: root.animDurationNormal
                easing.type: Easing.OutCubic
            }

        }

    }

}
