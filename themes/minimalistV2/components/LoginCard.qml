import "../singletons"
import Qt5Compat.GraphicalEffects
import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property bool isActive: true
    property var usersModel: null
    property var sessionsModel: null
    property string buffer: ""
    property var onRestoreFocus: null
    property var onLogin: null
    property alias userPicker: userPicker
    property alias sessionPicker: sessionPicker
    property bool isError: false
    property bool isAuthenticating: false

    function showError(msg) {
        root.isError = true;
        root.isAuthenticating = false;
        toast.show(msg);
    }

    function clearError() {
        root.isError = false;
    }

    function showAuthenticating() {
        root.isAuthenticating = true;
    }

    function clearAuthenticating() {
        root.isAuthenticating = false;
    }

    enabled: !isActive
    implicitWidth: 550
    implicitHeight: 830
    scale: isActive ? 0.5 : 1
    opacity: isActive ? 0 : 1

    Rectangle {
        id: cardBorder

        anchors.fill: mainCard
        anchors.margins: Theme.cardBorder ? -2 : 0
        radius: Theme.cardRadius + (Theme.cardBorder ? 2 : 0)
        color: "transparent"
        border.color: Theme.mHover
        border.width: Theme.cardBorder ? 2 : 0
        z: -1
    }

    DropShadow {
        anchors.fill: mainCard
        horizontalOffset: 0
        verticalOffset: 4
        radius: Theme.shadowRadius
        samples: Theme.shadowSamples
        spread: 0.05
        color: Theme.withAlpha(Theme.mShadow, 0.25)
        source: mainCard
        visible: Theme.dropShadows
        transparentBorder: true
    }

    Rectangle {
        id: mainCard

        anchors.fill: parent
        radius: Theme.cardRadius
        color: Theme.withAlpha(Theme.mSurface, Theme.cardOpacity)

        Rectangle {
            anchors.fill: parent
            anchors.margins: 16
            radius: Theme.cardRadius - 16
            color: Theme.withAlpha(Theme.mOnSecondary, Theme.cardOpacity * 1.55)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 40
                spacing: 30

                Clock {
                    Layout.alignment: Qt.AlignHCenter
                }

                Avatar {
                    id: avatar

                    Layout.alignment: Qt.AlignHCenter
                    userPicker: root.userPicker
                    userModel: root.usersModel
                }

                StyledComboBox {
                    id: userPicker

                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 380
                    Layout.preferredHeight: 55
                    model: root.usersModel
                    currentIndex: {
                        if (!root.usersModel || root.usersModel.count <= 0)
                            return -1;

                        var idx = root.usersModel.lastIndex;
                        return idx >= 0 && idx < root.usersModel.count ? idx : 0;
                    }
                    textRole: "name"
                    font.family: Theme.fontFamily
                    font.pixelSize: Math.round(Theme.baseFontSize * 1.67)
                    onRestoreFocus: root.onRestoreFocus
                }

                PasswordInput {
                    id: passwordInput

                    Layout.alignment: Qt.AlignHCenter
                    buffer: root.buffer
                    isError: root.isError
                    isAuthenticating: root.isAuthenticating
                    onRestoreFocus: root.onRestoreFocus
                    onLogin: root.onLogin
                }

                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    PowerButton {
                        id: shutBtn

                        width: 70
                        height: 70
                        iconText: "\ue8ac"
                        normalColor: Theme.mOnSurface
                        hoverColor: Theme.mError
                        onRestoreFocus: root.onRestoreFocus
                        onClickedAction: function() {
                            sddm.powerOff();
                        }
                    }

                    PowerButton {
                        id: rebBtn

                        width: 70
                        height: 70
                        iconText: "\uf053"
                        normalColor: Theme.mOnSurface
                        hoverColor: Theme.mHover
                        onRestoreFocus: root.onRestoreFocus
                        onClickedAction: function() {
                            sddm.reboot();
                        }
                    }

                }

                StyledComboBox {
                    id: sessionPicker

                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 380
                    Layout.preferredHeight: 55
                    model: root.sessionsModel
                    currentIndex: {
                        if (!root.sessionsModel || root.sessionsModel.count <= 0)
                            return -1;

                        var idx = root.sessionsModel.lastIndex;
                        return idx >= 0 && idx < root.sessionsModel.count ? idx : 0;
                    }
                    textRole: "name"
                    font.family: Theme.fontFamily
                    font.pixelSize: Math.round(Theme.baseFontSize * 1.5)
                    onRestoreFocus: root.onRestoreFocus
                }

            }

        }

    }

    ToastMessage {
        id: toast

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: -16
        onDismissed: root.clearError()
    }

    Behavior on scale {
        NumberAnimation {
            duration: Theme.animDurationNormal
            easing.type: Easing.OutBack
        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.animDurationNormal
            easing.type: Easing.OutBack
        }

    }

}
