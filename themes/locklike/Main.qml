import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import "components"

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#131313"

    property bool ap: config.ap === "true" ? true : false
    property bool firstInput: true
    property bool loading: false
    property string buffer

    onBufferChanged: {
        // ill make animations for typing
        return;
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.buffer = "";
            root.loading = false;
            shakeRotation.start();
        }
        function onLoginSucceeded() {
            root.loading = false;
        }
    }

    AnimatedImage {
        id: background
        anchors.fill: parent
        source: "assets/background"
        fillMode: Image.PreserveAspectCrop

        onStatusChanged: {
            if (status === Image.Error) {
                console.log("Background missing, using fallback color");
            }
        }
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: firstInput ? 0.0 : 0.4
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing: Easing.InOutCubic
                }
            }
        }

        Rectangle {
            id: welcomeTextRect
            width: welcomeText.width + 50
            height: welcomeText.height + 30
            color: config.background
            anchors.centerIn: parent
            radius: mainCard.radius
            layer.enabled: true
                layer.effect: DropShadow {
                color: Qt.rgba(parseInt(config.background.substring(1, 3), 16) / 255, parseInt(config.background.substring(3, 5), 16) / 255, parseInt(config.background.substring(5, 7), 16) / 255, 0.5)
                horizontalOffset: 0
                verticalOffset: 0
                radius: 16
                scale: 1.5
            }
            Text {
                id: welcomeText
                renderType: Text.NativeRendering
                text: "<span style='color:" + config.text + ";'>" + topLeftRect.welcomeString + " " + "</span>" + "<span style='color:" + config.primary + ";'>" + userPicker.displayText + "</span>"
                textFormat: Text.RichText
                font.pointSize: 70
                font.family: "Roboto"
                color: config.text
                opacity: root.firstInput ? 1 : 0
                anchors.centerIn: parent
                layer.enabled: true
                layer.effect: DropShadow {
                    color: Qt.rgba(parseInt(config.background.substring(1, 3), 16) / 255, parseInt(config.background.substring(3, 5), 16) / 255, parseInt(config.background.substring(5, 7), 16) / 255, 0.5)
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: 16
                    scale: 1.5
                }
            }
            PropertyAnimation {
                target: welcomeTextRect
                property: "scale"
                from: 0.1
                to: 1
                duration: 600
                easing.type: Easing.OutBack
                running: root.firstInput ? true : false
            }
        }
        Text {
            renderType: Text.NativeRendering
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            font.family: "Rubik"
            font.pointSize: 15
            font.italic: true
            opacity: root.firstInput ? 1.0 : 0.0
            color: config.text
            text: "Press a key on your Keyboard to login"

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
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
                if (userPicker.currentIndex < userModel.count - 1) {
                    userPicker.currentIndex += 1;
                }
                return;
            }
            if (event.key === Qt.Key_Left) {
                if (userPicker.currentIndex > 0) {
                    userPicker.currentIndex -= 1;
                }
                return;
            }

            if (event.key === Qt.Key_Up) {
                if (sessionPicker.currentIndex < sessionPicker.count - 1) {
                    sessionPicker.currentIndex += 1;
                }
                return;
            }
            if (event.key === Qt.Key_Down) {
                if (sessionPicker.currentIndex > 0) {
                    sessionPicker.currentIndex -= 1;
                }
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
        blur: root.firstInput ? 0 : 1.0
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

    Rectangle {
        id: mainCard
        width: 1350
        height: 750
        scale: firstInput ? 0.5 : 1.0
        opacity: firstInput ? 0.0 : 1.0
        anchors.centerIn: parent
        radius: 40
        color: config.mainCard

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
                    property string welcomeString

                    function getPhase() {
                        var now = new Date();
                        var hour = now.getHours();

                        if (hour >= 20 || hour < 4) {
                            welcomeString = "Good night";
                        } else if (hour >= 4 && hour < 10) {
                            welcomeString = "Good morning";
                        } else {
                            welcomeString = "Good day";
                        }
                    }
                    Text {
                        renderType: Text.NativeRendering
                        width: topLeftRect.width - 40

                        text: "<span style='color:" + config.text + ";'>" + topLeftRect.welcomeString + " </span>" + "<span style='color:" + config.primary + ";'>" + userPicker.displayText + "</span>"

                        textFormat: Text.RichText

                        anchors.centerIn: parent
                        font.family: "Rubik"
                        font.bold: false
                        font.pixelSize: 40
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Timer {
                        interval: 60000
                        running: true
                        onTriggered: topLeftRect.getPhase()
                        repeat: true
                    }
                    Component.onCompleted: getPhase()
                }

                Rectangle {
                    id: middleLeftRect
                    width: 390
                    Layout.fillHeight: true
                    color: config.subComponents
                    radius: mainCard.radius / 4
                    clip: true
                    RowLayout {
                        Rectangle {
                            width: 30
                            height: 40
                            radius: 12
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: 30
                            anchors.topMargin: 20
                            color: config.primary
                            Text {
                                renderType: Text.NativeRendering
                                anchors.centerIn: parent
                                color: "#111111"
                                text: ">"
                                font.family: "CaskaydiaCove NF"
                                font.pointSize: 15
                            }
                        }
                        Text {
                            renderType: Text.NativeRendering
                            color: config.text
                            text: "caelestiafetch.sh"
                            font.family: "CaskaydiaCove NF"
                            font.pointSize: 13
                            Layout.leftMargin: 35
                            Layout.topMargin: 29
                        }
                    }
                    ColumnLayout {
                        Item{
                            width:30
                            height: 60
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            Logo {
                                skipIntroAnimation: root.firstInput
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                                Layout.leftMargin: 25
                                Layout.topMargin: 50
                                Layout.preferredWidth: 130
                                Layout.preferredHeight: 130
                            }
                            RowLayout {
                                spacing: 10
                                Text {
                                    renderType: Text.NativeRendering
                                    Layout.leftMargin: 12
                                    Layout.topMargin: middleLeftRect.height / 10
                                    text: "WM     :\nUSER   :\nUP     :\nBATTERY:"
                                    color: config.text
                                    font.pixelSize: 18
                                    font.family: "CaskaydiaCove NF"
                                    lineHeight: 30
                                    lineHeightMode: Text.FixedHeight
                                    Layout.preferredWidth: 80
                                }
                                Text {
                                    renderType: Text.NativeRendering
                                    property string displayText: sessionPicker.currentText.split(" ")[0] // idk if i want it like that, but i dont know DEs that have more than one word as a name, that avoids something like that "Plasma (Wayland)"
                                    Layout.leftMargin: 0
                                    Layout.topMargin: middleLeftRect.height / 10
                                    text: displayText + "\n" + userPicker.currentText + "\n" + "WIP" + "\n" + "WIP"
                                    color: config.text
                                    font.pixelSize: 18
                                    font.family: "CaskaydiaCove NF"
                                    lineHeight: 30
                                    lineHeightMode: Text.FixedHeight
                                    Layout.preferredWidth: 100
                                }
                            }
                        }
                        RowLayout {
                            spacing: 20
                            Layout.alignment: Qt.AlignHCenter
                            Layout.leftMargin: 30
                            Layout.topMargin: 20
                            Rectangle {
                                width: 30
                                height: 30
                                color: config.background
                                radius: 12
                            }
                            Rectangle {
                                width: 30
                                height: 30
                                color: config.primary
                                radius: 12
                            }
                            Rectangle {
                                width: 30
                                height: 30
                                color: config.text
                                radius: 12
                            }
                            Rectangle {
                                width: 30
                                height: 30
                                color: config.textDark
                                radius: 12
                            }
                            Rectangle {
                                width: 30
                                height: 30
                                color: config.secondary
                                radius: 12
                            }
                            Rectangle {
                                width: 30
                                height: 30
                                color: config.onSuccess
                                radius: 12
                            }
                            Rectangle {
                                width: 30
                                height: 30
                                color: config.inverseOnSurface
                                radius: 12
                            }
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
                    Rectangle {
                        id: powerBtn
                        anchors.left: parent.left
                        anchors.top: parent.top
                        height: bottomLeftRect.height
                        width: bottomLeftRect.height + 10
                        radius: bottomLeftRect.radius
                        bottomLeftRadius: mainCard.radius / 1.9
                        color: config.subComponents
                        clip: true
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                        MaterialIcon {
                            id: powerIcon
                            property bool hovered: false
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: 50
                            anchors.topMargin: 30
                            text: "\ue8ac"
                            color: config.primary
                            pointSize: 70
                        }
                        LayerState {
                            anchors.fill: parent

                            onClicked: {
                                sddm.poweroff();
                            }
                        }
                    }

                    Rectangle {
                        id: rebootBtn
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: bottomLeftRect.height
                        width: bottomLeftRect.height + 10
                        radius: bottomLeftRect.radius
                        color: config.subComponents
                        clip: true
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                        MaterialIcon {
                            id: restartIcon
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: 47
                            anchors.topMargin: 30
                            text: "\ue863"
                            color: config.secondary
                            pointSize: 70
                        }
                        LayerState {
                            anchors.fill: parent

                            onClicked: {
                                sddm.reboot();
                            }
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
                    height: 45
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10
                    Text {
                        id: clock
                        Layout.alignment: Qt.AlignHCenter
                        textFormat: Text.RichText
                        text: {
                            var time = ap ? Qt.formatTime(new Date(), "hh:mm AP") : Qt.formatTime(new Date(), "hh:mm");

                            return time.replace(":", "<span style='color:" + config.primary + "'>:</span>");
                        }
                        font.pixelSize: 84
                        font.family: "Rubik"
                        font.bold: true
                        color: config.secondary
                    }
                    Text {
                        renderType: Text.NativeRendering
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDate(new Date(), "dddd,   d  MMMM  yyyy")
                        font.pixelSize: 28
                        font.family: "Rubik"
                        font.bold: false
                        color: config.textDark
                    }
                }

                Item {
                    height: 80
                }

                Avatar {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 230
                    Layout.preferredHeight: 230
                }

                Item {
                    height: 40
                }

                Rectangle {
                    id: inputRect
                    Layout.alignment: Qt.AlignHCenter
                    color: config.subComponents
                    radius: 30
                    width: 340
                    height: 40
                    Text {
                        renderType: Text.NativeRendering
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 17
                        font.family: "Material Symbols Rounded"
                        font.pointSize: 15
                        text: "\ue897"
                        color: '#a8a8a8'
                        Behavior on opacity {
                            ColorAnimation {
                                duration: 100
                            }
                        }
                    }
                    SequentialAnimation {
                        id: shakeRotation
                        running: false

                        NumberAnimation {
                            target: inputRect
                            property: "rotation"
                            to: -6
                            duration: 50
                        }
                        NumberAnimation {
                            target: inputRect
                            property: "rotation"
                            to: 6
                            duration: 50
                        }
                        NumberAnimation {
                            target: inputRect
                            property: "rotation"
                            to: -4
                            duration: 50
                        }
                        NumberAnimation {
                            target: inputRect
                            property: "rotation"
                            to: 4
                            duration: 50
                        }
                        NumberAnimation {
                            target: inputRect
                            property: "rotation"
                            to: -2
                            duration: 50
                        }
                        NumberAnimation {
                            target: inputRect
                            property: "rotation"
                            to: 2
                            duration: 50
                        }
                        NumberAnimation {
                            target: inputRect
                            property: "rotation"
                            to: 0
                            duration: 50
                        }
                    }

                    SequentialAnimation {
                        id: pulseColorRect1
                        loops: Animation.Infinite
                        running: root.loading

                        ColorAnimation {
                            target: inputRect
                            property: "color"
                            to: config.inverseOnSurface
                            duration: 350
                        }
                        ColorAnimation {
                            target: inputRect
                            property: "color"
                            to: config.subComponents
                            duration: 350
                        }
                    }

                    SequentialAnimation {
                        id: pulseColorRect2
                        loops: Animation.Infinite
                        running: root.loading

                        ColorAnimation {
                            target: inputBorders
                            property: "color"
                            to: config.inverseOnSurface
                            duration: 350
                        }
                        ColorAnimation {
                            target: inputBorders
                            property: "color"
                            to: config.subComponents
                            duration: 350
                        }
                    }

                    Rectangle {
                        id: inputBorders
                        anchors.centerIn: parent
                        color: config.subComponents
                        radius: 30
                        width: 250
                        height: 40
                        clip: true
                        Text {
                            renderType: Text.NativeRendering
                            anchors.centerIn: parent
                            font.pointSize: 12
                            text: "Enter your password"
                            color: '#6e6e6e'
                            font.family: "CaskaydiaCove NF"
                            opacity: root.buffer === "" ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 100
                                }
                            }
                        }
                        RowLayout {
                            anchors.centerIn: parent
                            Repeater {
                                id: characters
                                model: root.buffer.length
                                delegate: Rectangle {
                                    radius: 30
                                    width: 12
                                    height: 12
                                    color: config.text
                                }
                            }
                            Rectangle {
                                id: textIndicator
                                property bool invisible: true
                                visible: root.buffer === "" ? false : true
                                width: 1
                                height: 21
                                color: config.text
                                opacity: invisible ? 0 : 1
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 200
                                    }
                                }
                                Timer {
                                    running: true
                                    repeat: true
                                    interval: 500
                                    onTriggered: textIndicator.invisible = !textIndicator.invisible
                                }
                            }
                        }
                    }
                    Rectangle {
                        id: inputButton
                        radius: 30
                        width: 30
                        height: 30
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 8
                        color: root.buffer === "" ? config.inverseOnSurface : config.primary
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                        Text {
                            renderType: Text.NativeRendering
                            anchors.centerIn: parent
                            font.family: "Material Symbols Rounded"
                            font.pointSize: 17
                            text: "\ue941"
                            color: root.buffer === "" ? config.text : config.mainCard
                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: root.buffer === "" ? Qt.ArrowCursor : Qt.PointingHandCursor
                            onClicked: {
                                sddm.login(userPicker.currentText, root.buffer, sessionPicker.currentIndex);
                                root.loading = true;
                            }
                        }
                    }
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
                    RandomQuote {
                        maxWidth: topRightRect.width - 40
                        color: config.text
                    }
                }
                Rectangle {
                    id: bottomRightRect
                    width: 390
                    height: 355
                    color: config.subComponents
                    bottomRightRadius: mainCard.radius / 1.9
                    radius: mainCard.radius / 4
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
                }
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
