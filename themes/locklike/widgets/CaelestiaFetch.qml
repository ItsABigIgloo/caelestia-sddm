import "../components"
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property bool firstInput
    required property string currentSession
    required property string currentUser
    required property int rectHeight

    property string os: (config.os || "Arch").split(" ")[0]
    property string host: "."
    property string session: (root.currentSession || "Hyprland").split(" ")[0]
    property int animDuration: 300
    property int _activeUserName: 0

    function crossfadeUserName() {
        if (root.currentUser === "") return;
        var hidden = _activeUserName === 0 ? userNameB : userNameA;
        hidden.text = root.currentUser;
        _activeUserName = _activeUserName === 0 ? 1 : 0;
    }

    Component.onCompleted: {
        userNameA.text = root.currentUser;
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "file:///proc/sys/kernel/hostname");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var h = xhr.responseText.trim();
                root.host = h.length > 0 ? h : (config.host || "localhost");
            }
        };
        xhr.send();
    }

    RowLayout {
        Rectangle {
            width: 33; height: 35; radius: 13
            Layout.leftMargin: 23; Layout.topMargin: 25
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            color: config.secondary
            Text {
                renderType: Text.NativeRendering
                anchors.centerIn: parent; color: "#111111"
                text: ">"; font.family: "CaskaydiaCove NF"; font.pointSize: 15
            }
        }
        Text {
            renderType: Text.NativeRendering
            color: config.text; text: "caelestiafetch.sh"
            font.family: "CaskaydiaCove NF"; font.pointSize: 13
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.topMargin: 32; Layout.leftMargin: 8
        }
    }

    ColumnLayout {
        Item { width: 30; height: 30 }

        RowLayout {
            Layout.fillWidth: true; Layout.alignment: Qt.AlignHCenter

            Logo {
                skipIntroAnimation: root.firstInput
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.leftMargin: 25; Layout.topMargin: 50
                Layout.preferredWidth: 130; Layout.preferredHeight: 130
            }

            RowLayout {
                spacing: 10

                Text {
                    renderType: Text.NativeRendering
                    Layout.leftMargin: 12; Layout.topMargin: root.rectHeight / 10
                    text: "WM     :\nUSER   :\nOS     :\nHOST   :"
                    color: config.text; font.pixelSize: parseInt(config.fetchFontSize) || 18
                    font.family: "CaskaydiaCove NF"
                    lineHeight: 30; lineHeightMode: Text.FixedHeight
                    Layout.preferredWidth: 80
                }

                Item {
                    Layout.preferredWidth: 100
                    Layout.topMargin: root.rectHeight / 10
                    implicitHeight: sessionText.height + 90

                    Text {
                        id: sessionText
                        text: root.session
                        color: config.text; font.pixelSize: 18
                        font.family: "CaskaydiaCove NF"
                        lineHeight: 30; lineHeightMode: Text.FixedHeight
                    }

                    Item {
                        y: 30
                        width: 100; height: userNameA.height
                        Text {
                            id: userNameA
                            color: config.text; font.pixelSize: 18
                            font.family: "CaskaydiaCove NF"
                            lineHeight: 30; lineHeightMode: Text.FixedHeight
                            opacity: _activeUserName === 0 ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation { duration: root.animDuration; easing: Easing.InOutCubic }
                            }
                        }
                        Text {
                            id: userNameB
                            color: config.text; font.pixelSize: 18
                            font.family: "CaskaydiaCove NF"
                            lineHeight: 30; lineHeightMode: Text.FixedHeight
                            opacity: _activeUserName === 0 ? 0 : 1
                            Behavior on opacity {
                                NumberAnimation { duration: root.animDuration; easing: Easing.InOutCubic }
                            }
                        }
                    }

                    Text {
                        y: 60
                        text: root.os
                        color: config.text; font.pixelSize: 18
                        font.family: "CaskaydiaCove NF"
                        lineHeight: 30; lineHeightMode: Text.FixedHeight
                    }

                    Text {
                        y: 90
                        text: root.host
                        color: config.text; font.pixelSize: 18
                        font.family: "CaskaydiaCove NF"
                        lineHeight: 30; lineHeightMode: Text.FixedHeight
                    }
                }
            }
        }

        RowLayout {
            spacing: 20; Layout.alignment: Qt.AlignHCenter
            Layout.leftMargin: 30; Layout.topMargin: 4

            Rectangle { width: 30; height: 30; color: config.background; radius: 12 }
            Rectangle { width: 30; height: 30; color: config.primary; radius: 12 }
            Rectangle { width: 30; height: 30; color: config.text; radius: 12 }
            Rectangle { width: 30; height: 30; color: config.textDark; radius: 12 }
            Rectangle { width: 30; height: 30; color: config.secondary; radius: 12 }
            Rectangle { width: 30; height: 30; color: config.onSuccess; radius: 12 }
            Rectangle { width: 30; height: 30; color: config.inverseOnSurface; radius: 12 }
        }
    }
}
