import QtQuick 2.15
pragma Singleton

QtObject {
    id: theme

    property bool configAvailable: false
    property string backgroundSource: {
        if (configAvailable && config.background) {
            var source = config.background.toString().trim();
            if (source && source !== "")
                return source;

        }
        return "assets/background.png";
    }
    property string fontFamily: {
        var availableFonts = Qt.fontFamilies();
        var family = "";
        if (configAvailable && config.fontFamily)
            family = config.fontFamily;

        if (family && family !== "") {
            family = family.toString().replace(/^"|"$/g, "");
            if (availableFonts.indexOf(family) !== -1)
                return family;

        }
        return firstAvailable(["Rubik", "Sans"]);
    }
    property real baseFontSize: boundedNumber(getConfig("FontSize"), 12, 10, 24)
    property real avatarBaseSize: boundedNumber(getConfig("AvatarSize"), 128, 64, 320)
    property real avatarFrameSize: Math.max(96, Math.round(avatarBaseSize * 1.72))
    property real avatarInset: Math.max(8, Math.round(avatarFrameSize * 0.09))
    property real buttonRadius: boundedNumber(getConfig("buttonRadius"), 20, 0, 64)
    property real passwordInputRadius: boundedNumber(getConfig("passwordInputRadius"), 20, 0, 64)
    property real cardRadius: boundedNumber(getConfig("cardRadius"), 30, 0, 80)
    property color mPrimary: getConfig("mPrimary") || "#4cdadb"
    property color mOnPrimary: getConfig("mOnPrimary") || "#002022"
    property color mSecondary: getConfig("mSecondary") || "#95f4f5"
    property color mOnSecondary: getConfig("mOnSecondary") || "#003738"
    property color mTertiary: getConfig("mTertiary") || "#86d0ff"
    property color mOnTertiary: getConfig("mOnTertiary") || "#00344d"
    property color mError: getConfig("mError") || "#ffb4ab"
    property color mOnError: getConfig("mOnError") || "#690005"
    property color mSurface: getConfig("mSurface") || "#131313"
    property color mOnSurface: getConfig("mOnSurface") || "#e2e2e2"
    property color mSurfaceVariant: getConfig("mSurfaceVariant") || "#353535"
    property color mOnSurfaceVariant: getConfig("mOnSurfaceVariant") || "#919191"
    property color mOutline: getConfig("mOutline") || "#7d7d7d"
    property color mShadow: getConfig("mShadow") || "#000000"
    property color mHover: getConfig("mHover") || mPrimary
    property color mOnHover: getConfig("mOnHover") || mOnPrimary
    property bool dropShadows: toBool(getConfig("dropShadows"), true)
    property bool blurEnabled: toBool(getConfig("blurEnabled"), true)
    property real blurStrength: boundedNumber(getConfig("blurStrength"), 1, 0, 1)
    property real cardOpacity: boundedNumber(getConfig("cardOpacity"), 0.95, 0, 1)
    property real overlayOpacity: boundedNumber(getConfig("overlayOpacity"), 0.4, 0, 1)
    property int animDurationFast: 200
    property int animDurationNormal: 300
    property int animDurationSlow: 400
    property int shadowRadius: 16
    property int shadowSamples: 32

    function getConfig(key) {
        if (!configAvailable)
            return undefined;

        var value = config[key];
        return value !== undefined ? value : undefined;
    }

    function firstAvailable(candidates) {
        var availableFonts = Qt.fontFamilies();
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

    Component.onCompleted: {
        configAvailable = (typeof config !== 'undefined');
    }
}
