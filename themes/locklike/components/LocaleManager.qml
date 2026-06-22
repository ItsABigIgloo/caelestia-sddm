import QtQuick

Item {
    id: localeManager

    property string currentLocale: "en"
    property var availableLocales: []
    property var _englishStrings: ({})

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
                    availableLocales = [{code: "en", name: "English", nativeName: "English"}];
                }
                if (callback) callback();
            }
        };
        xhr.send();
    }

    function detectSystemLocale() {
        var parts = Qt.locale().name.split("_");
        return parts[0] || "en";
    }

    function applyStrings(data) {
        if (data.greetingMorning !== undefined) config.greetingMorning = data.greetingMorning;
        if (data.greetingAfternoon !== undefined) config.greetingAfternoon = data.greetingAfternoon;
        if (data.greetingNight !== undefined) config.greetingNight = data.greetingNight;
        if (data.passwordPlaceholder !== undefined) config.passwordPlaceholder = data.passwordPlaceholder;
        if (data.loadingText !== undefined) config.loadingText = data.loadingText;
        if (data.fetchTitle !== undefined) config.fetchTitle = data.fetchTitle;
        if (data.fetchLabels !== undefined) config.fetchLabels = data.fetchLabels;
        if (data.capsLockWarning !== undefined) config.capsLockWarning = data.capsLockWarning;
        if (data.unlockForNotifications !== undefined) config.unlockForNotifications = data.unlockForNotifications;
        if (data.settingsTitle !== undefined) config.settingsTitle = data.settingsTitle;
        if (data.animationSpeed !== undefined) config.animationSpeed = data.animationSpeed;
        if (data.syncDelay !== undefined) config.syncDelay = data.syncDelay;
        if (data.backgroundBlur !== undefined) config.backgroundBlur = data.backgroundBlur;
        if (data.language !== undefined) config.language = data.language;
        if (data.close !== undefined) config.close = data.close;
    }

    function loadLocale(code) {
        var xhrEn = new XMLHttpRequest();
        xhrEn.open("GET", Qt.resolvedUrl("../locales/en.json"));
        xhrEn.onreadystatechange = function() {
            if (xhrEn.readyState === XMLHttpRequest.DONE) {
                try {
                    _englishStrings = JSON.parse(xhrEn.responseText);
                } catch (e) {
                    _englishStrings = {};
                }

                if (code === "en") {
                    applyStrings(_englishStrings);
                    currentLocale = "en";
                    languageChanged();
                    return;
                }

                var xhrLocale = new XMLHttpRequest();
                xhrLocale.open("GET", Qt.resolvedUrl("../locales/" + code + ".json"));
                xhrLocale.onreadystatechange = function() {
                    if (xhrLocale.readyState === XMLHttpRequest.DONE) {
                        try {
                            var localeData = JSON.parse(xhrLocale.responseText);
                            var merged = JSON.parse(JSON.stringify(_englishStrings));
                            for (var k in localeData)
                                merged[k] = localeData[k];
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
