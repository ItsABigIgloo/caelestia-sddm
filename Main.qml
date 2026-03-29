import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#131313"

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
            opacity: 0.4
        }
    }

    Rectangle {
        id: mainCard
        width: 550
        height: 800
        anchors.centerIn: parent
        radius: 30
        border.color: "#BF4cdadb"
        border.width: 1

        gradient: Gradient {
            GradientStop {
                position: 0.5
                color: "#BF1b1b1b"
            }
            GradientStop {
                position: 1.0
                color: "#BF4cdadb"
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 30

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10
                Text {
                    id: clock
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatTime(new Date(), "hh:mm AP")
                    style: Text.Outline
                    styleColor: "#000000"
                    font.pixelSize: 84
                    font.family: "Rubik"
                    color: "#e2e2e2"
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDate(new Date(), "dddd, d MMMM yyyy")
                    style: Text.Outline
                    styleColor: "#000000"
                    font.pixelSize: 22
                    font.family: "Rubik"
                    color: "#919191"
                }
            }

            Rectangle {
                id: avatarFrame
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 220
                Layout.preferredHeight: 220
                radius: 110
                color: "#BF131313"
                border.color: "#4cdadb"
                border.width: 2
                clip: true

                Image {
                    id: avatarImage
                    anchors.fill: parent
                    anchors.margins: 20
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true

                    source: {
                        if (userPicker.currentIndex !== -1) {
                            var userName = userModel.data(userModel.index(userPicker.currentIndex, 0), Qt.UserRole + 1);

                            var faceIcon = "file:///home/" + userName + "/.face.icon";
                            var faceFile = "file:///home/" + userName + "/.face";

                            var modelIcon = userModel.data(userModel.index(userPicker.currentIndex, 0), Qt.UserRole + 2);

                            if (modelIcon && modelIcon !== "") {
                                return "file://" + modelIcon;
                            } else {
                                return faceIcon;
                            }
                        }
                        return "assets/logo.png";
                    }

                    onStatusChanged: {
                        if (status === Image.Error && source.toString().includes(".face.icon")) {
                            var userName = userModel.data(userModel.index(userPicker.currentIndex, 0), Qt.UserRole + 1);
                            source = "file:///home/" + userName + "/.face";
                        } else if (status === Image.Error) {
                            source = "assets/logo.png";
                        }
                    }
                }
            }

            ComboBox {
                id: userPicker
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 380
                Layout.preferredHeight: 55
                model: userModel
                currentIndex: userModel.lastIndex
                textRole: "name"
                font.family: "Rubik"
                font.pixelSize: 20

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

            TextField {
                id: passwordField
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 380
                Layout.preferredHeight: 55
                echoMode: TextInput.Password
                placeholderText: "Password"
                placeholderTextColor: "#e2e2e2"
                font.family: "Rubik"
                font.pixelSize: 22
                color: "#e2e2e2"
                horizontalAlignment: TextInput.AlignHCenter

                background: Rectangle {
                    color: "#BF131313"
                    radius: 35
                    border.color: passwordField.activeFocus ? "#4cdadb" : "#353535"
                }
                onAccepted: sddm.login(userPicker.currentText, text, sessionPicker.currentIndex)
            }

            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 50
                Button {
                    id: shutBtn
                    onClicked: sddm.powerOff()
                    background: Item {}
                    contentItem: Text {

                        text: "\ue8ac"
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 42
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: shutBtn.hovered ? "#ffb4ab" : "#e2e2e2"
                    }
                }

                Button {
                    id: rebBtn
                    onClicked: sddm.reboot()
                    background: Item {}
                    contentItem: Text {
                        text: "\uf053"
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 42
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: rebBtn.hovered ? "#4cdadb" : "#e2e2e2"
                    }
                }
            }

            ComboBox {
                id: sessionPicker
                Layout.alignment: Qt.AlignHCenter

                // 1. Remove fixed Layout.preferredWidth and use implicitWidth
                implicitWidth: contentItem.implicitWidth + (indicator.width * 2) + 20
                Layout.preferredHeight: 40

                model: sessionModel
                currentIndex: sessionModel.lastIndex
                textRole: "name"
                font.family: "Rubik"
                font.pixelSize: 18

                background: Rectangle {
                    // The background will now naturally follow the ComboBox width
                    color: "#BF131313"
                    radius: 20
                    border.color: "#353535"
                    border.width: 1
                }

                contentItem: Text {
                    // 2. Reference the displayText to calculate size
                    text: sessionPicker.displayText
                    font: sessionPicker.font
                    color: "#e2e2e2"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter

                    // 3. Add horizontal padding so text isn't cramped
                    leftPadding: 15
                    rightPadding: 15
                }

                indicator: Canvas {
                    id: canvas
                    // 4. Anchor the arrow to the right side of the control
                    x: sessionPicker.width - width - 10
                    y: (sessionPicker.height - height) / 2
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
    }
}
