import QtQuick

Item {
    id: root

    property bool welcomeEnabled: false
    property bool powerDialogVisible: false
    property bool settingsOpen: false
    property bool firstInputActive: false

    signal escapePressed()
    signal settingsCloseRequested()
    signal welcomeResetRequested()
    signal firstInputDismissed()
    signal capsLockToggled()
    signal rightPressed()
    signal leftPressed()
    signal upPressed()
    signal downPressed()
    signal backspacePressed()
    signal enterPressed()
    signal charEntered(string text)

    focus: true

    Keys.onPressed: {
        if (event.key === Qt.Key_Escape) {
            if (root.settingsOpen) { root.settingsCloseRequested(); event.accepted = true; return; }
            if (root.welcomeEnabled) root.welcomeResetRequested();
            root.escapePressed();
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_CapsLock) {
            root.capsLockToggled();
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Tab) { event.accepted = true; return; }
        if (root.firstInputActive) {
            root.firstInputDismissed();
            return;
        }
        if (event.key === Qt.Key_Right) { root.rightPressed(); event.accepted = true; return; }
        if (event.key === Qt.Key_Left) { root.leftPressed(); event.accepted = true; return; }
        if (event.key === Qt.Key_Up) { root.upPressed(); event.accepted = true; return; }
        if (event.key === Qt.Key_Down) { root.downPressed(); event.accepted = true; return; }
        if (event.key === Qt.Key_Backspace) { root.backspacePressed(); return; }
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            root.enterPressed();
            event.accepted = true;
            return;
        }
        root.charEntered(event.text);
    }
}
