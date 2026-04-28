import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Window
import "components"
import "widgets"

Rectangle {
    id: root

    property bool ap: config.ap === "true" ? true : false
    property bool firstInput: true
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
    property bool mainCardBgBlur: config.mainCardBgBlur === "true"

    width: 1920
    height: 1080
    color: "#131313"
    onBufferChanged: {
        // ill make animations for typing
        return;
    }

    Connections {
        function onLoginFailed() {
            root.buffer = "";
            root.loading = false;
            inputRect.color = config.subComponents;
            inputBorders.color = config.subComponents;
            shakeRotation.start();
        }

        function onLoginSucceeded() {
            root.loading = false;
        }

        target: sddm
    }

    AnimatedImage {
        id: background

        anchors.fill: parent
        source: "assets/background"
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: {
            if (status === Image.Error)
                console.log("Background missing, using fallback color");
        }

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: firstInput ? 0 : 0.4

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing: Easing.InOutCubic
                }
            }
        }
    }

    Item {
        id: keylogger

        focus: true
        Keys.onPressed: {
            if (event.key === Qt.Key_Escape) {
                root.firstInput = true;
                root.buffer = "";
                return;
            }
            if (root.firstInput) {
                root.firstInput = false;
                return;
            }
            if (event.key === Qt.Key_Right) {
                if (userPicker.currentIndex < userModel.count - 1)
                    userPicker.currentIndex += 1;

                return;
            }
            if (event.key === Qt.Key_Left) {
                if (userPicker.currentIndex > 0)
                    userPicker.currentIndex -= 1;

                return;
            }
            if (event.key === Qt.Key_Up) {
                if (sessionPicker.currentIndex < sessionPicker.count - 1)
                    sessionPicker.currentIndex += 1;

                return;
            }
            if (event.key === Qt.Key_Down) {
                if (sessionPicker.currentIndex > 0)
                    sessionPicker.currentIndex -= 1;

                return;
            }
            if (event.key === Qt.Key_Backspace) {
                root.buffer = root.buffer.slice(0, -1);
                return;
            }
            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                sddm.login(userPicker.currentText, root.buffer, sessionPicker.currentIndex);
                root.loading = true;
                return;
            }
            root.buffer += event.text;
        }
    }

    MultiEffect {
        blurEnabled: true
        source: background
        blur: root.firstInput ? 0 : 1
        autoPaddingEnabled: false
        blurMultiplier: 1
        blurMax: 64
        anchors.fill: background

        Behavior on blur {
            NumberAnimation {
                duration: 400
                easing: Easing.InOutCubic
            }
        }
    }

    Greeting {
        anchors.centerIn: parent
        firstInput: root.firstInput
        mainCardRadius: mainCard.radius
        rootHeight: root.height
        rootWidth: root.width
        greetingText: greeting.welcomeString
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
        radius: 40
        color: "transparent"

        BlurWrapper {
            anchors.centerIn: parent
            targetWidth: mainCard.width
            targetHeight: mainCard.height
            animDuration: 0
            blurAmount: root.mainCardBlurAmount
            bgColor: config.mainCard
            visibleState: !root.firstInput
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 40

            ColumnLayout {
                spacing: 10
                Layout.alignment: Qt.AlignLeft

                Rectangle {
                    id: topLeftRect

                    width: 390
                    height: 180
                    color: config.subComponents
                    topLeftRadius: mainCard.radius / 1.9
                    radius: mainCard.radius / 4
                    opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity

                    WelcomeText {
                        id: greeting

                        anchors.centerIn: parent
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutBack
                        }
                    }
                }

                Rectangle {
                    id: middleLeftRect

                    width: 390
                    Layout.fillHeight: true
                    color: config.subComponents
                    radius: mainCard.radius / 4
                    opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity
                    clip: true

                    CaelestiaFetch {
                        firstInput: root.firstInput
                        currentUser: userPicker.currentText
                        currentSession: sessionPicker.currentText
                        rectHeight: middleLeftRect.height
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutBack
                        }
                    }
                }

                Rectangle {
                    id: bottomLeftRect

                    width: 390
                    height: 180
                    color: "transparent"
                    bottomLeftRadius: mainCard.radius / 1.9
                    radius: mainCard.radius / 4
                    opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity

                    SystemButtons {
                        anchors.horizontalCenter: parent.horizontalCenter
                        rectHeight: bottomLeftRect.height
                        rectRadius: bottomLeftRect.radius
                        rectBigRadius: mainCard.radius / 1.9
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutBack
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                spacing: 0

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    color: "transparent"
                    width: 300
                    height: 30
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10

                    MainClock {
                        Layout.alignment: Qt.AlignHCenter
                        firstInput: root.firstInput
                        mainCardComponentsOpacity: root.mainCardComponentsOpacity
                        ap: root.ap
                    }

                    Text {
                        renderType: Text.NativeRendering
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDate(new Date(), "dddd,   d  MMMM  yyyy")
                        font.pixelSize: 28
                        font.family: "Rubik"
                        font.bold: false
                        color: config.textDark
                        opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutBack
                            }
                        }
                    }
                }

                Item {
                    height: 80
                }

                Avatar {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 230
                    Layout.preferredHeight: 230
                    opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutBack
                        }
                    }
                }

                Item {
                    height: 40
                }

                PasswordInput {
                    mainCardComponentsOpacity: root.mainCardComponentsOpacity
                    firstInput: root.firstInput
                    isLoading: root.loading
                    buffer: root.buffer
                    currentUser: userPicker.currentText
                    currentSession: sessionPicker.currentIndex
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    color: "transparent"
                    width: 300
                    height: 60
                }
            }

            ColumnLayout {
                spacing: 10
                Layout.alignment: Qt.AlignRight

                Rectangle {
                    id: topRightRect

                    width: 390
                    height: 355
                    color: config.subComponents
                    topRightRadius: mainCard.radius / 1.9
                    radius: mainCard.radius / 4
                    opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity

                    RandomQuote {
                        maxWidth: topRightRect.width - 40
                        color: config.text
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutBack
                        }
                    }
                }

                Rectangle {
                    id: bottomRightRect

                    width: 390
                    height: 355
                    color: config.subComponents
                    bottomRightRadius: mainCard.radius / 1.9
                    radius: mainCard.radius / 4
                    opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity

                    Image {
                        id: dino

                        width: 300
                        height: 150
                        source: "assets/dino.png"
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectCrop
                        layer.enabled: true

                        layer.effect: ColorOverlay {
                            color: config.inverseOnSurface
                        }
                    }

                    Text {
                        renderType: Text.NativeRendering
                        text: "Login for notifications"
                        color: config.inverseOnSurface
                        font.family: "CaskaydiaCove NF"
                        font.pointSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 50
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutBack
                        }
                    }
                }
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutBack
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutBack
            }
        }
    }

    ComboBox {
        // invisible just for now
        id: userPicker

        width: 190
        height: 50
        anchors.right: parent.right
        anchors.top: parent.top
        model: userModel
        currentIndex: userModel.lastIndex
        textRole: "name"
        font.family: "Rubik"
        font.pixelSize: 20
        visible: false

        background: Rectangle {
            color: "#BF131313"
            radius: 30
            border.color: "#353535"
            border.width: 1
        }

        contentItem: Text {
            renderType: Text.NativeRendering
            text: userPicker.displayText
            font: userPicker.font
            color: "#e2e2e2"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            anchors.fill: parent
        }

        indicator: Canvas {
            x: userPicker.width - 30
            y: (userPicker.height - 6) / 2
            width: 12
            height: 6
            onPaint: {
                var context = getContext("2d");
                context.reset();
                context.moveTo(0, 0);
                context.lineTo(width, 0);
                context.lineTo(width / 2, height);
                context.closePath();
                context.fillStyle = "#4cdadb";
                context.fill();
            }
        }
    }

    ComboBox {
        // this is too, invisible right now
        id: sessionPicker

        width: 190
        height: 50
        model: sessionModel
        currentIndex: sessionModel.lastIndex
        textRole: "name"
        font.family: "Rubik"
        font.pixelSize: 18
        visible: false

        background: Rectangle {
            color: "#BF131313"
            radius: 20
            border.color: "#353535"
            border.width: 1
        }

        contentItem: Text {
            renderType: Text.NativeRendering
            text: sessionPicker.displayText
            font: sessionPicker.font
            color: "#e2e2e2"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            leftPadding: 0
            rightPadding: 0
            anchors.fill: parent
        }

        indicator: Canvas {
            id: canvas

            x: sessionPicker.width - 24
            y: (sessionPicker.height - 6) / 2
            width: 10
            height: 6
            onPaint: {
                var context = getContext("2d");
                context.reset();
                context.moveTo(0, 0);
                context.lineTo(width, 0);
                context.lineTo(width / 2, height);
                context.closePath();
                context.fillStyle = "#4cdadb";
                context.fill();
            }
        }
    }
}
