import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import "assets/userColors/userColors.js" as UserColors
import "components"
import "widgets"

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

    // rounding stuff
    property real largeRadius: mainCard.radius
    property real midRadius: mainCard.radius / 1.4
    property real smallRadius: mainCard.radius / 2

    property string currentUser: userPicker.currentText

    property int animDuration: parseInt(config.animDuration) || 300
    property int syncDelay: parseInt(config.syncDelay) || 150
    property real bgBlur: parseFloat(config.bgBlur) || 0.5
    property bool transitionBusy: false
    property bool powerConfirmEnabled: config.powerConfirmEnabled !== "false"
    property real powerOverlayOpacity: parseFloat(config.powerOverlayOpacity) || 0.8
    property real powerBlur: parseFloat(config.powerBlur) || 1.0


    Component.onCompleted: {
        config.animDuration = parseInt(config.animDuration) || 300;
        config.syncDelay = parseInt(config.syncDelay) || 150;
        var ad = settingsStore.get("animDuration", config.animDuration);
        root.animDuration = parseInt(ad);
        config.animDuration = parseInt(ad);
        var sd = settingsStore.get("syncDelay", config.syncDelay);
        root.syncDelay = parseInt(sd);
        config.syncDelay = parseInt(sd);
        var bb = settingsStore.get("bgBlur", config.bgBlur);
        root.bgBlur = parseFloat(bb);
        config.bgBlur = parseFloat(bb);
        var po = settingsStore.get("powerOverlay", Math.round(root.powerOverlayOpacity * 100));
        root.powerOverlayOpacity = parseInt(po) / 100;
        config.powerOverlayOpacity = root.powerOverlayOpacity;
        var pb = settingsStore.get("powerBlur", Math.round(root.powerBlur * 100));
        root.powerBlur = parseInt(pb) / 100;
        config.powerBlur = root.powerBlur;
    }

    onCurrentUserChanged: {
        if (transitionBusy) return;
        transitionBusy = true;
        transitionTimer.restart();

        wallpaperComponent.prepareForUser(currentUser);

        syncTimer.restart();
    }

    Timer {
        id: syncTimer
        interval: syncDelay
        onTriggered: {
            wallpaperComponent.switchLayer();

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

            // text crossfades
            leftColumn.crossfadeGreeting();
            leftColumn.crossfadeFetchPanel();
        }
    }

    Timer {
        id: transitionTimer
        interval: syncDelay + animDuration + 100
        onTriggered: transitionBusy = false
    }

    readonly property int _settingsMargin: 16
    readonly property int _gap: 10

    width: 1920
    height: 1080
    color: config.background || "#131313"

    Behavior on color {
        ColorAnimation { duration: root.animDuration; easing: Easing.InOutCubic }
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

    Wallpaper {
        id: wallpaperComponent
        animDuration: root.animDuration
        currentUser: userPicker.currentText
    }

    Rectangle {
        id: bgOverlay
        anchors.fill: parent
        color: "#000000"
        opacity: firstInput ? 0 : 0.4
        Behavior on opacity {
            NumberAnimation { duration: root.animDuration; easing: Easing.InOutCubic }
        }
    }

    MultiEffect {
        blurEnabled: true
        source: wallpaperComponent
        blur: root.bgBlur
        autoPaddingEnabled: false
        blurMultiplier: 1
        blurMax: 64
        anchors.fill: wallpaperComponent

        Behavior on blur {
            NumberAnimation { duration: root.animDuration; easing: Easing.InOutCubic }
        }
    }

    KeyboardHandler {
        id: keylogger
        welcomeEnabled: root.welcomeMessageEnabled
        powerDialogVisible: powerDialog.visible
        settingsOpen: root.sOpen
        firstInputActive: root.firstInput

        onEscapePressed: {
            root.buffer = "";
        }
        onSettingsCloseRequested: {
            settingsPanel.close();
        }
        onWelcomeResetRequested: {
            root.firstInput = true;
        }
        onFirstInputDismissed: {
            root.firstInput = false;
        }
        onCapsLockToggled: {
            root.capsLockOn = !root.capsLockOn;
        }
        onRightPressed: {
            if (!root.transitionBusy && userPicker.currentIndex < userModel.count - 1)
                userPicker.currentIndex += 1;
        }
        onLeftPressed: {
            if (!root.transitionBusy && userPicker.currentIndex > 0)
                userPicker.currentIndex -= 1;
        }
        onUpPressed: {
            if (sessionPickerBtn.selectedIndex < sessionPickerBtn.count - 1)
                sessionPickerBtn.selectedIndex += 1;
        }
        onDownPressed: {
            if (sessionPickerBtn.selectedIndex > 0)
                sessionPickerBtn.selectedIndex -= 1;
        }
        onBackspacePressed: {
            root.buffer = root.buffer.slice(0, -1);
        }
        onEnterPressed: {
            if (powerDialog.visible) return;
            sddm.login(userPicker.currentText, root.buffer, root.sessionIndex);
            root.buffer = "";
            root.loading = true;
        }
        onCharEntered: function(ch) {
            root.buffer += ch;
        }
    }

    Greeting {
        anchors.centerIn: parent
        firstInput: root.firstInput
        mainCardRadius: root.midRadius
        rootHeight: root.height
        rootWidth: root.width
        greetingText: leftColumn.welcomeString
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
        radius: parseInt(config.mainCardRadius) || 70
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

        readonly property real centerScale: Math.min(mainCard.width, mainCard.height) / 500

        readonly property var fontAxesTitle: ({
                "wght": 500,
                "wdth": 30,
                "ROND": 25,
                "opsz": Math.max(16, Math.min(224, 224 * centerScale))
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
                ColorAnimation { duration: root.animDuration }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: parseInt(config.mainCardMargin) || 15
            spacing: parseInt(config.layoutSpacing) || 40

            LeftColumn {
                id: leftColumn
                firstInput: root.firstInput
                mainCardComponentsOpacity: root.mainCardComponentsOpacity
                animDuration: root.animDuration
                midRadius: root.midRadius
                mainCardRadius: mainCard.radius
                currentUser: userPicker.currentText
                currentSession: sessionPickerBtn.currentText
                powerConfirmEnabled: root.powerConfirmEnabled
                onPowerRequested: powerDialog.show(0)
                onRebootRequested: powerDialog.show(1)
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                spacing: 0

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    color: "transparent"
                    Layout.preferredWidth: 300
                    Layout.preferredHeight: 140
                }

                Item {
                    Layout.preferredHeight: 45
                }

                Avatar {
                    id: userAvatar
                    avatarShape: root.avatarShape
                    currentUser: root.currentUser
                    animDuration: root.animDuration
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: root.avatarShape === "circle" ? (parseInt(config.avatarCircleSize) || 260) : (parseInt(config.avatarHexagonWidth) || 330)
                    Layout.preferredHeight: root.avatarShape === "circle" ? (parseInt(config.avatarCircleSize) || 260) : (parseInt(config.avatarHexagonHeight) || 300)
                    Layout.leftMargin: root.avatarShape === "circle" ? 0 : 34
                    Layout.topMargin: root.avatarShape === "circle" ? 20 : 0
                    Layout.bottomMargin: root.avatarShape === "circle" ? 20 : 0
                    opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity

                    Behavior on opacity {
                        NumberAnimation { duration: root.animDuration; easing.type: Easing.OutBack }
                    }
                }

                PasswordInput {
                    id: inputRect
                    Layout.alignment: Qt.AlignHCenter
                    animDuration: root.animDuration
                    mainCardComponentsOpacity: root.mainCardComponentsOpacity
                    firstInput: root.firstInput
                    isLoading: root.loading
                    buffer: root.buffer
                    currentUser: userPicker.currentText
                    currentSession: root.sessionIndex
                    onFocusRequested: keylogger.forceActiveFocus()
                }

                Text {
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    Layout.topMargin: 6
                    Layout.alignment: Qt.AlignHCenter
                    text: config.capsLockWarning
                    font.pointSize: 8
                    font.family: "Roboto"
                    color: config.text
                    opacity: root.capsLockOn ? 1 : 0

                    Behavior on color {
                        ColorAnimation { duration: root.animDuration }
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: root.animDuration; easing: Easing.InOutCubic }
                    }
                }
                Item {
                    Layout.preferredHeight: 2 * root._gap
                }
            }

            RightColumn {
                firstInput: root.firstInput
                mainCardComponentsOpacity: root.mainCardComponentsOpacity
                animDuration: root.animDuration
                locale: localeManager.currentLocale
                smallRadius: root.smallRadius
                mainCardRadius: mainCard.radius
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
                NumberAnimation { duration: root.animDuration; easing.type: Easing.OutBack }
            }
        }

        Behavior on scale {
            NumberAnimation { duration: root.animDuration; easing.type: Easing.OutBack }
        }

        Behavior on opacity {
            NumberAnimation { duration: root.animDuration; easing.type: Easing.OutBack }
        }
    }

    LocaleManager {
        id: localeManager

        onLanguageChanged: {
            leftColumn.refreshGreeting();
        }
    }

    property bool sOpen: false

    MouseArea {
        anchors.fill: parent
        visible: root.sOpen && !powerDialog.visible
        z: 50
        onClicked: {
            settingsPanel.close();
            keylogger.forceActiveFocus();
        }
    }

    SettingsPanel {
        id: settingsPanel
        z: 100
        anchors.right: parent.right; anchors.rightMargin: _settingsMargin
        y: _settingsMargin
        animDuration: root.animDuration
        syncDelay: root.syncDelay
        bgBlur: root.bgBlur
        powerOverlay: Math.round(root.powerOverlayOpacity * 100)
        powerBlur: Math.round(root.powerBlur * 100)
        localeManager: localeManager
        welcomeEnabled: root.welcomeMessageEnabled
        mainCardBlur: root.mainCardBlurAmount
        mainCardOpacity: root.mainCardComponentsOpacity
        mainCardBgBlurEnabled: root.mainCardBgBlur
        sessionPickerEnabled: root.sessionPickerEnabled
        powerConfirmEnabled: root.powerConfirmEnabled
        avatarShape: root.avatarShape
        onOpenChanged: root.sOpen = open
        onAnimDurationChanged: if (animDuration !== root.animDuration) { root.animDuration = animDuration; config.animDuration = animDuration; settingsStore.set("animDuration", animDuration); }
        onSyncDelayChanged: if (syncDelay !== root.syncDelay) { root.syncDelay = syncDelay; config.syncDelay = syncDelay; settingsStore.set("syncDelay", syncDelay); }
        onBgBlurChanged: if (bgBlur !== root.bgBlur) { root.bgBlur = bgBlur; config.bgBlur = bgBlur; settingsStore.set("bgBlur", bgBlur); }
        onPowerOverlayChanged: if (powerOverlay !== Math.round(root.powerOverlayOpacity * 100)) { root.powerOverlayOpacity = powerOverlay / 100; config.powerOverlayOpacity = powerOverlay / 100; settingsStore.set("powerOverlay", powerOverlay); }
        onPowerBlurChanged: if (powerBlur !== Math.round(root.powerBlur * 100)) { root.powerBlur = powerBlur / 100; config.powerBlur = powerBlur / 100; settingsStore.set("powerBlur", powerBlur); }
        onWelcomeEnabledChanged: { root.welcomeMessageEnabled = welcomeEnabled; config.enableWelcomeMessage = welcomeEnabled.toString(); }
        onMainCardBlurChanged: { root.mainCardBlurAmount = mainCardBlur; config.mainCardBlurAmount = mainCardBlur.toString(); }
        onMainCardOpacityChanged: { root.mainCardComponentsOpacity = mainCardOpacity; config.mainCardComponentsOpacity = mainCardOpacity.toString(); }
        onMainCardBgBlurEnabledChanged: { root.mainCardBgBlur = mainCardBgBlurEnabled; config.mainCardBgBlur = mainCardBgBlurEnabled.toString(); }
        onSessionPickerEnabledChanged: { root.sessionPickerEnabled = sessionPickerEnabled; config.sessionPicker = sessionPickerEnabled.toString(); }
        onPowerConfirmEnabledChanged: { root.powerConfirmEnabled = powerConfirmEnabled; config.powerConfirmEnabled = powerConfirmEnabled.toString(); }
        onAvatarShapeChanged: { config.AvatarShape = avatarShape; root.avatarShape = avatarShape; }
    }

    SettingsStore {
        id: settingsStore
    }

    UserPicker {
        id: userPicker
    }

    PowerDialog {
        id: powerDialog
        z: 200
        anchors.fill: parent
        animDuration: root.animDuration
        overlayOpacity: root.powerOverlayOpacity
        powerBlur: root.powerBlur
        powerConfirmEnabled: root.powerConfirmEnabled
        onConfirmed: function(cmd) {
            if (cmd === "poweroff") sddm.powerOff();
            else if (cmd === "reboot") sddm.reboot();
        }
    }

        onPowerConfirmEnabledChanged: {
            leftColumn.systemButtons.powerConfirmEnabled = root.powerConfirmEnabled;
        }

        onSOpenChanged: {
            if (!root.sOpen) keylogger.forceActiveFocus();
        }

        Connections {
            target: powerDialog
            function onVisibleChanged() {
                if (!powerDialog.visible) keylogger.forceActiveFocus();
            }
        }
}
