import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    width: 1920
    height: 1080
    property real baseWidth: 1920
    property real baseHeight: 1080
    property real scaleX: width / baseWidth
    property real scaleY: height / baseHeight
    property real scaling: Math.min(scaleX, scaleY)
    color: "#131313"

    property bool ap: config.ap === "true" ? true : false
    property bool firstInput: true
    property string buffer

    onBufferChanged: {
        return // ill make animations for typing
    }

    Image {
        id: background
        anchors.fill: parent
        source: "assets/background.png"
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
            Behavior on opacity{NumberAnimation{duration: 300}}
        }
    }

    Item{
        id: keylogger
        focus: true
        Keys.onPressed: {
            if (root.firstInput) {
                root.firstInput = false
                return;
            }
            if (event.key === Qt.Key_Escape) {
                root.firstInput = true
                root.buffer = ""
                return; 
            }
            if (event.key === Qt.Key_Right) {
                if (userPicker.currentIndex < userModel.count - 1) {
                    userPicker.currentIndex += 1
                }   
                return; 
            }
            if (event.key === Qt.Key_Left) {
                if (userPicker.currentIndex > 0) {
                    userPicker.currentIndex -= 1
                }
                return; 
            }

            if (event.key === Qt.Key_Up) {
                if (sessionPicker.currentIndex < sessionPicker.count - 1) {
                    sessionPicker.currentIndex += 1
                }   
                return; 
            }
            if (event.key === Qt.Key_Down) {
                if (sessionPicker.currentIndex > 0) {
                    sessionPicker.currentIndex -= 1
                }
                return; 
            }

            if (event.key === Qt.Key_Backspace) {
                root.buffer = root.buffer.slice(0, -1)
                return
            }

            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                sddm.login(userPicker.currentText, root.buffer, sessionPicker.currentIndex)
                root.buffer = ""
                return; 
            }
            root.buffer += event.text
            console.log(root.buffer)
        }
    }

    MultiEffect{
        blurEnabled: true
        source: background
        blur: root.firstInput ? 0 : 1.0
        autoPaddingEnabled: false
        blurMultiplier: 1
        blurMax: 64
        anchors.fill: background
        Behavior on blur {NumberAnimation{duration: 400}}
    }

    Rectangle {
        id: mainCard
        width: 1300 * root.scaling
        height: 750 * root.scaling
        scale: firstInput ? 0.5 : 1.0
        opacity: firstInput ? 0.0 : 1.0
        anchors.centerIn: parent
        radius: 40 * root.scaling
        color: config.mainCard

        Behavior on scale{
            NumberAnimation{
                duration: 300 
                easing.type: Easing.OutBack
            }
        }

        Behavior on opacity{
            NumberAnimation{
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
                anchors.left: parent.left
                anchors.top: parent.top

                Rectangle {
                    id: topLeftRect
                    width: 390 * root.scaling
                    height: root.height / 6
                    color: config.subComponents
                    topLeftRadius: mainCard.radius
                    radius: mainCard.radius / 2
                    property string welcomeString: "nope"

                    function getPhase() {
                        var now = new Date()
                        var hour = now.getHours()

                        if (hour >= 20 || hour < 4) {
                            welcomeString = "Good night"
                        } else if (hour >= 4 && hour < 10) {
                            welcomeString = "Good morning"
                        } else {
                            welcomeString = "Good day"
                        }
                    }
                    Text {
                        width: topLeftRect.width - 40 * root.scaling

                        text: "<span style='color:" + config.text + ";'>" 
                            + topLeftRect.welcomeString + " </span>"
                            + "<span style='color:" + config.accent + ";'>" 
                            + userPicker.displayText + "</span>"

                        textFormat: Text.RichText

                        anchors.centerIn: parent
                        font.family: "Rubik"
                        font.bold: true
                        font.pixelSize: 40 * root.scaling
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter 
                    }

                    Timer{
                        interval: 60000 
                        running: true
                        onTriggered: topLeftRect.getPhase()
                        repeat: true
                    }
                    Component.onCompleted: getPhase()
                }

                Rectangle {
                    id: middleLeftRect
                    width: 390 * root.scaling
                    height: root.height / 3.2
                    color: config.subComponents
                    radius: mainCard.radius / 2
                    clip: true
                    Rectangle {
                        width: 30 * root.scaling
                        height: 40 * root.scaling
                        radius: 12 * root.scaling
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: 15 * root.scaling
                        anchors.topMargin: 15 * root.scaling
                        color: config.accent
                    }
                    ColumnLayout {
                        spacing: 10
                        Text {
                            Text {
                                color: "#111111"
                                text: ">"
                                font.family: "CaskaydiaCove NF"
                                font.pointSize: 15 * root.scaling
                            }
                            color: config.text
                            text: "  caelestiafetch.sh"
                            font.family: "CaskaydiaCove NF"
                            font.pointSize: 15 * root.scaling
                            Layout.leftMargin: 25
                            Layout.topMargin: 25 
                        }
                        RowLayout{
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            Image {
                                id: logoImage
                                source: "assets/logo.png"
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                                Layout.leftMargin: 15 * root.scaling
                                Layout.topMargin: middleLeftRect.height / 10
                                Layout.preferredWidth: 140 * root.scaling
                                Layout.preferredHeight: 140 * root.scaling
                            }
                            Text {
                                Layout.leftMargin: 20
                                Layout.topMargin: middleLeftRect.height / 10
                                text: "WM     :\nUSER   :\nUP     :\nBATTERY:"
                                color: config.text
                                font.pixelSize: 18
                                font.family:  "CaskaydiaCove NF"
                                lineHeight: 30
                                lineHeightMode: Text.FixedHeight
                                Layout.preferredWidth: 80 * root.scaling
                            }
                            Text {
                                Layout.leftMargin: 10
                                Layout.topMargin: middleLeftRect.height / 10
                                text: sessionPicker.currentText + "\n" + userPicker.currentText  +"\n" + "WIP" +"\n" + "WIP"
                                color: config.text
                                font.pixelSize: 18
                                font.family:  "CaskaydiaCove NF"
                                lineHeight: 30
                                lineHeightMode: Text.FixedHeight
                                Layout.preferredWidth: 100 * root.scaling
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 20 * root.scaling
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 20 * root.scaling
                            Rectangle {
                                width: 30 * root.scaling
                                height: 30 * root.scaling
                                color: config.background
                                radius: 12 * root.scaling
                            }
                            Rectangle {
                                width: 30 * root.scaling
                                height: 30 * root.scaling
                                color: config.accent
                                radius: 12 * root.scaling
                            }
                            Rectangle {
                                width: 30 * root.scaling
                                height: 30 * root.scaling
                                color: config.text
                                radius: 12 * root.scaling
                            }
                            Rectangle {
                                width: 30 * root.scaling
                                height: 30 * root.scaling
                                color: config.textDark
                                radius: 12 * root.scaling
                            }
                            Rectangle {
                                width: 30 * root.scaling
                                height: 30 * root.scaling
                                color: config.secondary
                                radius: 12 * root.scaling
                            }
                            Rectangle {
                                width: 30 * root.scaling
                                height: 30 * root.scaling
                                color: config.onSuccess
                                radius: 12 * root.scaling
                            }
                            Rectangle {
                                width: 30 * root.scaling
                                height: 30 * root.scaling
                                color: config.inverseOnSurface
                                radius: 12 * root.scaling
                            }
                        }
                    }
                }
                Rectangle {
                    id: bottomLeftRect
                    width: 390 * root.scaling
                    height: root.height / 6
                    color: config.subComponents
                    bottomLeftRadius: mainCard.radius
                    radius: mainCard.radius / 2
                    Text {
                        anchors.centerIn: parent
                        width: bottomLeftRect.width - 40 * root.scaling
                        text: "Use the arrow keys to change user and desktopenviroment"
                        color: config.text
                        font.pointSize: 18 * root.scaling
                        font.family: "CaskaydiaCove NF"
                        font.italic: true
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter 
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                Layout.fillWidth: true
                spacing: 30

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    color: "transparent"
                    width: 300 * root.scaling
                    height: 45 * root.scaling
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10
                    Text {
                        id: clock
                        Layout.alignment: Qt.AlignHCenter
                        text: ap ? Qt.formatTime(new Date(), "hh:mm AP") : Qt.formatTime(new Date(), "hh:mm")
                        font.pixelSize: 84
                        font.family: "Rubik"
                        font.bold: true
                        color: config.secondary
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDate(new Date(), "dddd,   d  MMMM  yyyy")
                        style: Text.Outline
                        styleColor: "#000000"
                        font.pixelSize: 28
                        font.family: "Rubik"
                        font.bold: true
                        color: config.textDark
                    }
                }

                Rectangle {
                    id: avatarFrame
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 220 * root.scaling
                    Layout.preferredHeight: 220 * root.scaling
                    radius: 110 * root.scaling
                    color: "black"
                    clip: true

                    Image {
                        id: avatarImage
                        anchors.fill: parent
                        source: "assets/avatar.jpg"
                        fillMode: Image.PreserveAspectCrop
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: parent
                        }
                        // asynchronous: true
                    }
                }

                Rectangle {
                    id: inputRect
                    Layout.alignment: Qt.AlignHCenter
                    color: config.subComponents
                    radius: 30
                    width: 340 * root.scaling
                    height: 50 * root.scaling
                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 17 * root.scaling
                        font.family: "Material Symbols Rounded"
                        font.pointSize:  15 * root.scaling
                        text: "\ue897"
                        color: '#a8a8a8'
                    }
                    Rectangle {
                        anchors.centerIn: parent
                        color: config.subComponents
                        radius: 30
                        width: 250 * root.scaling
                        height: 50 * root.scaling
                        clip: true
                        Text {
                            anchors.centerIn: parent
                            font.pointSize: 15 * root.scaling
                            text: "Enter your password"
                            color: '#6e6e6e'
                            font.family: "CaskaydiaCove NF"
                            opacity: root.buffer === "" ? 1: 0
                            Behavior on opacity{NumberAnimation{duration: 100}}
                        }
                        RowLayout {
                            anchors.centerIn: parent
                            Repeater {
                                id: characters
                                model: root.buffer.length
                                Rectangle {
                                    radius: 30
                                    width: 15 * root.scaling
                                    height: 15 * root.scaling
                                    color: "white"
                                }

                            }
                            Rectangle {
                                id: textIndicator
                                property bool invisible: true
                                visible: root.buffer === "" ? false: true
                                width: 1 * root.scaling
                                height: 25 * root.scaling
                                color: "white"
                                opacity: invisible ? 0 : 1
                                Behavior on opacity{NumberAnimation{duration: 200}}
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
                        width: 35 * root.scaling
                        height: 35 * root.scaling
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 8 * root.scaling
                        color: root.buffer === "" ? config.inverseOnSurface : config.accent
                        Behavior on color{ColorAnimation{duration: 200}}
                        Text {
                            anchors.centerIn: parent
                            font.family: "Material Symbols Rounded"
                            font.pointSize:  20
                            text: "\ue941"
                            color: root.buffer === "" ? config.text : config.mainCard
                            Behavior on color{ColorAnimation{duration: 200}}
                        }
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                sddm.login(userPicker.currentText, root.buffer, sessionPicker.currentIndex)
                                root.buffer = ""
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    color: "transparent"
                    width: 300 * root.scaling
                    height: 60 * root.scaling
                }
            }

            ColumnLayout {
                spacing: 10
                anchors.top: parent.top
                anchors.right: parent.right
                Rectangle {
                    id: topRightRect
                    width: 390 * root.scaling
                    height: 355 * root.scaling
                    color: config.subComponents
                    topRightRadius: mainCard.radius
                    radius: mainCard.radius / 2
                    RandomQuote{
                        maxWidth: topRightRect.width - 40 * root.scaling
                        color: config.text    
                    }
                }
                Rectangle {
                    id: bottomRightRect
                    width: 390 * root.scaling
                    height: 355 * root.scaling
                    color: config.subComponents
                    bottomRightRadius: mainCard.radius
                    radius: mainCard.radius / 2
                    Image {
                        id: dino
                        width : 300
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
                        text: "Login for notifications"
                        color: config.inverseOnSurface
                        font.family: "CaskaydiaCove NF"
                        font.pointSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 50 * root.scaling
                    }
                }
            }
        }

    }

    Text{
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        font.family: "Rubik"
        font.pointSize: 18
        font.italic: true
        opacity: root.firstInput ? 1.0 : 0.0
        color: "#c4c7c6"
        text: "Press a key on your Keyboard to login"

        Behavior on opacity{
            NumberAnimation{
                duration: 300 
                easing.type: Easing.OutCubic
            }
        }
    }

    ComboBox {
        // invisible just for now
        id: userPicker
        width: 190 * root.scaling
        height: 50 * root.scaling
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
        width: 190 * root.scaling
        height: 50 * root.scaling
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