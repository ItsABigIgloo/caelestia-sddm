import QtQuick

Item {
    id: localeManager

    property string currentLocale: "en"
    property var availableLocales: []
    property var _englishStrings: ({
    })

    signal languageChanged()

    function loadIndex(callback) {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", Qt.resolvedUrl("../locales/index.json"));
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    availableLocales = data.locales || [];
                } catch (e) {
                    availableLocales = [{
                        "code": "en",
                        "name": "English",
                        "nativeName": "English"
                    }];
                }
                if (callback)
                    callback();

            }
        };
        xhr.send();
    }

    function detectSystemLocale() {
        var name = Qt.locale().name;
        if (name === "C" || name === "POSIX" || name === "") {
            var ui = Qt.locale().uiLanguages;
            if (ui.length > 0) {
                var parts = ui[0].split(/[-_]/);
                name = parts[0];
            } else {
                return "en";
            }
        }
        var parts = name.split("_");
        return parts[0] ? parts[0].toLowerCase() : "en";
    }

    function applyStrings(data) {
        if (data.greetingMorning !== undefined)
            config.greetingMorning = data.greetingMorning;

        if (data.greetingAfternoon !== undefined)
            config.greetingAfternoon = data.greetingAfternoon;

        if (data.greetingNight !== undefined)
            config.greetingNight = data.greetingNight;

        if (data.passwordPlaceholder !== undefined)
            config.passwordPlaceholder = data.passwordPlaceholder;

        if (data.loadingText !== undefined)
            config.loadingText = data.loadingText;

        if (data.fetchTitle !== undefined)
            config.fetchTitle = data.fetchTitle;

        if (data.fetchLabels !== undefined)
            config.fetchLabels = data.fetchLabels;

        if (data.capsLockWarning !== undefined)
            config.capsLockWarning = data.capsLockWarning;

        if (data.unlockForNotifications !== undefined)
            config.unlockForNotifications = data.unlockForNotifications;

        if (data.settingsTitle !== undefined)
            config.settingsTitle = data.settingsTitle;

        if (data.animationSpeed !== undefined)
            config.animationSpeed = data.animationSpeed;

        if (data.syncDelay !== undefined)
            config.syncDelay = data.syncDelay;

        if (data.backgroundBlur !== undefined)
            config.backgroundBlur = data.backgroundBlur;

        if (data.language !== undefined)
            config.language = data.language;

        if (data.close !== undefined)
            config.close = data.close;

        if (data.shutdown !== undefined)
            config.shutdown = data.shutdown;

        if (data.reboot !== undefined)
            config.reboot = data.reboot;

        if (data.cancel !== undefined)
            config.cancel = data.cancel;

        if (data.confirmTitle !== undefined)
            config.confirmTitle = data.confirmTitle;

        if (data.confirmShutdown !== undefined)
            config.confirmShutdown = data.confirmShutdown;

        if (data.confirmReboot !== undefined)
            config.confirmReboot = data.confirmReboot;

        if (data.overlayDarkness !== undefined)
            config.overlayDarkness = data.overlayDarkness;

        if (data.powerDialogBlur !== undefined)
            config.powerDialogBlur = data.powerDialogBlur;

        if (data.welcomeMessageLabel !== undefined)
            config.welcomeMessageLabel = data.welcomeMessageLabel;

        if (data.cardBlurLabel !== undefined)
            config.cardBlurLabel = data.cardBlurLabel;

        if (data.cardOpacityLabel !== undefined)
            config.cardOpacityLabel = data.cardOpacityLabel;

        if (data.cardColorOpacityLabel !== undefined)
            config.cardColorOpacityLabel = data.cardColorOpacityLabel;

        if (data.welcomeBgBlurLabel !== undefined)
            config.welcomeBgBlurLabel = data.welcomeBgBlurLabel;

        if (data.welcomeColorOpacityLabel !== undefined)
            config.welcomeColorOpacityLabel = data.welcomeColorOpacityLabel;

        if (data.apLabel !== undefined)
            config.apLabel = data.apLabel;

        if (data.sessionPickerLabel !== undefined)
            config.sessionPickerLabel = data.sessionPickerLabel;

        if (data.powerConfirmLabel !== undefined)
            config.powerConfirmLabel = data.powerConfirmLabel;

        if (data.cardBlurToggleLabel !== undefined)
            config.cardBlurToggleLabel = data.cardBlurToggleLabel;

        if (data.avatarShapeLabel !== undefined)
            config.avatarShapeLabel = data.avatarShapeLabel;

        if (data.hexagonLabel !== undefined)
            config.hexagonLabel = data.hexagonLabel;

        if (data.circleLabel !== undefined)
            config.circleLabel = data.circleLabel;

        if (data.fontSizeLabel !== undefined)
            config.fontSizeLabel = data.fontSizeLabel;

        if (data.settingsFontSizeLabel !== undefined)
            config.settingsFontSizeLabel = data.settingsFontSizeLabel;

        if (data.settingsTitleSizeLabel !== undefined)
            config.settingsTitleSizeLabel = data.settingsTitleSizeLabel;

    }

    function loadLocale(code) {
        var xhrEn = new XMLHttpRequest();
        xhrEn.open("GET", Qt.resolvedUrl("../locales/en.json"));
        xhrEn.onreadystatechange = function() {
            if (xhrEn.readyState === XMLHttpRequest.DONE) {
                try {
                    _englishStrings = JSON.parse(xhrEn.responseText);
                } catch (e) {
                    _englishStrings = {
                    };
                }
                if (code === "en") {
                    applyStrings(_englishStrings);
                    currentLocale = "en";
                    languageChanged();
                    return ;
                }
                var xhrLocale = new XMLHttpRequest();
                xhrLocale.open("GET", Qt.resolvedUrl("../locales/" + code + ".json"));
                xhrLocale.onreadystatechange = function() {
                    if (xhrLocale.readyState === XMLHttpRequest.DONE) {
                        try {
                            var localeData = JSON.parse(xhrLocale.responseText);
                            var merged = JSON.parse(JSON.stringify(_englishStrings));
                            for (var k in localeData) merged[k] = localeData[k]
                            applyStrings(merged);
                            currentLocale = code;
                        } catch (e) {
                            applyStrings(_englishStrings);
                            currentLocale = "en";
                        }
                        languageChanged();
                    }
                };
                xhrLocale.send();
            }
        };
        xhrEn.send();
    }

    function switchLanguage(code) {
        loadLocale(code);
    }

    Component.onCompleted: {
        loadIndex(function() {
            var sysLang = detectSystemLocale();
            var found = false;
            for (var i = 0; i < availableLocales.length; i++) {
                if (availableLocales[i].code === sysLang) {
                    found = true;
                    break;
                }
            }
            loadLocale(found ? sysLang : "en");
        });
    }
}
