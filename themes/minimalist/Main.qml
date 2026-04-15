import Qt5Compat.GraphicalEffects
import QtQuick 2.15
import QtQuick.Effects
import "components"
import "singletons"

Rectangle {
    id: root

    property bool firstInput: true
    property string buffer: ""
    property var userName: {
        if (userModel.count > 0 && userModel.lastIndex >= 0) {
            var idx = userModel.index(userModel.lastIndex, 0);
            return userModel.data(idx, Qt.UserRole + 1);
        }
        return "";
    }

    function restoreFocus() {
        if (!keyHandler.activeFocus)
            keyHandler.forceActiveFocus();

    }

    function clearBuffer() {
        root.buffer = "";
    }

    width: 1920
    height: 1080
    color: Theme.mSurface

    Item {
        id: keyHandler

        focus: true
        Component.onCompleted: {
            keyHandler.forceActiveFocus();
        }
        Keys.onPressed: function(event) {
            if (root.firstInput) {
                loginCard.clearError();
                if (event.text && event.text !== "" && event.text.length === 1)
                    root.buffer = event.text;

                root.firstInput = false;
                return ;
            }
            if (event.key === Qt.Key_Escape) {
                root.firstInput = true;
                clearBuffer();
                return ;
            }
            if (event.key === Qt.Key_Right) {
                if (userModel.count > 0 && loginCard.userPicker.currentIndex < userModel.count - 1) {
                    loginCard.userPicker.currentIndex += 1;
                    clearBuffer();
                }
                return ;
            }
            if (event.key === Qt.Key_Left) {
                if (userModel.count > 0 && loginCard.userPicker.currentIndex > 0) {
                    loginCard.userPicker.currentIndex -= 1;
                    clearBuffer();
                }
                return ;
            }
            if (event.key === Qt.Key_Up) {
                if (sessionModel.count > 0 && loginCard.sessionPicker.currentIndex > 0)
                    loginCard.sessionPicker.currentIndex -= 1;

                return ;
            }
            if (event.key === Qt.Key_Down) {
                if (sessionModel.count > 0 && loginCard.sessionPicker.currentIndex < sessionModel.count - 1)
                    loginCard.sessionPicker.currentIndex += 1;

                return ;
            }
            if (event.key === Qt.Key_Backspace) {
                loginCard.clearError();
                root.buffer = root.buffer.slice(0, -1);
                return ;
            }
            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                loginCard.showAuthenticating();
                sddm.login(loginCard.userPicker.currentText, root.buffer, loginCard.sessionPicker.currentIndex);
                clearBuffer();
                return ;
            }
            if (event.text && event.text !== "" && event.text.length === 1) {
                // Clear error state when user starts typing after a failed attempt
                loginCard.clearError();
                root.buffer += event.text;
            }
            // DEBUG: Shift+F to simulate failed login (toggle via debugMode in theme.conf)
            if (Theme.debugMode && event.key === Qt.Key_F && (event.modifiers & Qt.ShiftModifier)) {
                loginCard.showError("Incorrect password");
                clearBuffer();
                return ;
            }
        }
    }

    Image {
        id: background

        property string src: Theme.backgroundSource
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
            color: Theme.mShadow
            opacity: firstInput ? 0 : Theme.overlayOpacity

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animDurationNormal
                }

            }

        }

    }

    MultiEffect {
        source: background
        anchors.fill: background
        blurEnabled: Theme.blurEnabled
        blur: firstInput ? 0 : Theme.blurStrength
        blurMax: 64
        blurMultiplier: 1
        autoPaddingEnabled: false

        Behavior on blur {
            NumberAnimation {
                duration: Theme.animDurationSlow
            }

        }

    }

    WelcomeHeading {
        userName: root.userName
        isActive: root.firstInput
    }

    LoginCard {
        id: loginCard

        anchors.centerIn: parent
        isActive: root.firstInput
        usersModel: userModel
        sessionsModel: sessionModel
        buffer: root.buffer
        onRestoreFocus: restoreFocus
        onLogin: function() {
            loginCard.showAuthenticating();
            sddm.login(loginCard.userPicker.currentText, root.buffer, loginCard.sessionPicker.currentIndex);
            clearBuffer();
            restoreFocus();
        }
    }

    Connections {
        function onLoginFailed() {
            loginCard.clearAuthenticating();
            loginCard.showError("Incorrect password");
            clearBuffer();
            restoreFocus();
        }

        function onLoginSucceeded() {
            loginCard.clearAuthenticating();
            loginCard.clearError();
        }

        target: sddm
    }

    Text {
        renderType: Text.NativeRendering
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        font.family: Theme.fontFamily
        font.pixelSize: Math.round(Theme.baseFontSize * 1.8)
        font.italic: true
        opacity: root.firstInput ? 1 : 0
        color: Theme.mOnSurfaceVariant
        text: "Press any key to login"

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animDurationNormal
                easing.type: Easing.OutCubic
            }

        }

    }

}
