import QtQuick

Item {
    id: root

    property bool expanded: dropdown._open
    property int count: sessionModel ? sessionModel.count : 0
    property var items: []
    property int selectedIndex: 0
    property string currentText

    width: dropdown.width; height: dropdown.height
    opacity: root.count > 0 ? 1 : 0
    enabled: root.count > 0

    Instantiator {
        id: sessionArray
        model: sessionModel
        property var sessions: []

        delegate: Item {
            Component.onCompleted: {
                sessionArray.sessions.push({
                    index: index,
                    name: model.name
                });
            }
        }
    }

    Component.onCompleted: {
        root.currentText = sessionArray.sessions[root.selectedIndex].name;
        var arr = [];
        for (var i = 0; i < sessionArray.sessions.length; i++) {
            arr.push(sessionArray.sessions[i].name);
        }
        root.items = arr;
        dropdown.model = arr;
        dropdown.currentIndex = root.selectedIndex;
        dropdown.displayText = root.currentText;
    }

    onSelectedIndexChanged: {
        root.currentText = sessionArray.sessions[root.selectedIndex].name;
        dropdown.currentIndex = root.selectedIndex;
        dropdown.displayText = root.currentText;
    }

    DropdownStyle {
        id: dropdown
        iconChar: "widgets"
        onActivated: function(index) {
            root.selectedIndex = index;
            root.currentText = root.items[index];
        }
    }
}
