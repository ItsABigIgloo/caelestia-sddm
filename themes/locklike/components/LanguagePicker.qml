import "."
import QtQuick

Item {
    id: root

    property var localeManager: null
    property bool expanded: dropdown._open
    property int animDuration: 200

    width: 260
    height: 40

    DropdownStyle {
        id: dropdown

        animDuration: root.animDuration
        model: root.localeManager.availableLocales.map(function(l) {
            return l.nativeName;
        })
        iconChar: "language"
        Component.onCompleted: {
            for (var i = 0; i < root.localeManager.availableLocales.length; i++) {
                if (root.localeManager.availableLocales[i].code === root.localeManager.currentLocale) {
                    currentIndex = i;
                    break;
                }
            }
        }
        displayText: {
            var idx = currentIndex;
            if (idx >= 0 && idx < root.localeManager.availableLocales.length)
                return root.localeManager.availableLocales[idx].nativeName;

            return "";
        }
        onActivated: function(index) {
            root.localeManager.switchLanguage(root.localeManager.availableLocales[index].code);
        }
    }

}
