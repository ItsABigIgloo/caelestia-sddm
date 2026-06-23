import Qt5Compat.GraphicalEffects
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
    property real mainCardComponentsOpacity: {
        var value = parseFloat(config.mainCardComponentsOpacity);
        if (isNaN(value) || value < 0.6)
            return 1;

        return value;
    }
    property bool capsLockOn: false
    property int sessionIndex

    // rounding stuff
    property real largeRadius: mainCard.radius
    property real midRadius: mainCard.radius / 1.4
    property real smallRadius: mainCard.radius / 2

    property string currentUser: userPicker.currentText

    property int animDuration: parseInt(config.animDuration) || 300
    property int syncDelay: parseInt(config.syncDelay) || 150
    property real bgBlur: parseFloat(config.bgBlur) || 0
    property bool powerConfirmEnabled: config.powerConfirmEnabled !== "false"
    property real powerOverlayOpacity: parseFloat(config.powerOverlayOpacity) || 0.8


    Component.onCompleted: {
        function load(key, fallback) {
            return settingsStore.get(key, fallback);
        }

        config.animDuration = parseInt(config.animDuration) || 300;
        config.syncDelay = parseInt(config.syncDelay) || 150;

        var ad = load("animDuration", config.animDuration);
        root.animDuration = parseInt(ad);
        config.animDuration = parseInt(ad);

        var sd = load("syncDelay", config.syncDelay);
        root.syncDelay = parseInt(sd);
        config.syncDelay = parseInt(sd);

        var bb = load("bgBlur", config.bgBlur);
        root.bgBlur = parseFloat(bb);
        config.bgBlur = parseFloat(bb);

        var po = load("powerOverlay", Math.round(root.powerOverlayOpacity * 100));
        root.powerOverlayOpacity = parseInt(po) / 100;
        config.powerOverlayOpacity = root.powerOverlayOpacity;

        var wm = load("enableWelcomeMessage", config.enableWelcomeMessage);
        root.welcomeMessageEnabled = wm !== "false";
        config.enableWelcomeMessage = wm;

        var sp = load("sessionPicker", config.sessionPicker);
        root.sessionPickerEnabled = sp === "true";
        config.sessionPicker = sp;

        var pc = load("powerConfirmEnabled", config.powerConfirmEnabled);
        root.powerConfirmEnabled = pc !== "false";
        config.powerConfirmEnabled = pc;

        var ap = load("ap", config.ap);
        root.ap = ap === "true";
        config.ap = ap;

        var as = load("avatarShape", config.AvatarShape || "hexagon");
        root.avatarShape = as;
        config.AvatarShape = as;

        var mo = load("mainCardComponentsOpacity", config.mainCardComponentsOpacity);
        root.mainCardComponentsOpacity = parseFloat(mo) || 1.0;
        config.mainCardComponentsOpacity = root.mainCardComponentsOpacity;

        var mco = load("mainCardColorOpacity", config.mainCardColorOpacity);
        config.mainCardColorOpacity = parseFloat(mco) || 0.9;

        var wco = load("welcomeColorOpacity", config.welcomeColorOpacity);
        config.welcomeColorOpacity = parseFloat(wco) || 0.7;

        var sf = load("settingsFontSize", config.settingsFontSize);
        config.settingsFontSize = parseInt(sf) || 18;

        var st = load("settingsTitleSize", config.settingsTitleSize);
        config.settingsTitleSize = parseInt(st) || 24;

        var wf = load("welcomeFontSize", config.welcomeFontSize);
        config.welcomeFontSize = parseInt(wf) || 40;

        var fc = load("fetchFontSize", config.fetchFontSize);
        config.fetchFontSize = parseInt(fc) || 18;

        var bt = load("buttonFontSize", config.buttonFontSize);
        config.buttonFontSize = parseInt(bt) || 14;

        var dt = load("dialogTitleSize", config.dialogTitleSize);
        config.dialogTitleSize = parseInt(dt) || 20;

        var db = load("dialogBodySize", config.dialogBodySize);
        config.dialogBodySize = parseInt(db) || 14;

        var qf = load("quoteFontSize", config.quoteFontSize);
        config.quoteFontSize = parseInt(qf) || 20;

        var dl = load("dropdownLabelSize", config.dropdownLabelSize);
        config.dropdownLabelSize = parseInt(dl) || 14;

        var di = load("dropdownItemSize", config.dropdownItemSize);
        config.dropdownItemSize = parseInt(di) || 13;

        var savedLocale = load("locale", "");
        if (savedLocale !== "") {
            Qt.callLater(function() { localeManager.switchLanguage(savedLocale); });
        }
    }

    onCurrentUserChanged: {
        wallpaperComponent.prepareForUser(currentUser);
        syncTimer.restart();
    }

    Timer {
        id: syncTimer
        interval: syncDelay
        onTriggered: {
            wallpaperComponent.switchLayer();

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

            userAvatar.crossfade();
            leftColumn.crossfadeGreeting();
            leftColumn.crossfadeFetchPanel();
        }
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
        settingsOpen: rightColumn.settingsOpen
        firstInputActive: root.firstInput

        onEscapePressed: {
            root.buffer = "";
        }
        onSettingsCloseRequested: {
            rightColumn.closeSettings();
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
            if (userPicker.currentIndex < userModel.count - 1)
                userPicker.currentIndex += 1;
        }
        onLeftPressed: {
            if (userPicker.currentIndex > 0)
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
        wallpaperSource: Qt.resolvedUrl(wallpaperComponent.activeSource)
    }

    Rectangle {
        id: mainCard
        z: 60

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
            blurAmount: 0.5
            blurEnabled: false
            bgColor: config.mainCard
            visibleState: !root.firstInput
            radius: 50
            source: Qt.resolvedUrl("../assets/background")
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
            opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity

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
                id: rightColumn
                firstInput: root.firstInput
                mainCardComponentsOpacity: root.mainCardComponentsOpacity
                animDuration: root.animDuration
                locale: localeManager.currentLocale
                smallRadius: root.smallRadius
                mainCardRadius: mainCard.radius
                welcomeEnabled: root.welcomeMessageEnabled
                sessionPickerEnabled: root.sessionPickerEnabled
                powerConfirmEnabled: root.powerConfirmEnabled
                apEnabled: root.ap
                avatarShape: root.avatarShape
                syncDelay: root.syncDelay
                bgBlur: root.bgBlur
                powerOverlay: Math.round(root.powerOverlayOpacity * 100)
                mainCardOpacity: root.mainCardComponentsOpacity
                mainCardColorOpacityVal: parseFloat(config.mainCardColorOpacity) || 0.9
                welcomeColorOpacityVal: parseFloat(config.welcomeColorOpacity) || 0.7
                settingsFontSize: parseInt(config.settingsFontSize) || 18
                settingsTitleSize: parseInt(config.settingsTitleSize) || 24
                welcomeFontSize: parseInt(config.welcomeFontSize) || 40
                fetchFontSize: parseInt(config.fetchFontSize) || 18
                buttonFontSize: parseInt(config.buttonFontSize) || 14
                dialogTitleSize: parseInt(config.dialogTitleSize) || 20
                dialogBodySize: parseInt(config.dialogBodySize) || 14
                quoteFontSize: parseInt(config.quoteFontSize) || 20
                dropdownLabelSize: parseInt(config.dropdownLabelSize) || 14
                dropdownItemSize: parseInt(config.dropdownItemSize) || 13
                localeManager: localeManager
                onAnimDurationChanged: { var v = rightColumn.animDuration; if (v !== root.animDuration) { root.animDuration = v; config.animDuration = v; settingsStore.set("animDuration", v); } }
                onBgBlurChanged: { var v = rightColumn.bgBlur; if (v !== root.bgBlur) { root.bgBlur = v; config.bgBlur = v; settingsStore.set("bgBlur", v); } }
                onSyncDelayChanged: { var v = rightColumn.syncDelay; if (v !== root.syncDelay) { root.syncDelay = v; config.syncDelay = v; settingsStore.set("syncDelay", v); } }
                onWelcomeEnabledChanged: { var v = rightColumn.welcomeEnabled; root.welcomeMessageEnabled = v; config.enableWelcomeMessage = v.toString(); settingsStore.set("enableWelcomeMessage", v.toString()); }
                onSessionPickerEnabledChanged: { var v = rightColumn.sessionPickerEnabled; root.sessionPickerEnabled = v; config.sessionPicker = v.toString(); settingsStore.set("sessionPicker", v.toString()); }
                onPowerConfirmEnabledChanged: { var v = rightColumn.powerConfirmEnabled; root.powerConfirmEnabled = v; config.powerConfirmEnabled = v.toString(); settingsStore.set("powerConfirmEnabled", v.toString()); leftColumn.systemButtons.powerConfirmEnabled = v; }
                onApEnabledChanged: { var v = rightColumn.apEnabled; root.ap = v; config.ap = v.toString(); settingsStore.set("ap", v.toString()); }
                onAvatarShapeChanged: { var v = rightColumn.avatarShape; root.avatarShape = v; config.AvatarShape = v; settingsStore.set("avatarShape", v); }
                onPowerOverlayChanged: { var v = rightColumn.powerOverlay; root.powerOverlayOpacity = v / 100; config.powerOverlayOpacity = root.powerOverlayOpacity; settingsStore.set("powerOverlay", v); }
                onMainCardOpacityChanged: { var v = rightColumn.mainCardOpacity; root.mainCardComponentsOpacity = v; config.mainCardComponentsOpacity = v; settingsStore.set("mainCardComponentsOpacity", v); }
                onMainCardColorOpacityValChanged: { var v = rightColumn.mainCardColorOpacityVal; config.mainCardColorOpacity = v; settingsStore.set("mainCardColorOpacity", v); }
                onWelcomeColorOpacityValChanged: { var v = rightColumn.welcomeColorOpacityVal; config.welcomeColorOpacity = v; settingsStore.set("welcomeColorOpacity", v); }
                onSettingsFontSizeChanged: { var v = rightColumn.settingsFontSize; config.settingsFontSize = v; settingsStore.set("settingsFontSize", v); }
                onSettingsTitleSizeChanged: { var v = rightColumn.settingsTitleSize; config.settingsTitleSize = v; settingsStore.set("settingsTitleSize", v); }
                onWelcomeFontSizeChanged: { var v = rightColumn.welcomeFontSize; config.welcomeFontSize = v; settingsStore.set("welcomeFontSize", v); }
                onFetchFontSizeChanged: { var v = rightColumn.fetchFontSize; config.fetchFontSize = v; settingsStore.set("fetchFontSize", v); }
                onButtonFontSizeChanged: { var v = rightColumn.buttonFontSize; config.buttonFontSize = v; settingsStore.set("buttonFontSize", v); }
                onDialogTitleSizeChanged: { var v = rightColumn.dialogTitleSize; config.dialogTitleSize = v; settingsStore.set("dialogTitleSize", v); }
                onDialogBodySizeChanged: { var v = rightColumn.dialogBodySize; config.dialogBodySize = v; settingsStore.set("dialogBodySize", v); }
                onQuoteFontSizeChanged: { var v = rightColumn.quoteFontSize; config.quoteFontSize = v; settingsStore.set("quoteFontSize", v); }
                onDropdownLabelSizeChanged: { var v = rightColumn.dropdownLabelSize; config.dropdownLabelSize = v; settingsStore.set("dropdownLabelSize", v); }
                onDropdownItemSizeChanged: { var v = rightColumn.dropdownItemSize; config.dropdownItemSize = v; settingsStore.set("dropdownItemSize", v); }
                onSettingsOpenChanged: { if (!rightColumn.settingsOpen) keylogger.forceActiveFocus(); }
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
            settingsStore.set("locale", localeManager.currentLocale);
        }
    }

    SettingsStore {
        id: settingsStore
    }

    UserPicker {
        id: userPicker
    }

    MouseArea {
        anchors.fill: parent
        visible: rightColumn.settingsOpen && !powerDialog.visible
        z: 50
        onClicked: {
            rightColumn.closeSettings();
            keylogger.forceActiveFocus();
        }
    }

    PowerDialog {
        id: powerDialog
        z: 200
        anchors.fill: parent
        animDuration: root.animDuration
        overlayOpacity: root.powerOverlayOpacity
        powerConfirmEnabled: root.powerConfirmEnabled
        onConfirmed: function(cmd) {
            if (cmd === "poweroff") sddm.powerOff();
            else if (cmd === "reboot") sddm.reboot();
        }
    }

    Connections {
        target: powerDialog
        function onVisibleChanged() {
            if (!powerDialog.visible) keylogger.forceActiveFocus();
        }
    }
}
