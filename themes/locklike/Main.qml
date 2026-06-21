import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Window
import "components"
import "widgets"
import "assets/userColors/userColors.js" as UserColors

Rectangle {
    id: root

    property bool ap: config.ap === "true" ? true : false
    property bool sessionPickerEnabled: config.sessionPicker === "true" ? true : false
    property string avatarShape: {
        var shape = config.AvatarShape || "hexagon";
        return (shape !== "hexagon" && shape !== "circle") ? "hexagon" : shape;
    }
    property bool welcomeMessageEnabled: config.enableWelcomeMessage !== "false"
    property bool firstInput: welcomeMessageEnabled
    property bool loading: false
    property string buffer
    property real welcomeBgBlurAmount: parseFloat(config.welcomeBgBlurAmount) || 1
    property bool welcomeBgBlur: config.welcomeBgBlur === "true"
    property real mainCardBlurAmount: parseFloat(config.mainCardBlurAmount) || 1
    property real mainCardComponentsOpacity: {
        var value = parseFloat(config.mainCardComponentsOpacity);
        if (isNaN(value) || value < 0.6)
            return 1;
        return value;
    }
    property bool capsLockOn: false
    property bool mainCardBgBlur: config.mainCardBgBlur === "true"
    property int sessionIndex

    property real largeRadius: mainCard.radius
    property real midRadius: mainCard.radius / 1.4
    property real smallRadius: mainCard.radius / 2

    property string currentUser: userPicker.currentText

    property int animDuration: 300
    property int syncDelay: 150
    property bool transitionBusy: false
    property int _activeLayer: 0

    onCurrentUserChanged: {
        if (transitionBusy) return;
        transitionBusy = true;
        transitionTimer.restart();

        // prepare wallpaper (hidden layer starts loading)
        var source = "assets/background-" + currentUser;
        var hidden = _activeLayer === 0 ? wallpaperB : wallpaperA;
        hidden.source = source;

        syncTimer.restart();
    }

    Timer {
        id: syncTimer
        interval: syncDelay
        onTriggered: {
            // wallpaper crossfade
            _activeLayer = _activeLayer === 0 ? 1 : 0;

            // color transitions (all start simultaneously)
            var c = UserColors.colors[currentUser] || {};
            if (c.background) config.background = c.background;
            if (c.mainCard) config.mainCard = c.mainCard;
            if (c.subComponents) config.subComponents = c.subComponents;
            if (c.text) config.text = c.text;
            if (c.inverseOnSurface) config.inverseOnSurface = c.inverseOnSurface;
            if (c.primary) config.primary = c.primary;
            if (c.secondary) config.secondary = c.secondary;
            if (c.textDark) config.textDark = c.textDark;
            if (c.onPrimary) config.onPrimary = c.onPrimary;
            if (c.onSuccess) config.onSuccess = c.onSuccess;
            if (c.outline) config.outline = c.outline;

            // avatar crossfade
            userAvatar.crossfade();
        }
    }

    Timer {
        id: transitionTimer
        interval: syncDelay + animDuration + 100
        onTriggered: transitionBusy = false
    }

    width: 1920
    height: 1080
    color: config.background || "#131313"

    Behavior on color {
        ColorAnimation { duration: 300; easing: Easing.InOutCubic }
    }

    Connections {
        function onLoginFailed() {
            root.buffer = "";
            root.loading = false;
            inputRect.color = config.subComponents;
            inputRect.shake();
        }

        function onLoginSucceeded() {
            root.loading = false;
            inputRect.color = config.subComponents;
        }

        target: sddm
    }

    Item {
        id: wallpaperContainer
        anchors.fill: parent

        AnimatedImage {
            id: wallpaperA
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            opacity: _activeLayer === 0 ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: root.animDuration; easing: Easing.InOutCubic }
            }
            onStatusChanged: {
                if (status === Image.Error)
                    source = "assets/background"
            }
            Component.onCompleted: {
                source = "assets/background-" + root.currentUser;
            }
        }

        AnimatedImage {
            id: wallpaperB
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            opacity: _activeLayer === 1 ? 1 : 0
            Behavior on opacity {
NumberAnimation { duration: root.animDuration; easing: Easing.InOutCubic }
        }
            onStatusChanged: {
                if (status === Image.Error)
                    source = "assets/background"
            }
        }
    }

    Rectangle {
        id: bgOverlay
        anchors.fill: parent
        color: "#000000"
        opacity: firstInput ? 0 : 0.4
        Behavior on opacity {
            NumberAnimation { duration: 150; easing: Easing.InOutCubic }
        }
    }

    MultiEffect {
        blurEnabled: true
        source: wallpaperContainer
        blur: root.firstInput ? 0 : 1
        autoPaddingEnabled: false
        blurMultiplier: 1
        blurMax: 64
        anchors.fill: wallpaperContainer

        Behavior on blur {
            NumberAnimation { duration: 400; easing: Easing.InOutCubic }
        }
    }

    Item {
        id: keylogger
        focus: true
        Keys.onPressed: {
            if (event.key === Qt.Key_Escape) {
                if (root.welcomeMessageEnabled)
                    root.firstInput = true;
                root.buffer = "";
                return;
            }
            if (event.key === Qt.Key_CapsLock) {
                root.capsLockOn = !root.capsLockOn;
                return;
            }
            if (event.key === Qt.Key_Tab) return;
            if (root.firstInput) {
                root.firstInput = false;
                return;
            }
            if (event.key === Qt.Key_Right) {
                if (!root.transitionBusy && userPicker.currentIndex < userModel.count - 1)
                    userPicker.currentIndex += 1;
                return;
            }
            if (event.key === Qt.Key_Left) {
                if (!root.transitionBusy && userPicker.currentIndex > 0)
                    userPicker.currentIndex -= 1;
                return;
            }
            if (event.key === Qt.Key_Up) {
                if (sessionPickerBtn.selectedIndex < sessionPickerBtn.count - 1)
                    sessionPickerBtn.selectedIndex += 1;
                return;
            }
            if (event.key === Qt.Key_Down) {
                if (sessionPickerBtn.selectedIndex > 0)
                    sessionPickerBtn.selectedIndex -= 1;
                return;
            }
            if (event.key === Qt.Key_Backspace) {
                root.buffer = root.buffer.slice(0, -1);
                return;
            }
            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                sddm.login(userPicker.currentText, root.buffer, root.sessionIndex);
                root.buffer = "";
                root.loading = true;
                return;
            }
            root.buffer += event.text;
        }
    }

    Greeting {
        anchors.centerIn: parent
        firstInput: root.firstInput
        mainCardRadius: root.midRadius
        rootHeight: root.height
        rootWidth: root.width
        greetingText: greeting.welcomeString
        username: userPicker.currentText
        blurAmount: root.welcomeBgBlurAmount
        blurEnabled: root.welcomeBgBlur
    }

    Rectangle {
        id: mainCard
        width: 1350
        height: 750
        scale: firstInput ? 0.5 : 1
        opacity: firstInput ? 0 : 1
        anchors.centerIn: parent
        radius: 70
        color: "transparent"

        BlurWrapper {
            anchors.centerIn: parent
            targetWidth: mainCard.width
            targetHeight: mainCard.height
            animDuration: 0
            blurAmount: root.mainCardBlurAmount
            bgColor: config.mainCard
            visibleState: !root.firstInput
            radius: 50
        }

        MainClock {
            anchors.horizontalCenter: mainCard.horizontalCenter
            anchors.top: mainCard.top
            anchors.topMargin: 170
            firstInput: root.firstInput
            mainCardComponentsOpacity: root.mainCardComponentsOpacity
            ap: root.ap
        }

        property date currentTime: new Date()
        property string day: Qt.formatDateTime(currentTime, "dddd").toUpperCase()
        property string date: Qt.formatDateTime(currentTime, "d MMM").toUpperCase()

        readonly property var fontAxesTitle: ({
                "wght": 500,
                "wdth": 30,
                "ROND": 25,
                "opsz": 224 * centerScale
            })

        FontLoader {
            id: googleSansFlex
            source: "assets/google-sans-flex/GoogleSansFlex.ttf"
        }

        Text {
            anchors.horizontalCenter: mainCard.horizontalCenter
            anchors.top: mainCard.top
            anchors.topMargin: 267
            anchors.bottom: parent.bottom
            color: config.text
            text: mainCard.day + " • " + mainCard.date
            font.pixelSize: 22
            font.family: googleSansFlex.name
            font.bold: true
            font.variableAxes: mainCard.fontAxesTitle

            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 40

            ColumnLayout {
                spacing: 13
                Layout.alignment: Qt.AlignLeft

                Rectangle {
                    id: topLeftRect
                    width: 390
                    height: 220
                    color: config.subComponents
                    radius: root.midRadius
                    opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity
                    clip: true

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }

                    WelcomeText {
                        id: greeting
                        anchors.centerIn: parent
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 300; easing.type: Easing.OutBack }
                    }
                }

                Rectangle {
                    id: middleLeftRect
                    width: 390
                    Layout.fillHeight: true
                    color: config.subComponents
                    radius: mainCard.radius / 4
                    opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity
                    clip: true

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }

                    CaelestiaFetch {
                        firstInput: root.firstInput
                        currentUser: userPicker.currentText
                        currentSession: sessionPickerBtn.currentText
                        rectHeight: middleLeftRect.height
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 300; easing.type: Easing.OutBack }
                    }
                }

                Rectangle {
                    id: bottomLeftRect
                    width: 390
                    height: 190
                    color: "transparent"
                    bottomLeftRadius: mainCard.radius / 1.9
                    radius: root.midRadius / 1.7
                    opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity

                    SystemButtons {
                        anchors.horizontalCenter: parent.horizontalCenter
                        rectHeight: bottomLeftRect.height
                        rectWidth: bottomLeftRect.height - 1
                        rectRadius: bottomLeftRect.radius
                        rectBigRadius: mainCard.radius / 1.9
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 300; easing.type: Easing.OutBack }
                    }
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                spacing: 0

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    color: "transparent"
                    width: 300
                    height: 140
                }

                Item {
                    height: 45
                }

                Avatar {
                    id: userAvatar
                    avatarShape: root.avatarShape
                    currentUser: root.currentUser
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: root.avatarShape === "circle" ? 260 : 330
                    Layout.preferredHeight: root.avatarShape === "circle" ? 260 : 300
                    Layout.leftMargin: root.avatarShape === "circle" ? 0 : 34
                    Layout.topMargin: root.avatarShape === "circle" ? 20 : 0
                    Layout.bottomMargin: root.avatarShape === "circle" ? 20 : 0
                    opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity

                    Behavior on opacity {
                        NumberAnimation { duration: 300; easing.type: Easing.OutBack }
                    }
                }

                PasswordInput {
                    id: inputRect
                    Layout.alignment: Qt.AlignHCenter
                    mainCardComponentsOpacity: root.mainCardComponentsOpacity
                    firstInput: root.firstInput
                    isLoading: root.loading
                    buffer: root.buffer
                    currentUser: userPicker.currentText
                    currentSession: root.sessionIndex
                }

                Text {
                    Layout.margins: 10
                    Layout.alignment: Qt.AlignHCenter
                    text: "Caps Lock is activated!"
                    font.pointSize: 8
                    font.family: "Roboto"
                    color: config.text
                    opacity: 0

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 300; easing: Easing.InOutCubic }
                    }
                }
                Item {
                    height: 20
                }
            }

            ColumnLayout {
                spacing: 13
                Layout.alignment: Qt.AlignRight

                Rectangle {
                    id: topRightRect
                    width: 390
                    height: 355
                    color: config.subComponents
                    radius: root.smallRadius
                    opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }

                    RandomQuote {
                        maxWidth: topRightRect.width - 40
                        color: config.text
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 300; easing.type: Easing.OutBack }
                    }
                }

                Rectangle {
                    id: bottomRightRect
                    width: 390
                    height: 355
                    color: config.subComponents
                    bottomRightRadius: mainCard.radius / 1.9
                    radius: mainCard.radius / 4
                    opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }

                    Image {
                        id: dino
                        width: 300
                        height: 150
                        source: "assets/dino.png"
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectCrop
                        layer.enabled: true
                        layer.effect: ColorOverlay {
                            color: config.inverseOnSurface

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }
                    }

                    Text {
                        renderType: Text.NativeRendering
                        text: "Unlock for notifications"
                        color: config.inverseOnSurface
                        font.family: "CaskaydiaCove NF"
                        font.pointSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 50

                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 300; easing.type: Easing.OutBack }
                    }
                }
            }
        }

        SessionPicker {
            id: sessionPickerBtn
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: mainCard.height - 100
            currentText: sessionArray.sessions[0].name
            selectedIndex: 0
            opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity
            visible: root.sessionPickerEnabled
            onSelectedIndexChanged: {
                root.sessionIndex = sessionPickerBtn.selectedIndex;
            }

            Behavior on opacity {
                NumberAnimation { duration: 300; easing.type: Easing.OutBack }
            }
        }

        Behavior on scale {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack }
        }

        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack }
        }
    }

    ComboBox {
        id: userPicker
        width: 190
        height: 50
        anchors.right: parent.right
        anchors.top: parent.top
        model: userModel
        currentIndex: userModel.lastIndex
        textRole: "name"
        font.family: "Rubik"
        font.pixelSize: 20
        visible: false

        background: Rectangle {
            color: "#BF131313"
            radius: 30
            border.color: "#353535"
            border.width: 1
        }

        contentItem: Text {
            renderType: Text.NativeRendering
            text: userPicker.displayText
            font: userPicker.font
            color: "#e2e2e2"
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
                context.fillStyle = "#4cdadb";
                context.fill();
            }
        }
    }
}
